import time
import struct
import binascii
from bluepy.btle import Scanner, DefaultDelegate, Peripheral, UUID, BTLEDisconnectError

# BLE 관련 상수 정의
TL_UUID_APP_BEACON_UINT = 0x6C6E6A7D  # 비콘 UUID
APP_COMPANY_IDENTIFIER = 0x0059       # Nordic Semiconductor 식별자

class ScanDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)
        self.discovered_devices = {}
        self.scanning_for_device = False
        self.target_serial = None
        
    def handleDiscovery(self, dev, isNewDev, isNewData):
        """비콘 데이터를 스캔하고 처리하는 함수"""
        if isNewDev or isNewData:
            # 제조사 데이터가 있는지 확인
            for (adtype, desc, value) in dev.getScanData():
                if adtype == 255:  # 제조사 데이터
                    try:
                        # 데이터 파싱 (제조사 ID가 Nordic인지 확인)
                        manufacturer_id = struct.unpack("<H", binascii.unhexlify(value[0:4]))[0]
                        if manufacturer_id == APP_COMPANY_IDENTIFIER:
                            # 비콘 데이터 파싱
                            data_hex = value[4:]
                            if len(data_hex) >= 8:  # 최소 데이터 길이 확인
                                # 비콘 UUID 확인
                                uuid = struct.unpack("<I", binascii.unhexlify(data_hex[4:12]))[0]
                                if uuid == TL_UUID_APP_BEACON_UINT:
                                    # 시리얼 번호 추출 (MAC 주소에서)
                                    serial = int.from_bytes(dev.addr.replace(':', '')[-8:].encode(), byteorder='big')
                                    
                                    # 데이터 처리 및 저장
                                    rssi = dev.rssi
                                    payload = binascii.unhexlify(data_hex[12:])
                                    
                                    print(f"수신된 디바이스: {dev.addr}, 시리얼: {serial}, RSSI: {rssi}")
                                    print(f"데이터: {binascii.hexlify(payload).decode()}")
                                    
                                    # 디바이스 정보 저장
                                    self.discovered_devices[dev.addr] = {
                                        "serial": serial,
                                        "rssi": rssi,
                                        "data": payload,
                                        "last_seen": time.time()
                                    }
                                    
                                    # 특정 시리얼 번호 디바이스를 찾고 있다면
                                    if self.scanning_for_device and serial == self.target_serial:
                                        print(f"목표 디바이스 발견: {dev.addr}")
                                        return dev.addr
                    except Exception as e:
                        print(f"데이터 파싱 중 오류: {e}")

class TemperatureReceiver:
    def __init__(self):
        self.scanner = Scanner().withDelegate(ScanDelegate())
        self.delegate = self.scanner.delegate
        self.peripheral = None
        self.connected = False
        
    def scan_beacons(self, duration=10):
        """비콘을 스캔하고 발견된 디바이스 목록을 반환"""
        print(f"BLE 비콘 스캔 중... ({duration}초)")
        self.scanner.scan(duration)
        return self.delegate.discovered_devices
    
    def connect_to_device(self, device_addr):
        """특정 디바이스에 연결"""
        try:
            print(f"디바이스에 연결 중: {device_addr}")
            self.peripheral = Peripheral(device_addr)
            self.peripheral.setDelegate(DefaultDelegate())
            self.connected = True
            print("연결 성공!")
            return True
        except BTLEDisconnectError as e:
            print(f"연결 실패: {e}")
            return False
    
    def disconnect(self):
        """디바이스 연결 해제"""
        if self.peripheral and self.connected:
            self.peripheral.disconnect()
            self.connected = False
            print("연결 해제됨")
    
    def find_and_connect_device(self, serial_number, scan_duration=15):
        """특정 시리얼 번호의 디바이스를 찾아 연결"""
        # 특정 시리얼 번호 디바이스를 찾도록 설정
        self.delegate.scanning_for_device = True
        self.delegate.target_serial = serial_number
        
        # 스캔 실행
        print(f"시리얼 번호 {serial_number}의 디바이스 검색 중...")
        devices = self.scan_beacons(scan_duration)
        
        # 타겟 디바이스 찾기
        target_addr = None
        for addr, device_info in devices.items():
            if device_info["serial"] == serial_number:
                target_addr = addr
                break
        
        if target_addr:
            return self.connect_to_device(target_addr)
        else:
            print(f"시리얼 번호 {serial_number}의 디바이스를 찾을 수 없음")
            return False
    
    def receive_temperature_data(self):
        """연결된 디바이스로부터 온도 데이터 수신"""
        if not self.connected or not self.peripheral:
            print("디바이스가 연결되어 있지 않음")
            return None
        
        # 서비스 및 특성 탐색
        try:
            services = self.peripheral.getServices()
            nus_service = None
            
            # NUS 서비스 찾기 (Nordic UART Service)
            for service in services:
                if service.uuid == UUID("6E400001-B5A3-F393-E0A9-E50E24DCCA9E"):
                    nus_service = service
                    break
            
            if nus_service:
                # TX 특성 찾기 (노르딕 관점에서 TX는 디바이스가 데이터를 전송하는 것)
                tx_char = nus_service.getCharacteristics(UUID("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"))[0]
                
                # RX 특성 찾기 (노르딕 관점에서 RX는 디바이스가 데이터를 수신하는 것)
                rx_char = nus_service.getCharacteristics(UUID("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"))[0]
                
                # TX 특성에 알림 활성화
                self.peripheral.writeCharacteristic(tx_char.valHandle + 1, b"\x01\x00")
                
                # 온도 데이터 요청 메시지 전송
                request_msg = bytes([0xD7, 0x11, 0x00, 0x00])  # TL_MSG_STX_RCV_TO_LGR, TL_CMD_REQUEST_TEMPERATURE
                rx_char.write(request_msg)
                
                print("온도 데이터 요청 전송됨. 응답 대기 중...")
                
                # 알림 대기
                if self.peripheral.waitForNotifications(10.0):
                    print("온도 데이터 수신됨!")
                    # 실제 데이터 처리는 handleNotification에서 수행
                    return True
                else:
                    print("10초 동안 응답 없음")
                    return False
            else:
                print("NUS 서비스를 찾을 수 없음")
                return False
                
        except Exception as e:
            print(f"온도 데이터 수신 중 오류: {e}")
            return False
    
    def start_scan_mode(self):
        """스캔 모드 시작 - 정기적으로 비콘 스캔"""
        try:
            while True:
                devices = self.scan_beacons(15)  # 15초 동안 스캔
                print(f"발견된 디바이스 수: {len(devices)}")
                for addr, device_info in devices.items():
                    print(f"디바이스: {addr}, 시리얼: {device_info['serial']}, RSSI: {device_info['rssi']}")
                
                print("10초 후 재스캔...")
                time.sleep(10)
        except KeyboardInterrupt:
            print("스캔 중단됨")

# NotificationDelegate 클래스 - 온도 데이터 알림 처리
class NotificationDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)
        self.temperature_data = []
        
    def handleNotification(self, cHandle, data):
        """온도 데이터 알림 처리"""
        print(f"알림 수신: 핸들 {cHandle}, 데이터 길이 {len(data)}")
        print(f"데이터: {binascii.hexlify(data).decode()}")
        
        # 온도 데이터 파싱
        try:
            # 데이터 형식에 따라 파싱 로직 구현
            # 예: 첫 바이트가 시퀀스 번호, 두 번째 바이트가 데이터 길이
            seq_num = data[0]
            data_len = data[1]
            
            # 온도 데이터 추출 예시 (실제 형식에 맞게 수정 필요)
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

def main():
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
            devices = receiver.scan_beacons()
            print(f"\n발견된 디바이스 수: {len(devices)}")
            for addr, device_info in devices.items():
                print(f"디바이스: {addr}, 시리얼: {device_info['serial']}, RSSI: {device_info['rssi']}")
        
        elif choice == "2":
            serial = int(input("연결할 디바이스의 시리얼 번호: "))
            receiver.find_and_connect_device(serial)
        
        elif choice == "3":
            receiver.receive_temperature_data()
        
        elif choice == "4":
            receiver.disconnect()
        
        elif choice == "5":
            receiver.start_scan_mode()
        
        elif choice == "0":
            receiver.disconnect()
            print("프로그램 종료")
            break

if __name__ == "__main__":
    main()