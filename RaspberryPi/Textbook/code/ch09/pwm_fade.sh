#!/bin/bash
# pwm_fade.sh : 실습 9-3  pigs 명령으로 셸에서 PWM 밝기 조절
# 준비 : sudo systemctl start pigpiod   (pigs는 데몬 클라이언트다)
# 실행 : bash pwm_fade.sh               (중괄호 증감 {0..255..5}는 bash 문법이다)
# 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND
# 원본 : 「Raspberry Pi 실습」 슬라이드 pwm_demo.sh (GPIO18 -> GPIO17, 주파수 확인 추가)

LED=17

pigs pfs $LED 800                         # 주파수(pfs) 800 Hz 요청
echo "실제 주파수 $(pigs pfg $LED) Hz, 범위 $(pigs prg $LED), 실제 범위 $(pigs prrg $LED)"

echo "Fade In"
for i in {0..255..5}; do
    pigs p $LED $i                        # 듀티(p) 0~255
    sleep 0.05
done

echo "Fade Out"
for i in {255..0..-5}; do
    pigs p $LED $i
    sleep 0.05
done

pigs p $LED 0                             # PWM 끄기
pigs m $LED r                             # 입력으로 되돌린다
