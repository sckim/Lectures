#include <Adafruit_TinyUSB.h>
#include <bluefruit.h>

#define DEBUG_SERIAL Serial

// BLE UART 서비스 객체 생성
BLEUart bleuart;

// ECG 관련 정의
#define ECG_SERVICE_UUID "12345678-1234-5678-1234-56789abcdef0"        
#define ECG_CHARACTERISTIC_UUID "12345678-1234-5678-1234-56789abcdef1" 

BLEService BLE_UART(ECG_SERVICE_UUID);
BLECharacteristic BLE_UART_Data(ECG_CHARACTERISTIC_UUID);
#define MAX_CHUNK_SIZE 20

void connect_callback(uint16_t conn_handle)
{
    Serial.println("Connected");
    Serial.print("Conn handle: ");
    Serial.println(conn_handle);
}

void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
    (void)conn_handle;
    (void)reason;

    Serial.println("Disconnected");
    Serial.println("Advertising will restart...");
}

void setup()
{
    // 디버그용 시리얼 초기화
    DEBUG_SERIAL.begin(115200);

    // BLE 초기화
    Bluefruit.begin();
    Bluefruit.setName("BLE UART");
    Bluefruit.setTxPower(4);

    // 콜백 설정
    Bluefruit.Periph.setConnectCallback(connect_callback);
    Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

    // ECG 서비스 설정
    BLE_UART.begin();
    
    // BLE UART 서비스 시작
    bleuart.begin();

    // ECG 특성 설정
    BLE_UART_Data.setProperties(CHR_PROPS_NOTIFY | CHR_PROPS_READ);
    BLE_UART_Data.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
    BLE_UART_Data.setMaxLen(MAX_CHUNK_SIZE);
    BLE_UART_Data.begin();

    // 광고 설정
    Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
    Bluefruit.Advertising.addTxPower();
    Bluefruit.Advertising.addService(bleuart);  // UART 서비스 광고에 추가
    Bluefruit.Advertising.addService(BLE_UART);
    Bluefruit.Advertising.addName();

    // 광고 시작
    Bluefruit.Advertising.restartOnDisconnect(true);
    Bluefruit.Advertising.setInterval(32, 244);
    Bluefruit.Advertising.setFastTimeout(30);
    Bluefruit.Advertising.start(0);

    Serial.println("BLE advertising with UART Service...");
}

void loop()
{
    if (Bluefruit.connected())
    {
        // Arduino IDE에서 입력받은 데이터를 BLE UART로 전송
        if (DEBUG_SERIAL.available())
        {
            char receivedChar = DEBUG_SERIAL.read();
            bleuart.write(receivedChar);
            DEBUG_SERIAL.write(receivedChar);  // echo
        }
        
        // BLE UART로부터 받은 데이터를 Arduino IDE로 출력
        if (bleuart.available())
        {
            char receivedChar = bleuart.read();
            DEBUG_SERIAL.write(receivedChar);
        }
    }
    delay(1);
}