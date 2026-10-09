#!/bin/bash
# bashism.sh : 4.20절  bash 전용 문법이 sh(dash)에서는 실패하는 것을 확인
# 실행 : bash bashism.sh   와   sh bashism.sh   를 비교한다

name="raspberrypi"
if [[ $name == rasp* ]]; then        # [[ ]] 와 패턴 비교는 bash 전용
    echo "[[ ]] OK: $name"
fi

leds=(17 27 22)                       # 배열도 bash 전용 (dash에는 배열이 없다)
echo "LED 개수: ${#leds[@]}, 첫 번째: ${leds[0]}"
