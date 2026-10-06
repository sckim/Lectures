#!/bin/bash
# heartbeat.sh : 실습 5-4  일정 간격으로 "살아 있음"과 SoC 온도를 표준 출력에 기록
# 사용법 : heartbeat.sh [간격_초]     -> 끝없이 반복 (systemd 서비스용, 기본 10초)
#          heartbeat.sh --once        -> 한 줄만 출력하고 끝 (cron, systemd 타이머용)
# 설치 : sudo install -m 755 heartbeat.sh /usr/local/bin/heartbeat.sh
# 참고 : 서비스로 실행하면 표준 출력이 그대로 journal에 저장된다(journalctl -u heartbeat).
#        파일에 직접 쓰지 않으므로 root가 아닌 임시 사용자(DynamicUser)로도 동작한다.

TEMP_FILE=/sys/class/thermal/thermal_zone0/temp   # 단위: 밀리도(m°C), 예) 48686 -> 48.6

# --- 함수: SoC 온도를 "48.6C" 형태로 돌려준다 (파일이 없으면 N/A) -----
read_temp() {
    local milli
    if [ -r "$TEMP_FILE" ] && read -r milli < "$TEMP_FILE"; then
        echo "$((milli / 1000)).$(((milli % 1000) / 100))C"
    else
        echo "N/A"
    fi
}

# --- 함수: 한 줄 기록 -----------------------------------------------
beat() {
    local up load
    up=$(cut -d' ' -f1 /proc/uptime)          # 부팅 후 경과 초
    load=$(cut -d' ' -f1 /proc/loadavg)       # 1분 평균 부하
    echo "heartbeat n=$1 temp=$(read_temp) uptime=${up}s load1=$load"
}

# --- 1. 한 번만 실행하는 모드 -----------------------------------------
if [ "$1" = "--once" ]; then
    beat 1
    exit 0
fi

# --- 2. 간격 확인 -----------------------------------------------------
interval="${1:-10}"
if ! [[ "$interval" =~ ^[1-9][0-9]*$ ]]; then
    echo "사용법: $0 [간격_초(1 이상)] | --once" >&2
    exit 2
fi

# --- 3. 종료 요청(SIGTERM)을 받으면 마지막 줄을 남기고 끝낸다 ------------
n=0
trap 'echo "heartbeat 종료 요청(SIGTERM) 받음, n=$n"; exit 0' TERM
trap 'echo "heartbeat 종료 요청(SIGINT) 받음, n=$n"; exit 0' INT

echo "heartbeat 시작: PID=$$, 간격=${interval}s"
while true; do
    n=$((n + 1))
    beat "$n"
    sleep "$interval" &
    wait $!
done
