#!/usr/bin/env python3

import struct
import binascii
import time
import random
import sys
from bluez_peripheral.util import *
from bluez_peripheral.gatt.service import Service
# 변경 전:
# from bluez_peripheral.gatt.characteristic import Characteristic, CharacteristicFlags
# 변경 후 (예시):
from bluez_peripheral.gatt.characteristic import GattCharacteristic as Characteristic
from bluez_peripheral.gatt.characteristic import Flags as CharacteristicFlags

from bluez_peripheral.gatt.descriptor import Descriptor, DescriptorFlags
from bluez_peripheral.advert import Advertisement
from bluez_peripheral.agent import NoIoAgent
import logging

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("Temperature-Peripheral")

# BLE 관련 상수 정의
TL_UUID_APP_BEACON_UINT = 0x6C6E6A7D  # 비콘 UUID
APP_COMPANY_IDENTIFIER = 0x0059       # Nordic Semiconductor 식별자

# Nordic UART Service UUIDs
NUS_SERVICE_UUID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e'
NUS_RX_CHAR_UUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e'  # PC에서 데이터 수신 (Write)
NUS_TX_CHAR_UUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e'  # PC로 데이터 전송 (Notify)

# 현재 온도 데이터 (샘플)
current_temperature = 25.5

# 시리얼 번호 생성 (실제 구현에서는 고유한 값으로 설정해야 함)
def generate_serial_number():
    import uuid
    # MAC 주소를 기반으로 고유 ID 생성
    try:
        with open('/sys/class/net/wlan0/address', 'r') as f:
            mac = f.read().strip().replace(':', '')
        return int(mac[-8:], 16)  # MAC 주소의 마지막 8자리를 16진수로 변환
    except:
        # MAC 주소를 읽을 수 없는 경우 임의의 번호 생성
        logger.warning("MAC 주소를 읽을 수 없어 임의의 시리얼 번호를 생성합니다.")
        return int(uuid.uuid4().hex[-8:], 16)

SERIAL_NUMBER = generate_serial_number()

class NordicUARTService(Service):
    """Nordic UART Service 구현"""
    
    def __init__(self):
        super().__init__(NUS_SERVICE_UUID, True)
        self.tx_characteristic = None  # TX 특성 참조 저장
        
    def on_rx_write(self, data, options):
        """RX 특성에 데이터가 쓰여질 때 호출되는 콜백"""
        logger.info(f"RX 데이터 수신: {binascii.hexlify(data).decode()}")
        
        # 온도 요청 메시지 처리 (0xD7, 0x11, 0x00, 0x00)
        if len(data) >= 2 and data[0] == 0xD7 and data[1] == 0x11:
            logger.info('온도 데이터 요청 받음, 데이터 전송 시작')
            
            # 온도 데이터 전송
            self.send_temperature_data()
    
    def send_temperature_data(self):
        """온도 데이터를 TX 특성을 통해 전송"""
        global current_temperature
        
        # 온도를 int16으로 변환 (100을 곱해 소수점 2자리까지 저장)
        temp_int = int(current_temperature * 100)
        temp_bytes = struct.pack("<h", temp_int)
        
        # 시퀀스 번호: 0, 데이터 길이: 2(온도 데이터 바이트 수)
        data = bytearray([0, 2]) + temp_bytes
        
        logger.info(f'온도 데이터 전송: {current_temperature}°C')
        
        # TX 특성을 통해 알림 전송
        if self.tx_characteristic:
            self.tx_characteristic.notify(data)
        
        # 다음 온도값 변경 (실제 구현에서는 센서 값 사용)
        # 샘플 구현에서는 -0.5 ~ +0.5 사이의 변화를 줌
        current_temperature += random.uniform(-0.5, 0.5)
        current_temperature = round(current_temperature, 1)  # 소수점 첫째 자리까지
    
    def add_characteristics(self):
        """서비스에 특성들 추가"""
        # RX Characteristic - PC로부터 데이터 수신 (Write)
        rx_flags = [CharacteristicFlags.WRITE, CharacteristicFlags.WRITE_WITHOUT_RESPONSE]
        rx_char = Characteristic(NUS_RX_CHAR_UUID, rx_flags, self.on_rx_write)
        self.add_characteristic(rx_char)
        
        # TX Characteristic - PC로 데이터 전송 (Notify)
        tx_flags = [CharacteristicFlags.NOTIFY]
        tx_char = Characteristic(NUS_TX_CHAR_UUID, tx_flags)
        self.add_characteristic(tx_char)
        self.tx_characteristic = tx_char  # 참조 저장

def create_manufacturer_data():
    """비콘 UUID와 형식에 맞는 제조사별 데이터 생성"""
    # 형식: DeviceType(1) + DataLength(1) + UUID(4) + STX(1) + CMD(1) + 추가 데이터
    device_type = 0x02  # 예: 비콘
    data_length = 0x0D  # 데이터 길이 (13바이트: UUID(4) + 명령어(2) + 추가 데이터(7))
    uuid_bytes = struct.pack("<I", TL_UUID_APP_BEACON_UINT)
    stx = 0xD7  # 예시 STX 값
    cmd = 0x11  # 예시 CMD 값
    
    # 시리얼 번호와 기타 데이터
    serial_bytes = struct.pack("<I", SERIAL_NUMBER)
    extra_data = bytearray([0x00, 0x01, 0x00])  # 예시 추가 데이터
    
    return bytearray([device_type, data_length]) + uuid_bytes + bytearray([stx, cmd]) + serial_bytes + extra_data

def main():
    logger.info(f"시리얼 번호: {SERIAL_NUMBER}")
    
    # BLE 서비스 구성
    service = NordicUARTService()
    service.add_characteristics()
    
    # BLE 광고 설정
    advert = Advertisement("RPi-TemperatureLogger", [NUS_SERVICE_UUID])
    advert.include_tx_power = True
    
    # 제조사 데이터 설정
    manufacturer_data = create_manufacturer_data()
    advert.manufacturer_data = {APP_COMPANY_IDENTIFIER: manufacturer_data}
    
    # 에이전트 생성 (페어링 필요 없음)
    agent = NoIoAgent()
    
    # 광고 시작
    try:
        logger.info("BLE Peripheral 모드로 실행 중...")
        logger.info("종료하려면 Ctrl-C를 누르세요")
        
        # BLE 광고 시작
        with advert, service, agent:
            # 무한 루프로 실행
            while True:
                # 정기적으로 온도 데이터 갱신 (실제 구현에서는 센서에서 읽음)
                time.sleep(10)
                # 연결된 상태에서는 주기적으로 온도 데이터 전송 가능
                # (여기서는 요청 시에만 데이터 전송하도록 구현)
                
    except KeyboardInterrupt:
        logger.info("프로그램 종료됨")
    except Exception as e:
        logger.error(f"오류 발생: {e}")

if __name__ == "__main__":
    main()