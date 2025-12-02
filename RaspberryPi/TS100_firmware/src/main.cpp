/**
 * @file main.cpp
 * @brief TS100 Banana Thermometer Simulator
 * @details BLE compatible thermometer simulator for Arduino boards
 * 
 * @author SC Kim <firmware@gmail.com>
 * @date 2024.11.18
 * 
 * @note Tested on Arduino Nano 33 IoT
 * @note Requires Arduino BLE compatible board
 */

#include <ArduinoBLE.h>

// 서비스와 특성 UUID 정의
#define HEALTH_THERMOMETER_SERVICE "00001809-0000-1000-8000-00805f9b34fb"
#define DATE_TIME_CHARACTERISTIC "00002a08-0000-1000-8000-00805f9b34fb"
#define TEMPERATURE_CHARACTERISTIC "00002a1c-0000-1000-8000-00805f9b34fb"

// BLE 서비스와 특성 생성
BLEService healthService(HEALTH_THERMOMETER_SERVICE);
BLECharacteristic dateTimeChar(DATE_TIME_CHARACTERISTIC, BLERead | BLEWrite, 7);        // 7바이트: YYYY(2) MM(1) DD(1) HH(1) MM(1) SS(1)
BLECharacteristic temperatureChar(TEMPERATURE_CHARACTERISTIC, BLERead | BLENotify, 12); // 온도(4) + 날짜시간(7)

// 날짜/시간 저장 구조체
struct DateTime
{
    uint16_t year;
    uint8_t month;
    uint8_t day;
    uint8_t hours;
    uint8_t minutes;
    uint8_t seconds;
} currentDateTime;

unsigned long lastTempUpdate = 0;
const long tempUpdateInterval = 1000; // 1초마다 온도 업데이트

// MAC 주소에서 고유 ID를 생성하는 함수
String generateUniqueId() {
     String address = BLE.address();
    // MAC 주소의 마지막 4자리만 추출
    String uniqueId = address.substring(address.length() - 5);
    // 콜론(:) 제거
    uniqueId.replace(":", "");
    return uniqueId;
}

// 온도 측정 함수 (실제 센서 사용 시 이 부분을 수정)
float measureTemperature()
{
    // 테스트를 위한 가상의 온도 데이터 생성 (35.5 ~ 37.5도 사이)
    return 35.5 + (float)random(0, 20) / 10.0;
}

// 날짜/시간 수신 콜백 함수
void onDateTimeReceived(BLEDevice central, BLECharacteristic characteristic)
{
    uint8_t dateTimeData[7];
    characteristic.readValue(dateTimeData, 7);

    // 수신된 날짜/시간 데이터 파싱
    currentDateTime.year = (dateTimeData[1] << 8) | dateTimeData[0];
    currentDateTime.month = dateTimeData[2];
    currentDateTime.day = dateTimeData[3];
    currentDateTime.hours = dateTimeData[4];
    currentDateTime.minutes = dateTimeData[5];
    currentDateTime.seconds = dateTimeData[6];
}

// 온도와 날짜/시간 데이터 전송
void sendTemperatureData()
{
    float temperature = measureTemperature();

    uint8_t tempData[12]; // 온도(5) + 날짜시간(7)

    // 온도 데이터 (5바이트)
    int32_t tempInt = (int32_t)(temperature * 100); // 소수점 2자리까지 보존
    tempData[0] = 0;                                // Reserved byte
    tempData[1] = tempInt & 0xFF;                   // 하위 바이트
    tempData[2] = (tempInt >> 8) & 0xFF;           // 중간 바이트
    tempData[3] = (tempInt >> 16) & 0xFF;          // 상위 바이트
    tempData[4] = 0xFE;                            // 지수 값 (-2: 10^-2를 의미하므로 0xFE로 표현)

    // 날짜/시간 데이터 (7바이트)
    tempData[5] = currentDateTime.year & 0xFF;         // 년도 하위 8비트
    tempData[6] = (currentDateTime.year >> 8) & 0xFF;  // 년도 상위 8비트
    tempData[7] = currentDateTime.month;
    tempData[8] = currentDateTime.day;
    tempData[9] = currentDateTime.hours;
    tempData[10] = currentDateTime.minutes;
    tempData[11] = currentDateTime.seconds;

    // 데이터 전송
    if (temperatureChar.writeValue(tempData, sizeof(tempData)))
    {
        Serial.print("Temperature sent: ");
        Serial.print(temperature, 1);
        Serial.print("°C at ");

        // 년도 출력
        if (currentDateTime.year < 1000)
            Serial.print("0");
        if (currentDateTime.year < 100)
            Serial.print("0");
        if (currentDateTime.year < 10)
            Serial.print("0");
        Serial.print(currentDateTime.year);
        Serial.print("-");

        // 월 출력
        if (currentDateTime.month < 10)
            Serial.print("0");
        Serial.print(currentDateTime.month);
        Serial.print("-");

        // 일 출력
        if (currentDateTime.day < 10)
            Serial.print("0");
        Serial.print(currentDateTime.day);
        Serial.print(" ");

        // 시간 출력
        if (currentDateTime.hours < 10)
            Serial.print("0");
        Serial.print(currentDateTime.hours);
        Serial.print(":");

        // 분 출력
        if (currentDateTime.minutes < 10)
            Serial.print("0");
        Serial.print(currentDateTime.minutes);
        Serial.print(":");

        // 초 출력
        if (currentDateTime.seconds < 10)
            Serial.print("0");
        Serial.print(currentDateTime.seconds);
        Serial.println();
    }
}

void setup()
{
    Serial.begin(115200);
    while (!Serial)
        delay(10);

    Serial.println("BLE Temperature Sensor");

    // BLE 초기화
    if (!BLE.begin())
    {
        Serial.println("BLE initialization failed!");
        while (1)
            ;
    }

    // 고유한 디바이스 이름 생성
    String uniqueId = generateUniqueId();
    String deviceName = "TS100-" + uniqueId;
    
    // 디바이스 이름 설정
    BLE.setLocalName(deviceName.c_str());
    BLE.setDeviceName(deviceName.c_str());

    Serial.print("Device Name: ");
    Serial.println(deviceName);

    // 서비스에 특성 추가
    healthService.addCharacteristic(dateTimeChar);
    healthService.addCharacteristic(temperatureChar);

    // 서비스 추가
    BLE.addService(healthService);

    // 콜백 설정
    dateTimeChar.setEventHandler(BLEWritten, onDateTimeReceived);

    // 광고 시작
    BLE.setAdvertisedService(healthService);
    BLE.advertise();

    Serial.println("Bluetooth device active, waiting for connections...");

    // 초기 날짜/시간 설정
    currentDateTime = {2024, 1, 1, 0, 0, 0};

    // 난수 생성기 초기화
    randomSeed(analogRead(0));
}

void loop()
{
    BLE.poll();

    if (BLE.connected())
    {
        unsigned long currentMillis = millis();
        if (currentMillis - lastTempUpdate >= tempUpdateInterval)
        {
            lastTempUpdate = currentMillis;
            sendTemperatureData();
        }
    }
}