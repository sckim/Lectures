#!/bin/bash
# worker.sh : 실습 5-3  프로세스 제어 실험용 "일꾼" 스크립트
# 사용법 : ./worker.sh [이름] [간격_초]
#   예   : ./worker.sh A 1      -> 1초마다 "A" 일꾼이 숫자를 센다
#          ./worker.sh B 0      -> 간격 0 = 쉬지 않고 계산만 한다 (CPU를 100% 쓴다, top 관찰용)
# 종료 : Ctrl+C(SIGINT), kill PID(SIGTERM), kill -HUP PID(SIGHUP)는 "정리 후 종료" 메시지를 남긴다.
#        kill -9 PID(SIGKILL)는 잡을 수 없으므로 아무 메시지 없이 즉시 사라진다.

name="${1:-worker}"
interval="${2:-1}"
count=0

# --- 1. 인자 확인: 간격은 0 이상의 정수 ------------------------------
if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
    echo "사용법: $0 [이름] [간격_초(0 이상의 정수)]" >&2
    exit 2
fi

# --- 2. 시그널 처리기(trap): 받은 시그널 이름을 남기고 끝낸다 ----------
cleanup() {
    echo "[$name] PID $$ : $1 받음 -> 정리하고 종료 (count=$count)"
    exit 0
}
trap 'cleanup SIGINT'  INT
trap 'cleanup SIGTERM' TERM
trap 'cleanup SIGHUP'  HUP

echo "[$name] 시작: PID=$$, 부모 PPID=$PPID, 간격=${interval}s"

# --- 3. 본 작업 ---------------------------------------------------------
while true; do
    count=$((count + 1))
    if [ "$interval" -eq 0 ]; then
        # 쉬지 않는 계산: 100만 번마다 한 줄만 출력한다
        if [ $((count % 1000000)) -eq 0 ]; then
            echo "[$name] 계산 중... count=$count"
        fi
    else
        echo "[$name] count=$count  $(date +%H:%M:%S)"
        sleep "$interval" &      # sleep을 자식으로 돌리고
        wait $!                  # 기다린다: 이렇게 해야 시그널을 받는 즉시 trap이 실행된다
    fi
done
