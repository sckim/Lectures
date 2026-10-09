#!/bin/bash
# hello.sh : 4.19절  첫 셸 스크립트 (shebang, 주석, 변수, 명령 치환)

name="Raspberry Pi"            # 변수 대입: = 양옆에 공백을 두지 않는다
today=$(date +%F)              # 명령 치환: 명령의 출력을 변수에 넣는다 (예: 2025-10-16)

echo "Hello, $name!"
echo "오늘은 $today, 나는 $USER 이고 지금 위치는 $PWD 이다."
