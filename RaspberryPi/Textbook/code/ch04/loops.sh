#!/bin/bash
# loops.sh : 4.19절  for, while, 산술 확장 $(( ))

echo "--- 1. 목록을 도는 for ---"
for pin in 17 27 22; do
    echo "GPIO$pin"
done

echo "--- 2. 숫자 범위 for (중괄호 확장) ---"
for i in {1..3}; do
    echo "측정 $i 회"
done

echo "--- 3. 조건이 참인 동안 도는 while ---"
count=3
while [ "$count" -gt 0 ]; do
    echo "카운트다운 $count"
    count=$((count - 1))       # 산술 확장: 정수 계산
done

echo "--- 4. 파일을 한 줄씩 읽는 while read (sample.log 앞 3줄) ---"
n=0
while read -r day time level sensor value msg; do   # 공백으로 나뉜 칸이 변수에 차례로 들어간다
    n=$((n + 1))
    echo "$n: $sensor = $value ($level)"
    if [ "$n" -ge 3 ]; then
        break                  # 반복문 빠져나가기
    fi
done < sample.log
