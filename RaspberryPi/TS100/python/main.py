import tkinter as tk
from tkinter import *

import asyncio

from bleak import BleakScanner, BleakClient

scan_frame = None
scroll_frame = None

def create_ui(root):
    global scan_frame
    global scroll_frame

    # UI 제목
    root.title("TS100-Project")

    # Bottom 프레임, Scan TS100, Temperature Information을 포함함
    bottom_frame = Frame(root)

    # Scan리스트 Frame
    scan_ts100_frame = LabelFrame(bottom_frame, relief="solid", bd=1, text="Scan TS100", width=115)
    scan_ts100_frame.grid(row=0, column=0, padx=5, pady=5, sticky="nsew")

    # 전역변수 할당
    scan_frame = scan_ts100_frame

    # 온도정보 Frame
    temperature_information_frame = LabelFrame(bottom_frame, relief="solid", bd=1, text="Temperature Information")
    canvas = Canvas(temperature_information_frame, borderwidth=0)
    scrollbar = Scrollbar(temperature_information_frame, orient="vertical", command=canvas.yview)
    scrollable_frame = Frame(canvas)

    # 전역변수 할당
    scroll_frame = scrollable_frame

    scrollable_frame.bind(
        "<Configure>",
        lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
    )

    canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
    canvas.configure(yscrollcommand=scrollbar.set)

    temperature_information_frame.grid(row=0, column=1, padx=5, pady=5, sticky="nsew")
    canvas.pack(side="left", fill="both", expand=True)
    scrollbar.pack(side="right", fill="y", expand=True)

    # Scan 버튼
    scan_button = Button(root, text="Scan", command=scan_button_click)
    scan_button.pack()

    # 하위 프레임
    bottom_frame.pack(side="bottom", fill="both", expand=True)

'''
    Scan
'''

# 스캔된 버튼을 담고있는 배열
scan_devices_list = []

def remove_button(button_name=None):
    if button_name is not None:
        if not scan_devices_list:
            return

        remove_button = None
        for device in scan_devices_list:
            if device.cget("text") == button_name:
                remove_button = device
                break
        
        if remove_button:
            root.after(0, remove_button.destroy)
            scan_devices_list.remove(remove_button)
        return

    # 기존에 scan했던 기기 화면에서 제거
    for button in scan_devices_list:
        root.after(0, button.destroy)
        scan_devices_list.remove(button)

def create_scan_devices(ts100_scan_list):
    global scan_devices_list

    # Scan했던 Device 버튼 생성
    for device in ts100_scan_list:
        button = Button(scan_frame, text=device.name, command=lambda device=device: scan_device_button_click(device))
        button.pack()
        scan_devices_list.append(button)

def scan_button_click():
    remove_button()

    # 이벤트루프 생성해 BLE 기기 scan
    loop = asyncio.get_event_loop()
    ts100_scan_list = loop.run_until_complete(scan())

    create_scan_devices(ts100_scan_list)

async def scan():
    ts100_device = []

    print('Scan Start')
    # scan start
    scan_devices = await BleakScanner.discover()
    print('Scan End')

    for device in scan_devices:
        device_name = device.name if device.name else "Unknown Device"
        if "TS100" in device_name:
            ts100_device.append(device)
            print(device_name)
    
    return ts100_device

def scan_device_button_click(device):
    print("Selected Device: " + device.name)

    loop = asyncio.get_event_loop()
    loop.run_until_complete(connect(device))

'''
    Connect
''' 

# dictionary 선언(key: device_name, value: device_text_frame)
device_info_frame_dict = {}


async def connect(candidate_device):
    print('connect start')

    selected_client = BleakClient(candidate_device)

    try:
        # 장치 연결 시작
        await selected_client.connect()
        print('connected')

        # Characteristic, Service 요청
        await get_service_and_characteristic(candidate_device, selected_client)

        # scan_ts100에서 연결된 기기 삭제
        root.after(0, remove_button, candidate_device.name)
        # info 화면에 추가
        root.after(0, create_device_info_frame, candidate_device, selected_client)

    except Exception as e:
        # 연결 실패시 발생
        print('error: ', e, end='')
        return None

# 연결된 기기 Frame을 생성하는 함수
def create_device_info_frame(device, ble_client):
    global scroll_frame
    global device_info_frame_dict
    global sender_dict

    # Device 영역 제거
    def remove_frame():
        # 프레임에서 삭제
        frame.destroy()

        # BLE 연결 해제
        loop = asyncio.get_event_loop()
        loop.run_until_complete(ble_client.disconnect())

        # dictionary 삭제
        del device_info_frame_dict[device.name]
        remove_characteristic_by_value(device.name)

    # value값으로 dictionary 값 삭제하는 함수
    def remove_characteristic_by_value(name):
        keys_to_remove = [key for key, value in sender_dict.items() if value == name]
        for key in keys_to_remove:
            del sender_dict[key]

    frame = Frame(scroll_frame, relief="solid", bd=1, padx=5, pady=5)
    frame.pack()

    # TitleFrame: 좌측 상단에 제목이 표시되는 프레임
    title_frame = Frame(frame, padx=5, pady=5)
    title_label = Label(title_frame, text=device.name, font=("Helvetica", 14))
    title_label.pack(side="left")

    # NotifyStartFrame: 우측 상단에 notify를 시작하는 버튼이 표시되는 프레임
    remove_button_frame = Frame(frame, padx=5, pady=5)
    remove_button = Button(remove_button_frame, text="X", command=remove_frame, bg="red", fg="white")
    remove_button.pack()

    # ContentFrame: 하단에 내용을 보여주는 프레임
    content_frame = Frame(frame, padx=10, pady=10)
    content_label_text = StringVar()
    content_label = Label(content_frame, textvariable=content_label_text, font=("Helvetica", 14))
    content_label_text.set("Connect")
    content_label.pack(side="bottom")

    # 배치
    title_frame.grid(row=0, column=0, sticky="ew")
    remove_button_frame.grid(row=0, column=1, sticky="e")
    content_frame.grid(row=1, column=0, columnspan=2, sticky="nsew")

    # 그리드 가중치 설정 (윈도우 크기 조절에 대응하기 위해)
    scroll_frame.grid_rowconfigure(1, weight=1)
    scroll_frame.grid_columnconfigure(0, weight=1)

    # dictionary에 추가
    device_info_frame_dict[device.name] = content_label_text

'''
    notify
'''

health_thermometer_service = '00001809-0000-1000-8000-00805f9b34fb'

temperature_characteristic = '00002a1c-0000-1000-8000-00805f9b34fb'

# dictionary 선언(key: characteristic, value: device_name)
sender_dict = {}

# Service, Characteristic 요청하는 함수
async def get_service_and_characteristic(candidate_device, connected_device):
    # Service 확인
    for service in connected_device.services:
        # Health Thermometer 관련 Service일때만 Characteristic 검색
        if service.uuid == health_thermometer_service:
            for characteristic in service.characteristics:
                # 온도정보 notify 설정
                if characteristic.uuid == temperature_characteristic:
                    # Dictionary에 추가
                    if characteristic not in sender_dict:
                        sender_dict[characteristic] = candidate_device.name
                    await connected_device.start_notify(characteristic, notify_callback)

# notify를 수신했을 때 호출되는 함수
def notify_callback(handle, data):
    temperature = parse_temperature_information(data)

    # 수신된 기기 이름 확인
    device_name = sender_dict.get(handle)

    if device_name is None:
        return
    
    # 업데이트할 텍스트 영역 확인 후 업데이트
    string_var = device_info_frame_dict.get(device_name)

    if string_var is None:
        return

    string_var.set(f"{temperature}°C")

# 온도정보 변환
def parse_temperature_information(data: bytearray):
    # 온도정보 변환
    temperature = temperature_calculate(data[1], data[2], data[3], data[4])

    # 온도정보 출력
    print(temperature)

    return temperature

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

if __name__ == "__main__":
    # root = tk.Tk()

    # create_ui(root)

    # 이벤트루프 생성
    loop = asyncio.get_event_loop()

    # 비동기로 UI 계속 업데이트
    def asyncio_loop():
        loop.call_soon(loop.stop)
        loop.run_forever()
        root.after(100, asyncio_loop)

    root.after(100, asyncio_loop)
    root.mainloop()