import asyncio
import struct
import binascii
import time
from typing import Dict, List, Optional, Any
from bleak import BleakScanner, BleakClient
from bleak.backends.device import BLEDevice
from bleak.backends.scanner import AdvertisementData

# BLE 관련 상수 정의
TL_UUID_APP_BEACON_UINT = 0x6C6E6A7D  # 비콘 UUID
APP_COMPANY_IDENTIFIER = 0x0059       # Nordic Semiconductor 식별자

# Nordic UART Service UUIDs
NUS_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
NUS_RX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"  # 디바이스로 데이터 전송 (Write)
NUS_TX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"  # 디바이스로부터 데이터 수신 (Notify)

class TemperatureReceiver:
    def __init__(self):
        self.discovered_devices: Dict[str, Dict[str, Any]] = {}
        self.client: Optional[BleakClient] = None
        self.connected = False
        self.temperature_data = []
        self.scanning_task = None

    async def scan_beacons(self, duration: float = 10.0) -> Dict[str, Dict[str, Any]]:
        """비콘을 스캔하고 발견된 디바이스 목록을 반환"""
        print(f"BLE 비콘 스캔 중... ({duration}초)")
        self.discovered_devices = {}
        
        def detection_callback(device: BLEDevice, advertisement_data: AdvertisementData):
            """비콘 디바이스 감지 콜백"""
            # 제조사 데이터가 있는지 확인
            if advertisement_data.manufacturer_data:
                for company_id, data in advertisement_data.manufacturer_data.items():
                    try:
                        # 제조사 ID가 Nordic인지 확인
                        if company_id == APP_COMPANY_IDENTIFIER:
                            # 비콘 데이터 파싱
                            if len(data) >= 10:  # 최소 데이터 길이 확인
                                # 비콘 UUID 확인 (제조사 데이터의 앞부분인 device type과 length 이후 위치)
                                uuid_bytes = data[2:6]
                                uuid = int.from_bytes(uuid_bytes, byteorder='little')
                                
                                if uuid == TL_UUID_APP_BEACON_UINT:
                                    # 시리얼 번호 추출 (MAC 주소에서)
                                    addr_bytes = device.address.replace(':', '').encode()
                                    serial = int.from_bytes(addr_bytes[-8:], byteorder='big')
                                    
                                    # 데이터 처리 및 저장
                                    payload = data[6:]  # UUID 이후의 데이터
                                    
                                    print(f"수신된 디바이스: {device.address}, 시리얼: {serial}, RSSI: {advertisement_data.rssi}")
                                    print(f"데이터: {binascii.hexlify(payload).decode()}")
                                    
                                    # 디바이스 정보 저장
                                    self.discovered_devices[device.address] = {
                                        "device": device,
                                        "serial": serial,
                                        "rssi": advertisement_data.rssi,
                                        "data": payload,
                                        "last_seen": time.time()
                                    }
                    except Exception as e:
                        print(f"데이터 파싱 중 오류: {e}")
        
        # 스캔 시작
        scanner = BleakScanner(detection_callback)
        await scanner.start()
        await asyncio.sleep(duration)
        await scanner.stop()
        
        return self.discovered_devices

    async def connect_to_device(self, device_addr: str) -> bool:
        """특정 디바이스에 연결"""
        try:
            print(f"디바이스에 연결 중: {device_addr}")
            
            # 발견된 디바이스 목록에서 해당 주소를 가진 디바이스 찾기
            if device_addr in self.discovered_devices:
                device = self.discovered_devices[device_addr]["device"]
            else:
                # 스캔 결과에 없으면 주소로만 연결 시도
                device = device_addr
            
            # 연결
            self.client = BleakClient(device)
            await self.client.connect()
            self.connected = True
            print("연결 성공!")
            
            # 알림 콜백 설정
            await self.setup_notifications()
            
            return True
        except Exception as e:
            print(f"연결 실패: {e}")
            self.connected = False
            return False

    async def setup_notifications(self):
        """NUS 서비스의 TX 특성(디바이스에서 데이터 수신)에 대한 알림 설정"""
        if not self.connected or not self.client:
            return False
        
        try:
            # TX 특성(디바이스가 데이터를 보내는 특성)에 대한 알림 활성화
            await self.client.start_notify(NUS_TX_CHAR_UUID, self.notification_handler)
            print("알림 설정 완료")
            return True
        except Exception as e:
            print(f"알림 설정 중 오류: {e}")
            return False

    def notification_handler(self, sender, data):
        """온도 데이터 알림 처리"""
        print(f"알림 수신: 데이터 길이 {len(data)}")
        print(f"데이터: {binascii.hexlify(data).decode()}")
        
        # 온도 데이터 파싱
        try:
            # 데이터 형식에 따라 파싱 로직 구현
            # 예: 첫 바이트가 시퀀스 번호, 두 번째 바이트가 데이터 길이
            if len(data) >= 2:
                seq_num = data[0]
                data_len = data[1]
                
                # 온도 데이터 추출 (실제 형식에 맞게 수정 필요)
                if len(data) >= 2 + data_len:
                    temp_data = data[2:2+data_len]
                    self.temperature_data.append({
                        "sequence": seq_num,
                        "data": temp_data
                    })
                    
                    # 온도 값 예시 (실제 형식에 맞게 수정 필요)
                    if len(temp_data) >= 2:
                        temp_value = struct.unpack("<h", temp_data[0:2])[0] / 100.0  # 예시: 2바이트 int16, 100으로 나눔
                        print(f"온도: {temp_value}°C")
        except Exception as e:
            print(f"데이터 파싱 중 오류: {e}")

    async def disconnect(self):
        """디바이스 연결 해제"""
        if self.client and self.connected:
            try:
                await self.client.disconnect()
            except Exception as e:
                print(f"연결 해제 중 오류: {e}")
            finally:
                self.connected = False
                print("연결 해제됨")

    async def find_and_connect_device(self, serial_number: int, scan_duration: float = 15.0) -> bool:
        """특정 시리얼 번호의 디바이스를 찾아 연결"""
        # 스캔 실행
        print(f"시리얼 번호 {serial_number}의 디바이스 검색 중...")
        await self.scan_beacons(scan_duration)
        
        # 타겟 디바이스 찾기
        target_addr = None
        for addr, device_info in self.discovered_devices.items():
            if device_info["serial"] == serial_number:
                target_addr = addr
                break
        
        if target_addr:
            return await self.connect_to_device(target_addr)
        else:
            print(f"시리얼 번호 {serial_number}의 디바이스를 찾을 수 없음")
            return False

    async def receive_temperature_data(self):
        """연결된 디바이스로부터 온도 데이터 수신"""
        if not self.connected or not self.client:
            print("디바이스가 연결되어 있지 않음")
            return None
        
        try:
            # 서비스 탐색
            services = await self.client.get_services()
            nus_service = services.get_service(NUS_SERVICE_UUID)
            
            if nus_service:
                # TX 특성 확인
                tx_char = nus_service.get_characteristic(NUS_TX_CHAR_UUID)
                # RX 특성 확인
                rx_char = nus_service.get_characteristic(NUS_RX_CHAR_UUID)
                
                if tx_char and rx_char:
                    # 온도 데이터 요청 메시지 전송
                    request_msg = bytes([0xD7, 0x11, 0x00, 0x00])  # TL_MSG_STX_RCV_TO_LGR, TL_CMD_REQUEST_TEMPERATURE
                    await self.client.write_gatt_char(rx_char.uuid, request_msg)
                    
                    print("온도 데이터 요청 전송됨. 응답 대기 중...")
                    
                    # 알림을 통해 데이터를 받기 위해 대기
                    # Bleak는 자동으로 핸들러로 알림을 전달하므로 응답을 대기하기만 하면 됨
                    try:
                        await asyncio.sleep(10.0)  # 10초 동안 응답 대기
                        if len(self.temperature_data) > 0:
                            print("온도 데이터 수신 완료!")
                            return True
                        else:
                            print("10초 동안 응답 없음")
                            return False
                    except asyncio.CancelledError:
                        print("데이터 수신 대기 취소됨")
                        return False
                else:
                    print("필요한 특성을 찾을 수 없음")
                    return False
            else:
                print("NUS 서비스를 찾을 수 없음")
                return False
                
        except Exception as e:
            print(f"온도 데이터 수신 중 오류: {e}")
            return False

    async def start_scan_mode(self):
        """스캔 모드 시작 - 정기적으로 비콘 스캔"""
        try:
            while True:
                await self.scan_beacons(15.0)  # 15초 동안 스캔
                print(f"발견된 디바이스 수: {len(self.discovered_devices)}")
                for addr, device_info in self.discovered_devices.items():
                    print(f"디바이스: {addr}, 시리얼: {device_info['serial']}, RSSI: {device_info['rssi']}")
                
                print("10초 후 재스캔...")
                await asyncio.sleep(10.0)
        except asyncio.CancelledError:
            print("스캔 모드 취소됨")

async def main_menu():
    receiver = TemperatureReceiver()
    
    while True:
        print("\n====== 온도 수신기 ======")
        print("1. 비콘 스캔")
        print("2. 시리얼 번호로 디바이스 연결")
        print("3. 온도 데이터 수신")
        print("4. 연결 해제")
        print("5. 스캔 모드 시작")
        print("0. 종료")
        
        choice = input("선택: ")
        
        if choice == "1":
            devices = await receiver.scan_beacons()
            print(f"\n발견된 디바이스 수: {len(devices)}")
            for addr, device_info in devices.items():
                print(f"디바이스: {addr}, 시리얼: {device_info['serial']}, RSSI: {device_info['rssi']}")
        
        elif choice == "2":
            serial = int(input("연결할 디바이스의 시리얼 번호: "))
            await receiver.find_and_connect_device(serial)
        
        elif choice == "3":
            await receiver.receive_temperature_data()
        
        elif choice == "4":
            await receiver.disconnect()
        
        elif choice == "5":
            # 스캔 모드 시작하고 사용자가 중단할 때까지 실행
            print("스캔 모드 시작 (Ctrl+C로 중단)...")
            try:
                receiver.scanning_task = asyncio.create_task(receiver.start_scan_mode())
                await receiver.scanning_task
            except KeyboardInterrupt:
                if receiver.scanning_task:
                    receiver.scanning_task.cancel()
                    try:
                        await receiver.scanning_task
                    except asyncio.CancelledError:
                        pass
                print("스캔 모드 중단됨")
        
        elif choice == "0":
            await receiver.disconnect()
            print("프로그램 종료")
            break

def main():
    try:
        asyncio.run(main_menu())
    except KeyboardInterrupt:
        print("\n프로그램이 사용자에 의해 중단되었습니다.")

if __name__ == "__main__":
    main()