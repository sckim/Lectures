import asyncio # 비동기화 모듈
from typing import Optional # 타입 어노테이션 관련 모듈

from bleak import BleakScanner, BleakClient, BleakGATTCharacteristic # BLE 관련 모듈
from bleak import BleakClient

import tkinter as tk # GUI 라이브러리

# 날짜정보 변환하기 위해 사용하는 라이브러리
from datetime import datetime

import sqlite3

# 그래프 관련 라이브러리
import matplotlib.pyplot as plt

# 비동기 형태로 BLE 장치 검색
async def scan():
    ts100_device = []

    print('Scan Start')
    # scan start
    scan_devices = await BleakScanner.discover()
    print('Scan End')

    # 스캔된 device 탐색
    for device in scan_devices:
        # 이름이 없는 Device "Unknown Device로 변경"
        device_name = device.name if device.name else "Unknown Device"
        # 이름에 TS100을 포함하면 콘솔에 출력
        if "TS100" in device_name:
            ts100_device.append(device)
            print(device_name)
    
    return ts100_device
# GUI로 화면에 나타내는 함수
def show_scan_devices(devices):
    if not devices:
        return False

    window = tk.Tk()
    # 화면 제목
    window.title("TS100 Scan List")

    buttons = []
    for device in devices:
        text = device.name
        # 버튼 이벤트 추가(button_click 함수 호출)
        button = tk.Button(window, text=text, command=lambda device=device: button_click(device, window))
        button.pack()
        buttons.append(button)

    # 윈도우 종료까지 실행
    window.mainloop()
def button_click(device, window):
    global selected_device # 전역변수 함수내 사용하도록 설정
    selected_device = device # 선택한 Device selected_device 변수에 담기

    # remove gui
    window.quit()

# 선택한 TS100에 연결하는 함수
async def connect(candidate_device):
    print('connect start')

    selected_client = BleakClient(candidate_device)

    try:
        # 장치 연결 시작
        await selected_client.connect()
        print('connected')
    except Exception as e:
        # 연결 실패시 발생
        print('error: ', e, end='')
        return None

    return selected_client

# Service, Charactristic 확인하는 함수
async def get_service_and_characteristic(connected_device):
    global health_thermometer_service

    # Service 확인(제대로 연결되었는지 테스트용)
    for service in connected_device.services:
        # Health Thermometer 관련 Service일때만 Characteristic 검색
        if service.uuid == health_thermometer_service:
            for characteristic in service.characteristics:
                # 날짜정보 Update(추가된 부분)
                if characteristic.uuid == date_time_characteristic:
                    await connected_device.write_gatt_char(characteristic, current_date())

                # 온도정보 notify 설정
                if characteristic.uuid == temperature_characteristic:
                    await connected_device.start_notify(characteristic, notify_callback)

# notify를 수신했을 때 호출되는 함수
def notify_callback(handle, data):
    parse_temperature_information(data)

# 온도정보 변환
def parse_temperature_information(data: bytearray):
    global cursor

    # 온도정보 변환
    temperature = temperature_calculate(data[1], data[2], data[3], data[4])

    array_slice = data[5:]
    date_array = list(map(int, array_slice))
    # 날짜정보 변환
    date = date_calculate(date_array)
    # 온도, 날짜정보 출력
    print(date)
    print(temperature)

    # 데이터베이스에 저장(추가된 부분)
    cursor.execute("INSERT INTO TEMPERATURE (date, temperature) VALUES (?, ?)", (date, temperature))
    conn.commit()

    # 배열에 값 추가
    temperature_list.append(temperature)


    # 20개의 데이터만 graph_temperature_data 배열에 담을 수 있도록 설정
    graph_temperature_data = temperature_list
    if len(temperature_list) > 20:
        graph_temperature_data = temperature_list[-20:]

    # 그래프 그리기
    line_chart[0].set_data(range(len(graph_temperature_data)), graph_temperature_data)
    plt.pause(1)

# 온도정보 계산하는 함수
def temperature_calculate(t1, t2, t3, d):
    # Int로 변환, 비트 시프트 후 합산
    int_t1 = int(t1)
    int_t2 = int(t2) << 8
    int_t3 = int(t3) << 16

    signed_value = int_t1 + int_t2 + int_t3

    # 자릿수 정하는 변수
    digit = int(d)
    if digit > 127:
        digit -= 256

    # 온도
    temperature = float(signed_value) * 10 ** digit
    # 소수점 1자리만 남도록 수정
    temperature = round(temperature * 10) / 10

    return temperature

# 날짜정보 계산하는 함수
def date_calculate(array):
    year = (array[1] & 0x0F) << 8 | (array[0] & 0x00FF)
    month = array[2]
    day = array[3]
    hour = array[4]
    minute = array[5]
    second = array[6]

    date_component = datetime(year, month, day, hour, minute, second)

    return date_component

# 현재 시간을 리턴하는 메서드(byte 타입)
def current_date():
    current_datetime = datetime.now()

    year = current_datetime.year
    month = current_datetime.month
    day = current_datetime.day
    hour = current_datetime.hour
    minute = current_datetime.minute
    second = current_datetime.second

    result = [
        year & 0xFF,
        (year >> 8) & 0xFF,
        month & 0xFF,
        day & 0xFF,
        hour & 0xFF,
        minute & 0xFF,
        second & 0xFF
    ]

    return bytes(result)

# 그래프 설정하는 함수
def set_graph():
    global line_chart
    # Set Graph
    plt.ion()  # Activate interactive mode
    fig, ax = plt.subplots()
    line = ax.plot([], [], label='Temperature', marker='o', lw=1)
    ax.set_ylim(20, 40)
    ax.set_xlim(0, 20)
    ax.set_ylabel('Temperature (°C)')
    ax.legend()

    # 전역변수에 차트정보 설정
    line_chart = line

# 이벤트루프 종료를 방지하기위한 함수
async def wait_connect():
    while connected_device.is_connected:
        await asyncio.sleep(1)

# Global variabales
# ------
selected_device = None

# Service, Characteristic
health_thermometer_service = '00001809-0000-1000-8000-00805f9b34fb'
date_time_characteristic = '00002a08-0000-1000-8000-00805f9b34fb'
temperature_characteristic = '00002a1c-0000-1000-8000-00805f9b34fb'

temperature_list = []

line_chart = None

# 데이터베이스 객체 생성(temperature.db 파일 생성됨)
conn = sqlite3.connect("temperature.db")
# SQL 동작을 위해 cursor 오브젝트 생성
cursor = conn.cursor()

connected_device = None

if __name__ == '__main__':
    # 테이블 생성(한번만 실행되도록 try-catch 이용)
    try:
        cursor.execute("CREATE TABLE TEMPERATURE(date datetime, temperature double)")
    except:
        # 이미 테이블이 실행되었다면 아래 구문 콘솔 출력
        print("database already created")
        
    # 비동기 이벤트 루프 생성
    loop = asyncio.get_event_loop()
    # 비동기 형태로 Scan함수 실행
    scan_devices = loop.run_until_complete(scan())
    # Scan된 기기 화면으로 출력
    show_scan_devices(scan_devices)

    # 선택한 기기가 None이 아니라면
    if selected_device is not None:
        # connect 요청 후 함수가 끝날때까지 기다림
        connected_device = loop.run_until_complete(connect(selected_device))

    # 그래프 설정 함수
    set_graph()

    # TS100과 연결되어 있다면
    if connected_device is not None:
        # Service, Characteristic 출력하는 함수 호출
        loop.run_until_complete(get_service_and_characteristic(connected_device))

    # 종료 방지함수 호출
    loop.run_until_complete(wait_connect())