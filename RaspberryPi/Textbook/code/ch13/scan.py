#!/usr/bin/env python3
"""scan.py : 실습 13-2  주변 BLE 장치를 스캔하여 이름·주소·RSSI·서비스 UUID를 보여 준다

사용법 : python scan.py                      # 5초 동안 스캔, 전부 출력
         python scan.py --name TS100         # 이름이 TS100으로 시작하는 장치만
         python scan.py --hts                # Health Thermometer(0x1809)를 광고하는 장치만
         python scan.py --time 10            # 10초 동안 스캔
원본 : TS100-Gitbook 4.1.3절 scan(), TS100/Bleaktest/discover.py
       (bleak 3.x에서 BLEDevice.rssi가 없어졌으므로 AdvertisementData.rssi를 쓰도록 고침)
"""

import argparse
import asyncio

from bleak import BleakScanner

from hts import HTS_SERVICE_UUID


async def main():
    parser = argparse.ArgumentParser(description="BLE 스캐너 (13장)")
    parser.add_argument("--time", type=float, default=5.0, help="스캔 시간(초)")
    parser.add_argument("--name", default="", help="이름 앞부분으로 거르기 (예: TS100)")
    parser.add_argument("--hts", action="store_true", help="0x1809 서비스를 광고하는 장치만")
    args = parser.parse_args()

    print("스캔 중... (%.0f초)" % args.time)
    # return_adv=True: {주소: (BLEDevice, AdvertisementData)} 사전을 돌려준다
    found = await BleakScanner.discover(timeout=args.time, return_adv=True)

    rows = []
    for address, (device, adv) in found.items():
        name = adv.local_name or device.name or ""
        if args.name and not name.startswith(args.name):
            continue
        if args.hts and HTS_SERVICE_UUID not in adv.service_uuids:
            continue
        rows.append((adv.rssi, address, name, adv))

    rows.sort(key=lambda r: r[0], reverse=True)          # 신호가 센(가까운) 순서
    print("%-17s  %5s  %-20s  %s" % ("주소", "RSSI", "이름", "광고한 서비스 UUID"))
    for rssi, address, name, adv in rows:
        uuids = ", ".join(u[4:8] if u.endswith("-0000-1000-8000-00805f9b34fb") else u
                          for u in adv.service_uuids)   # 표준 UUID는 16비트로 줄여 표시
        print("%-17s  %5d  %-20s  %s" % (address, rssi, name or "(이름 없음)", uuids))
        if adv.manufacturer_data:
            for company, payload in adv.manufacturer_data.items():
                print("%17s  제조사 0x%04X 데이터: %s" % ("", company, payload.hex(" ")))
    print("장치 %d개 (전체 %d개 중)" % (len(rows), len(found)))


if __name__ == "__main__":
    asyncio.run(main())
