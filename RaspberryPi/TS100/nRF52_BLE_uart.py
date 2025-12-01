import asyncio
from bleak import BleakClient, BleakScanner
import struct
import logging
import time

# Nordic UART Service UUID
UART_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
UART_RX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"  # Write
UART_TX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"  # Notify

# BLE Commands
CMD_LED = 0x01
CMD_STATUS = 0x02
CMD_LARGE_DATA = 0x03
CMD_DIAGNOSIS = 0x04
CMD_ADC = 0x05
CMD_UNKNOWN = 0xFF

DATA_START_PACKET = 0x10
DATA_CHUNK_PACKET = 0x11
DATA_END_PACKET = 0x12

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constants
DEVICE_NAME = "HKNU EE RTOS"

class BLEUARTTest:
    def __init__(self):
        self.client = None
        self.rx_characteristic = None
        self.tx_characteristic = None
        self.response_event = asyncio.Event()
        self.response_data = None
        self.data_buffer = bytearray()
        self.large_data_complete = False

    async def connect_device(self):
        logger.info("Scanning for device...")
        device = None
        retry_count = 0
        
        while retry_count < 3 and not device:
            try:
                device = await BleakScanner.find_device_by_filter(
                    lambda d, ad: d.name and d.name.lower() == DEVICE_NAME.lower(),
                )
                if device:
                    logger.info(f"Found device: {device.name}")
                    
                    # MTU 크기를 위한 특별한 설정
                    self.client = BleakClient(device, mtu_size=100)  # MTU 크기 지정
                    await self.client.connect(timeout=20.0)
                    logger.info("Connected to device")
                    logger.info(f"MTU size: {self.client.mtu_size}")
                    
                    await asyncio.sleep(0.1)  # MTU 설정을 위한 안정화 시간

                    # Get all services
                    services = self.client.services
                    logger.info("Available services:")
                    for service in services:
                         if service.uuid.lower() == UART_SERVICE_UUID.lower():
                            for char in service.characteristics:
                                if char.uuid.lower() == UART_RX_CHAR_UUID.lower():
                                    self.rx_characteristic = char
                                elif char.uuid.lower() == UART_TX_CHAR_UUID.lower():
                                    self.tx_characteristic = char
                    
                    if self.rx_characteristic and self.tx_characteristic:
                        logger.info("UART service found")
                        return
                    else:
                        raise Exception("UART characteristics not found")
                    
                retry_count += 1
                logger.info(f"Retry {retry_count}/3...")
                await asyncio.sleep(1)
                
            except Exception as e:
                retry_count += 1
                logger.error(f"Connection attempt {retry_count} failed: {e}")
                if retry_count < 3:
                    await asyncio.sleep(2)
                else:
                    raise Exception("Failed to connect after 3 attempts")

        if not device or not self.characteristic:
            raise Exception(f"Could not establish connection with device: {DEVICE_NAME}")

    def notification_handler(self, sender: int, data: bytearray):
        if len(data) == 0:
            return

        cmd_type = data[0]
        
        # Large Data 수신 처리
        if cmd_type == DATA_START_PACKET:
            self.data_buffer = bytearray()  # 새로운 데이터 수신 시작
            self.receiving_large_data = True
            data_length = (data[1] << 8) | data[2]  # 2바이트 길이 계산
            logger.info(f"Starting large data reception, expected size: {data_length} bytes")
            
        elif cmd_type == DATA_CHUNK_PACKET and self.receiving_large_data:
            chunk_data = data[1:]  # 첫 바이트(헤더)를 제외한 데이터
            self.data_buffer.extend(chunk_data)
            logger.info(f"Received chunk, size: {len(chunk_data)} bytes, "
                    f"Total received: {len(self.data_buffer)} bytes")
            
        elif cmd_type == DATA_END_PACKET and self.receiving_large_data:
            self.receiving_large_data = False
            logger.info(f"Large data reception complete. "
                    f"Total received: {len(self.data_buffer)} bytes")
            
            # 데이터 출력 (16진수 형태로)
            logger.info("Complete data (hex):")
            for i in range(0, len(self.data_buffer), 16):
                chunk = self.data_buffer[i:i+16]
                hex_str = ' '.join([f'{b:02X}' for b in chunk])
                ascii_str = ''.join([chr(b) if 32 <= b <= 126 else '.' for b in chunk])
                logger.info(f"{i:04X}: {hex_str:<48} {ascii_str}")
                
            self.response_data = self.data_buffer
            self.response_event.set()
        else:
            logger.info(f"Received data: {' '.join([f'{b:02X}' for b in data])}")
            if cmd_type in [CMD_LED, CMD_STATUS, CMD_ADC, CMD_DIAGNOSIS]:
                self.response_data = data
                self.response_event.set()

    async def send_command(self, command, data=None):
        """UART를 통해 명령 전송"""
        if data:
            message = bytes([command]) + data
        else:
            message = bytes([command])
        
        await self.client.write_gatt_char(self.rx_characteristic, message)

    async def send_command_and_wait(self, command, timeout=5.0):
        """명령을 보내고 응답을 기다림"""
        self.response_event.clear()
        self.response_data = None
        self.data_buffer.clear()
        self.large_data_complete = False
        
        await self.send_command(command)
        
        try:
            await asyncio.wait_for(self.response_event.wait(), timeout)
            if self.large_data_complete:
                return self.data_buffer
            else:
                return self.response_data
            
        except asyncio.TimeoutError:
            logger.error(f"Command {command:02X} timeout")
            return None

    async def test_led_control(self):
        """LED 제어 테스트"""
        logger.info("Testing LED control...")
        # LED ON
        await self.send_command(CMD_LED, bytes([0x01]))
        logger.info("LED turned ON")
        logger.info("Press Enter to turn it off...")
        input()
        # LED OFF
        await self.send_command(CMD_LED, bytes([0x00]))
        logger.info("LED turned OFF")

    async def test_system_status(self):
        """시스템 상태 테스트"""
        logger.info("Requesting system status...")
        response = await self.send_command_and_wait(CMD_STATUS)
        
        if response and response[0] == CMD_STATUS:
            logger.info(f"System status: {response[1]}")
        else:
            logger.error("Failed to get system status")

    async def test_large_data(self):
        """대용량 데이터 전송 테스트"""
        logger.info("Requesting large data transfer...")
        response = await self.send_command_and_wait(CMD_LARGE_DATA, timeout=30.0)
        
        if response:
            logger.info(f"Received large data, total size: {len(response)} bytes")
            # logger.info("Data preview (first 32 bytes):")
            # preview = response[:32]
            # for i in range(0, len(preview), 16):
            #     chunk = preview[i:i+16]
            #     hex_str = ' '.join([f'{b:02X}' for b in chunk])
            #     ascii_str = ''.join([chr(b) if 32 <= b <= 126 else '.' for b in chunk])
            #     logger.info(f"{i:04X}: {hex_str:<48} {ascii_str}")
        else:
            logger.error("Failed to receive large data")

    async def test_adc_data(self):
        """ADC 데이터 테스트"""
        logger.info("Requesting ADC data...")
        response = await self.send_command_and_wait(CMD_ADC)
        
        if response and response[0] == CMD_ADC:
            adc_value = (response[1] << 8) | response[2]
            logger.info(f"ADC value: {adc_value}")
        else:
            logger.error("Failed to get ADC data")

    async def run_interactive_tests(self):
        """대화형 테스트 실행"""
        try:
            print("\nBLE UART Device Testing Program")
            print("==============================")
            
            connected = False
            
            while True:
                print("\nAvailable commands:")
                if not connected:
                    print("0. Connect to device")
                else:
                    print("0. Disconnect device")
                    print("1. LED Control Test")
                    print("2. System Status Test")
                    print("3. Large Data Transfer Test")
                    print("4. ADC Data Test")
                print("q. Exit")
                
                choice = input("\nSelect a command: ")
                
                if not connected:
                    if choice == "0":
                        print("\nConnecting to device...")
                        try:
                            await self.connect_device()
                            await self.client.start_notify(
                                self.tx_characteristic,
                                self.notification_handler
                            )
                            connected = True
                            print("Device connected successfully!")
                        except Exception as e:
                            print(f"Connection failed: {e}")
                    elif choice == "q":
                        break
                    else:
                        print("Invalid choice. Please connect to device first.")
                else:
                    if choice == "0":
                        if self.client and self.client.is_connected:
                            await self.client.disconnect()
                            connected = False
                            print("Device disconnected successfully!")
                    elif choice == "1":
                        await self.test_led_control()
                    elif choice == "2":
                        await self.test_system_status()
                    elif choice == "3":
                        start = time.perf_counter()
                        await self.test_large_data()
                        end = time.perf_counter()
                        execution_time_ms = (end - start) * 1000
                        print(f"고해상도 타이머 측정 시간: {execution_time_ms:.3f} ms")
                    elif choice == "4":
                        await self.test_adc_data()
                    elif choice == "q":
                        break
                    else:
                        print("Invalid choice. Please try again.")
        
        finally:
            if self.client and self.client.is_connected:
                await self.client.disconnect()
                logger.info("Disconnected from device")

async def main():
    ble_test = BLEUARTTest()
    await ble_test.run_interactive_tests()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProgram terminated by user")
    except Exception as e:
        print(f"\nAn error occurred: {e}")