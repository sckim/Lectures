#!/usr/bin/env python3
"""read_temp.py : 실습 13-3  체온계에 연결해 Temperature Measurement(0x2A1C)를 구독하고 출력한다

사용법 : python read_temp.py --name TS100              # 이름이 TS100으로 시작하는 첫 장치
         python read_temp.py --address XX:XX:XX:XX:XX:XX
         python read_temp.py --name TS100 --set-time   # 연결 직후 0x2A08에 Pi의 현재 시각을 쓴다
끝내기 : Ctrl+C (SIGINT) 또는 kill (SIGTERM) -> 구독을 끊고 정상 종료
원본 : TS100-Gitbook 4.1.3절 connect(), get_service_and_characteristic(), notify_callback()
       (tkinter 선택 창 대신 명령줄 인자, 연결이 끊기면 다시 연결, bleak 1.x 이후 콜백 형식)
       여러 장치 연결 시 잠금(connect_lock): bleak 저장소 examples/two_devices.py의 방법
"""

import argparse
import asyncio
import contextlib
import signal
from datetime import datetime

from bleak import BleakClient, BleakScanner
from bleak.exc import BleakError

from hts import (HTS_SERVICE_UUID, TEMP_MEASUREMENT_UUID, DATE_TIME_UUID,
                 parse_temperature_measurement, encode_date_time)


async def wait_first(*events):
    """여러 asyncio.Event 중 하나라도 set되면 돌아온다."""
    tasks = [asyncio.create_task(e.wait()) for e in events]
    try:
        await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
    finally:
        for t in tasks:
            t.cancel()


async def find_device(address, name, scan_time):
    """주소가 있으면 주소로, 없으면 이름 앞부분 또는 0x1809 광고로 장치를 찾는다."""
    if address:
        return await BleakScanner.find_device_by_address(address, timeout=scan_time)

    def match(device, adv):
        dev_name = adv.local_name or device.name or ""
        if name:
            return dev_name.startswith(name)
        return HTS_SERVICE_UUID in adv.service_uuids

    return await BleakScanner.find_device_by_filter(match, timeout=scan_time)


async def run_session(address, name, on_sample, stop, set_time=False, scan_time=10.0,
                      connect_lock=None, timeout=30.0):
    """찾기 -> 연결 -> 구독한 뒤, stop이 set되거나 연결이 끊길 때까지 머문다.

    찾은 장치의 주소를 돌려준다(못 찾으면 None). connect_lock을 주면 찾기~구독 구간만
    잠가서, 여러 장치를 동시에 찾고 연결하다 BlueZ에서 생기는 충돌을 피한다.
    """
    disconnected = asyncio.Event()
    async with contextlib.AsyncExitStack() as stack:      # 블록을 나갈 때 연결을 끊어 준다
        async with (connect_lock or contextlib.nullcontext()):
            device = await find_device(address, name, scan_time)
            if device is None:
                print("장치를 찾지 못했다 (%s)" % (address or name or "0x1809"))
                return None

            def on_disconnect(client):                   # bleak가 이벤트 루프에서 불러 준다
                print("[%s] 연결 끊김" % device.address)
                disconnected.set()

            def on_notify(characteristic, data):         # bleak 1.x 이후: (특성, bytearray)
                try:
                    m = parse_temperature_measurement(data)
                except ValueError as e:
                    print("[%s] 해석 실패(%s): %s" % (device.address, e, bytes(data).hex(" ")))
                    return
                on_sample(device, m, bytes(data))

            client = await stack.enter_async_context(
                BleakClient(device, disconnected_callback=on_disconnect, timeout=timeout))
            print("[%s] 연결됨: %s" % (device.address, device.name))
            char = client.services.get_characteristic(TEMP_MEASUREMENT_UUID)
            if char is None:
                raise BleakError("0x2A1C 특성이 없다 (Health Thermometer 장치가 맞는가?)")
            print("[%s] 0x2A1C 속성: %s" % (device.address, ", ".join(char.properties)))
            if "notify" not in char.properties and "indicate" not in char.properties:
                raise BleakError("0x2A1C가 notify/indicate를 지원하지 않는다")

            if set_time:
                dt_char = client.services.get_characteristic(DATE_TIME_UUID)
                if dt_char is not None and "write" in dt_char.properties:
                    await client.write_gatt_char(dt_char, encode_date_time(datetime.now()),
                                                 response=True)
                    print("[%s] 0x2A08에 현재 시각을 썼다" % device.address)

            # notify든 indicate든 start_notify 하나로 된다(CCCD 0x2902에 알맞은 값을 써 준다)
            await client.start_notify(char, on_notify)
        # 여기서 잠금이 풀린다. 연결은 유지되고, 다른 장치가 찾기·연결을 시작할 수 있다

        await wait_first(stop, disconnected)
        if client.is_connected:
            await client.stop_notify(char)
    return device.address


async def monitor(address, name, on_sample, stop, set_time=False, scan_time=10.0,
                  connect_lock=None):
    """찾기 -> 연결 -> 구독을 반복한다. 끊기거나 실패하면 점점 길게 기다렸다가 다시 시도한다."""
    backoff = 2.0
    while not stop.is_set():
        try:
            found = await run_session(address, name, on_sample, stop, set_time,
                                      scan_time, connect_lock)
            if found:
                address = found                        # 한 번 찾으면 그 장치만 계속 쓴다
                backoff = 2.0                          # 정상 연결 뒤에는 대기 시간을 처음으로
        except (BleakError, asyncio.TimeoutError, OSError) as e:
            print("오류: %s: %s" % (type(e).__name__, e))
        if stop.is_set():
            break
        print("%.0f초 뒤 다시 시도" % backoff)
        try:
            await asyncio.wait_for(stop.wait(), timeout=backoff)
        except asyncio.TimeoutError:
            pass
        backoff = min(backoff * 2, 60.0)


def print_sample(device, m, raw):
    now = datetime.now().strftime("%H:%M:%S")
    text = "%s  %-14s %.2f %s" % (now, device.name or device.address, m.value, m.unit)
    if m.timestamp:
        text += "  (장치 시각 %s)" % m.timestamp
    if m.temp_type is not None:
        text += "  [%s]" % m.temp_type_name
    print(text + "  raw=" + raw.hex(" "))


async def main():
    parser = argparse.ArgumentParser(description="Health Thermometer 수신기 (13장)")
    parser.add_argument("--address", help="장치 주소 XX:XX:XX:XX:XX:XX")
    parser.add_argument("--name", default="", help="장치 이름 앞부분 (예: TS100)")
    parser.add_argument("--set-time", action="store_true", help="0x2A08에 현재 시각 쓰기")
    args = parser.parse_args()

    stop = asyncio.Event()
    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)        # Ctrl+C, systemctl stop 모두 정상 종료

    await monitor(args.address, args.name, print_sample, stop, args.set_time)
    print("종료")


if __name__ == "__main__":
    asyncio.run(main())
