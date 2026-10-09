#!/bin/bash
# toggle_shell.sh : 실습 10-1  셸 명령으로 GPIO17을 "최대한 빨리" 토글해 C 프로그램과 비교
# 회로 : GPIO17 (물리 핀 11) -> AD2 DIO 0,  GND -> AD2 GND
# 실행 : bash toggle_shell.sh pinctrl    pinctrl set 17 dh / dl 반복
#        bash toggle_shell.sh pigs       pigs w 17 1 / 0 반복 (sudo systemctl start pigpiod 필요)
#        bash toggle_shell.sh sysfs      /sys/class/gpio 파일 쓰기 반복 (sudo 필요)
#        Ctrl+C로 끝낸다. 주파수는 계측기로 잰다.
# 주의 : C 실습(toggle_max)과 동시에 돌리지 않는다. 한 핀은 한 가지 방법으로만 제어한다.

PIN=17
METHOD=${1:-pinctrl}

cleanup() {
    echo
    echo "정리 후 종료"
    case $METHOD in
        pinctrl) pinctrl set $PIN ip ;;
        pigs)    pigs m $PIN r ;;
        sysfs)   echo $GPIO > /sys/class/gpio/unexport ;;
    esac
    exit 0
}
trap cleanup INT

case $METHOD in
pinctrl)
    pinctrl set $PIN op dl
    echo "pinctrl 토글 중 (Ctrl+C로 종료)"
    while true; do
        pinctrl set $PIN dh
        pinctrl set $PIN dl
    done
    ;;
pigs)
    pigs m $PIN w
    echo "pigs 토글 중 (Ctrl+C로 종료)"
    while true; do
        pigs w $PIN 1
        pigs w $PIN 0
    done
    ;;
sysfs)
    # 최신 커널은 sysfs 번호에 칩 기준 번호(base)가 더해진다(8장 8.4절).
    BASE=$(cat /sys/class/gpio/gpiochip*/base | sort -n | head -1)
    GPIO=$((BASE + PIN))
    echo $GPIO > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio$GPIO/direction
    echo "sysfs(gpio$GPIO) 토글 중 (Ctrl+C로 종료)"
    while true; do
        echo 1 > /sys/class/gpio/gpio$GPIO/value
        echo 0 > /sys/class/gpio/gpio$GPIO/value
    done
    ;;
*)
    echo "사용법: bash toggle_shell.sh [pinctrl|pigs|sysfs]"
    exit 1
    ;;
esac
