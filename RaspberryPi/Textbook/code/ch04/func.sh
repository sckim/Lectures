#!/bin/bash
# func.sh : 4.19절  함수, local 변수, return(종료 상태)과 echo(출력값)의 차이

# 섭씨를 화씨로 바꿔 "출력"한다 (bash 산술은 정수만 다루므로 awk 로 계산)
c_to_f() {
    local c="$1"                       # local : 함수 안에서만 쓰는 변수
    awk -v c="$c" 'BEGIN { printf "%.1f\n", c * 9 / 5 + 32 }'
}

# 값이 숫자이면 0(성공), 아니면 1(실패)을 "반환"한다
is_number() {
    [[ $1 =~ ^-?[0-9]+(\.[0-9]+)?$ ]]  # 마지막 명령의 종료 상태가 함수의 종료 상태가 된다
}

for t in 23.4 NA 100; do
    if is_number "$t"; then
        echo "$t C = $(c_to_f "$t") F"
    else
        echo "$t 은(는) 숫자가 아니다 (is_number 종료 상태: 1)"
    fi
done
