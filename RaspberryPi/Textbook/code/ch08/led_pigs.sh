#!/bin/bash
# led_pigs.sh : 실습 8-1  pigs 명령으로 셸에서 LED 제어
# 준비 : sudo systemctl start pigpiod   (pigs는 데몬에게 명령을 보내는 클라이언트다)
# 실행 : bash led_pigs.sh   또는  chmod +x led_pigs.sh && ./led_pigs.sh
# 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND

LED=17

pigs m $LED w            # 모드: 출력(w)
for i in 1 2 3 4 5; do
    pigs w $LED 1        # High
    echo "[$i] LED on  (read back: $(pigs r $LED))"
    sleep 0.5
    pigs w $LED 0        # Low
    echo "[$i] LED off (read back: $(pigs r $LED))"
    sleep 0.5
done
pigs m $LED r            # 끝나면 입력으로 되돌린다
