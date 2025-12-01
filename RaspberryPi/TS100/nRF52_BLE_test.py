import asyncio
from bleak import BleakClient, BleakScanner
import struct
import logging
import time

# Constants
DEVICE_NAME = "HKNU EE FreeRTOS"
DATA_SERVICE_UUID = "0000180f-0000-1000-8000-00805f9b34fb"
DATA_CHAR_UUID = "00002a19-0000-1000-8000-00805f9b34fb"

# BLE Commands
CMD_LED = 0x01         # LED 제어 명령. LED의 상태를 제어합니다.
CMD_STATUS = 0x02      # 시스템 상태 요청. 현재 시스템 상태를 전송합니다.
CMD_LARGE_DATA = 0x03  # 대용량 데이터 전송 요청. 테스트 데이터의 큰 버퍼를 전송합니다.
CMD_DIAGNOSIS = 0x04   # 시스템 진단 데이터 요청. 진단 정보를 전송합니다.
CMD_ADC = 0x05         # ADC
CMD_DATA_START = 0x10  # Large data start packet
CMD_DATA_CHUNK = 0x11  # Large data chunk
CMD_DATA_END = 0x12    # Large data end chunk
CMD_UNKNOWN = 0xFF     # Unknown command

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constants
DEVICE_NAME = "HKNU EE FreeRTOS"

# Convert 16-bit UUID to 128-bit UUID
def short_uuid_to_full(uuid16):
    """Convert 16-bit UUID to full 128-bit UUID"""
    # BLE base UUID: 00000000-0000-1000-8000-00805F9B34FB
    return f"0000{uuid16}-0000-1000-8000-00805f9b34fb"

    # Full UUIDs
    DATA_SERVICE_UUID = short_uuid_to_full("180F")
    DATA_CHAR_UUID = short_uuid_to_full("2A19")

class BLETest:
    def __init__(self):
        self.client = None
        self.characteristic = None
        self.response_event = asyncio.Event()
        self.response_data = None
        self.receiving_large_data = False
        self.large_data_buffer = bytearray()
        self.expected_data_size = 0

    async def connect_device(self):
        logger.info("Scanning for device...")
        device = None
        retry_count = 0
        
        while retry_count < 3 and not device:
            try:
                device = await BleakScanner.find_device_by_filter(
                    lambda d, ad: d.name and d.name.lower() == DEVICE_NAME.lower()
                )
                if device:
                    logger.info(f"Found device: {device.name}")
                    self.client = BleakClient(device)
                    await self.client.connect(timeout=20.0)
                    logger.info("Connected to device")

                    # Get all services
                    services = await self.client.get_services()
                    logger.info("Available services:")
                    for service in services:
                        logger.info(f"Service: {service.uuid}")
                        for char in service.characteristics:
                            logger.info(f"  Characteristic: {char.uuid}")
                            if DATA_CHAR_UUID.lower() == char.uuid.lower():
                                self.characteristic = char
                                logger.info(f"Found target characteristic: {char.uuid}")
                                return  # 성공적으로 연결되면 함수 종료

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
        """Handle incoming notifications from the device"""
        if len(data) == 0:
            return

        cmd_type = data[0]
        
        if cmd_type == CMD_DATA_START:  # Large data start packet
            self.receiving_large_data = True
            self.large_data_buffer.clear()
            self.expected_data_size = struct.unpack(">I", data[1:5])[0]
            logger.info(f"Starting large data transfer, expected size: {self.expected_data_size}")
        
        elif cmd_type == CMD_DATA_CHUNK:
            if self.receiving_large_data:
                    chunk_data = data[2:]
                    self.large_data_buffer.extend(chunk_data)
                    # 로깅 줄이기
                    if len(self.large_data_buffer) % 1000 == 0:
                        logger.info(f"Received: {len(self.large_data_buffer)} bytes")

        elif cmd_type == CMD_DATA_CHUNK:  # Large data chunk
            if self.receiving_large_data:
                chunk_index = data[1]
                chunk_data = data[2:]
                self.large_data_buffer.extend(chunk_data)
                logger.info(f"Chunk {chunk_index} data: " +
                        ' '.join([f'{b:02X}' for b in chunk_data]))
                logger.info(f"Total received: {len(self.large_data_buffer)} bytes")
        
        elif cmd_type == CMD_DATA_END:  # Large data end
            self.receiving_large_data = False
            logger.info("Large data transfer complete")
            logger.info(f"Total received: {len(self.large_data_buffer)} bytes")
            logger.info("Complete data (hex):")
            for i in range(0, len(self.large_data_buffer), 16):
                chunk = self.large_data_buffer[i:i+16]
                hex_str = ' '.join([f'{b:02X}' for b in chunk])
                ascii_str = ''.join([chr(b) if 32 <= b <= 126 else '.' for b in chunk])
                logger.info(f"{i:04X}: {hex_str:<48} {ascii_str}")
        else:
            # 일반 응답 처리
            self.response_data = data
            self.response_event.set()  # 응답이 도착했음을 알림

    async def send_command_and_wait(self, command, timeout=5.0):
        """명령을 보내고 응답을 기다립니다"""
        self.response_event.clear()
        self.response_data = None
        
        # 명령 전송
        await self.client.write_gatt_char(self.characteristic.uuid, bytes([command]))
        
        # 응답 대기
        try:
            await asyncio.wait_for(self.response_event.wait(), timeout)
            return self.response_data
        except asyncio.TimeoutError:
            logger.error(f"Command {command:02X} timeout")
            return None

    async def test_led_control(self):
        """Test LED control command"""
        logger.info("Testing LED control...")
        # LED ON
        await self.client.write_gatt_char(self.characteristic.uuid, bytes([CMD_LED, 0x01]))
        logger.info("LED turned ON.");
        logger.info("Press Enter to turn it off...")
        input()
        # LED OFF
        await self.client.write_gatt_char(self.characteristic.uuid, bytes([CMD_LED, 0x00]))
        logger.info("LED turned OFF")

    async def test_system_status(self):
        """Test system status request"""
        logger.info("Requesting system status...")
        response = await self.send_command_and_wait(CMD_STATUS)
        
        if response and response[0] == CMD_STATUS:
            logger.info(f"System status: {response[1]}")
        else:
            logger.error("Failed to get system status")

    async def test_large_data(self):
        """Test large data transfer"""
        logger.info("Requesting large data transfer...")
        self.large_data_buffer.clear()
        self.receiving_large_data = False
        
        await self.client.write_gatt_char(self.characteristic.uuid, bytes([CMD_LARGE_DATA]))
        
        timeout = 30  # 30초 타임아웃
        start_time = time.time()
        
        while True:
            if time.time() - start_time > timeout:
                logger.error("Large data transfer timeout")
                break
            
            if len(self.large_data_buffer) > 0 and not self.receiving_large_data:
                logger.info(f"Transfer complete. Total bytes received: {len(self.large_data_buffer)}")
                break
                
            await asyncio.sleep(0.1)

    async def test_diagnostic_data(self):
        """Test diagnostic data request"""
        logger.info("Requesting diagnostic data...")
        response = await self.send_command_and_wait(CMD_DIAGNOSIS)
        
        if response and response[0] == CMD_DIAGNOSIS:
            logger.info(f"Diagnostic data - \nTransfer status: {response[1]}, "
                    f"\nCurrent chunk: {response[2]}, "
                    f"\nData length: {(response[3] << 8) | response[4]}")
        else:
            logger.error("Failed to get diagnostic data")

    async def test_adc_data(self):
        """Test ADC data request"""
        logger.info("Requesting ADC data...")
        response = await self.send_command_and_wait(CMD_ADC)
        
        if response and response[0] == CMD_ADC:
            adc_value = (response[1] << 8) | response[2]
            logger.info(f"ADC value: {adc_value}")
        else:
            logger.error("Failed to get ADC data")

    async def run_interactive_tests(self):
        """Run tests interactively"""
        try:
            print("\nBLE Device Testing Program")
            print("=========================")
            
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
                    print("4. Diagnostic Data Test")
                    print("5. ADC Data Test")
                print("q. Exit")
                
                choice = input("\nSelect a command: ")
                
                if not connected:
                    if choice == "0":
                        print("\nConnecting to device...")
                        try:
                            await self.connect_device()
                            await self.client.start_notify(self.characteristic.uuid, self.notification_handler)
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
                        await self.test_large_data()
                        input("Press Enter to continue...")
                    elif choice == "4":
                        await self.test_diagnostic_data()
                    elif choice == "5":
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
    ble_test = BLETest()
    await ble_test.run_interactive_tests()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProgram terminated by user")
    except Exception as e:
        print(f"\nAn error occurred: {e}")