#!/bin/bash
# led_gpiod.sh : 실습 8-6 (선택)  libgpiod 명령(gpioset)으로 같은 LED 제어
# 준비 : sudo apt install gpiod      (Bookworm 기본 저장소는 libgpiod 1.6.x, v1 문법)
# 실행 : bash led_gpiod.sh           (gpio 그룹 사용자는 sudo 불필요)
# 주의 : 다른 프로그램(pigpio 등)이 GPIO17을 쓰고 있지 않은 상태에서 실행한다.

CHIP=gpiochip0           # Pi 4의 40핀 GPIO 컨트롤러 (gpiodetect로 확인)
LED=17                   # 칩 안에서의 오프셋 = BCM 번호

gpiodetect
gpioinfo $CHIP | grep -E "line +$LED:"

for i in 1 2 3; do
    echo "[$i] on"
    gpioset --mode=time --sec=1 $CHIP $LED=1    # 1초 동안 High 유지 후 해제
    echo "[$i] off"
    gpioset --mode=time --sec=1 $CHIP $LED=0
done
