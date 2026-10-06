#!/usr/bin/env python3
"""remote_button.py : 실습 9-8 (선택)  Python pigpio 클라이언트로 버튼 콜백 받기

회로 : 버튼 GPIO26 (물리 핀 37) - GND, LED GPIO17 (물리 핀 11) - 330 Ω - LED - GND
준비 : Pi에서  sudo systemctl start pigpiod
       원격 접속이면 Pi의 데몬이 원격을 허용해야 한다 (8장 8.6절, 기본 서비스는 -l)
설치 : Pi:  sudo apt install python3-pigpio
       PC:  pip install pigpio   (가상환경 권장)
실행 : python3 remote_button.py                 같은 Pi에서 (sudo 불필요)
       python3 remote_button.py 192.168.0.xx    다른 PC에서 원격으로

원본 : Raspberry Pi Codes §7.4.3 button_counter.py (GPIO21, 풀다운, 상승 에지)를
       교재 배선(GPIO26, 풀업, 하강 에지)으로 바꾸고 glitch 필터와 tick 간격을 더했다.
"""
import sys
import time

import pigpio

LED = 17
BUTTON = 26

host = sys.argv[1] if len(sys.argv) > 1 else "localhost"
pi = pigpio.pi(host)                     # 데몬에 소켓(8888)으로 접속
if not pi.connected:
    print(f"{host}의 pigpiod에 접속할 수 없다. 데몬 실행·원격 허용 여부를 확인하라.")
    sys.exit(1)

count = 0
last_tick = None


def on_press(gpio, level, tick):
    """pigpio 모듈의 콜백 스레드에서 불린다. tick은 Pi에서 찍힌 us 시각이다."""
    global count, last_tick
    count += 1
    pi.write(LED, count & 1)             # 누를 때마다 LED 반전
    if last_tick is None:
        print(f"눌림 {count}회")
    else:
        gap = pigpio.tickDiff(last_tick, tick)   # 랩어라운드를 고려한 차이
        print(f"눌림 {count}회 (직전과 {gap / 1e6:.3f}초 간격)")
    last_tick = tick


pi.set_mode(LED, pigpio.OUTPUT)
pi.set_mode(BUTTON, pigpio.INPUT)
pi.set_pull_up_down(BUTTON, pigpio.PUD_UP)
pi.set_glitch_filter(BUTTON, 5000)       # 5 ms보다 짧은 변화 무시 (채터링 제거)
cb = pi.callback(BUTTON, pigpio.FALLING_EDGE, on_press)

print(f"{host}의 GPIO{BUTTON} 버튼을 눌러 보라. Ctrl+C로 종료")
try:
    while True:
        time.sleep(1)                    # 메인은 할 일이 없다. 콜백이 알아서 불린다.
except KeyboardInterrupt:
    pass
finally:
    cb.cancel()                          # 콜백 해제
    pi.set_glitch_filter(BUTTON, 0)
    pi.write(LED, 0)
    pi.set_mode(LED, pigpio.INPUT)
    pi.stop()                            # 연결만 끊는다. 데몬은 계속 돈다.
    print("\n정상 종료")
