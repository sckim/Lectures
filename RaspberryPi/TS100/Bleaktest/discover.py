import asyncio
import time

from bleak import BleakScanner, BleakClient

DEVICE_ADDRESS = "XX:XX:XX:XX:XX:XX"  # BLE 기기의 MAC 주소

SERVICE_UUID = "00001809-0000-1000-8000-00805f9b34fb" # TS100 서비스 UUID
CHARACTERISTIC_UUID = "00002a1c-0000-1000-8000-00805f9b34fb"  # TS100 캐릭터리스틱 UUID

# BLE 장치 검색
# BleakScanner.discover() 함수를 사용하여 BLE 장치를 검색하고, 검색된 장치의 주소와 이름을 출력한다.
async def scan_devices():
    devices = await BleakScanner.discover()
    for device in devices:
        print(f"주소: {device.address}, 이름: {device.name}")

async def scan_and_filter():
    devices = await BleakScanner.discover()
    matched_devices = [device for device in devices if device.name and DEVICE_NAME in device.name]

    if matched_devices:
        print("일치하는 장치 목록:")
        for device in matched_devices:
            print(f"주소: {device.address}, 이름: {device.name}")
    else:
        print("일치하는 장치를 찾을 수 없습니다.")

async def scan_devices_filter(DEVICE_NAME):
    device = await BleakScanner.find_device_by_filter(
        lambda d, ad: d.name and DEVICE_NAME.lower() in d.name.lower()
    )
    # 일치
    # device = await BleakScanner.find_device_by_filter(
    #                 lambda d, ad: d.name and d.name.lower() == DEVICE_NAME.lower(),
    #             )

    if device:
        print(f"일치하는 장치 발견: 주소: {device.address}, 이름: {device.name}")
        return device
    else:
        print("일치하는 장치를 찾을 수 없습니다.")


async def read_data(DEVICE_ADDRESS):
    async with BleakClient(DEVICE_ADDRESS) as client:
        if client.is_connected:
            print(f"{DEVICE_ADDRESS}에 연결됨")
            data = await client.read_gatt_char(CHARACTERISTIC_UUID)
            print(f"데이터: {data}")

async def write_data():
    async with BleakClient(DEVICE_ADDRESS) as client:
        if client.is_connected:
            data = bytearray([0x01])  # 전송할 데이터
            await client.write_gatt_char(CHARACTERISTIC_UUID, data)
            print("데이터 전송 완료")
   
DEVICE_NAME = "TS100"

asyncio.run(scan_devices())    
# asyncio.run(scan_and_filter())
# device = asyncio.run(scan_devices_filter(DEVICE_NAME))
# time.sleep(2)
# device = asyncio.run(read_data(device.address))
# asyncio.run(write_data())
# asyncio.run(read_data())
