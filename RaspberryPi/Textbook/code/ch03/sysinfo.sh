#!/bin/bash
# sysinfo.sh : 실습 3-4  Raspberry Pi 시스템 정보를 한 화면에 정리해 출력
# 실행 : bash sysinfo.sh   또는  chmod +x sysinfo.sh && ./sysinfo.sh
# 참고 : vcgencmd가 없는 환경(PC의 WSL 등)에서는 해당 항목을 "확인 불가"로 표시한다.

line() { printf '%-14s: %s\n' "$1" "$2"; }

echo "===== Raspberry Pi 시스템 정보 ====="

# 1. 보드 모델: device tree의 model 문자열 (끝의 NUL 문자를 지운다)
if [ -r /proc/device-tree/model ]; then
    MODEL=$(tr -d '\0' < /proc/device-tree/model)
else
    MODEL="확인 불가 (device tree 없음)"
fi
line "Model" "$MODEL"

# 2. 호스트 이름과 OS 이름
line "Hostname" "$(hostname)"
if [ -r /etc/os-release ]; then
    . /etc/os-release
    line "OS" "$PRETTY_NAME"
fi

# 3. 커널 버전과 아키텍처
line "Kernel" "$(uname -r)"
line "Arch" "$(uname -m)"

# 4. CPU 코어 수와 최대 클록
CORES=$(nproc)
MAXF=/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
if [ -r "$MAXF" ]; then
    line "CPU" "${CORES} cores, max $(( $(cat "$MAXF") / 1000 )) MHz"
else
    line "CPU" "${CORES} cores"
fi

# 5. SoC 온도와 전원 상태 (vcgencmd는 Raspberry Pi 전용 도구)
if command -v vcgencmd > /dev/null 2>&1; then
    line "Temperature" "$(vcgencmd measure_temp | cut -d= -f2)"
    THR=$(vcgencmd get_throttled | cut -d= -f2)
    if [ "$THR" = "0x0" ]; then
        line "Throttled" "$THR (정상: 저전압·과열 기록 없음)"
    else
        line "Throttled" "$THR (0이 아님: 전원 어댑터와 온도를 점검할 것)"
    fi
else
    line "Temperature" "확인 불가 (vcgencmd 없음)"
fi

# 6. 메모리: free -h 의 Mem 줄에서 전체(2번째 칸)와 사용 가능(7번째 칸)
MEM=$(LC_ALL=C free -h | awk '/^Mem:/ {print "total " $2 ", available " $7}')
line "Memory" "$MEM"

# 7. 디스크: 루트(/)와 부트 파티션(/boot/firmware)
for MP in / /boot/firmware; do
    if mountpoint -q "$MP" 2> /dev/null; then
        USE=$(LC_ALL=C df -h "$MP" | awk 'NR == 2 {print $1 "  size " $2 ", used " $3 " (" $5 ")"}')
        line "Disk $MP" "$USE"
    fi
done

# 8. IP 주소: 인터페이스 이름과 IPv4 주소 (lo 제외)
ip -4 -o addr show 2> /dev/null | awk '$2 != "lo" {print $2, $4}' | while read -r IF ADDR; do
    line "IP ($IF)" "$ADDR"
done

# 9. 부팅 후 경과 시간
line "Uptime" "$(uptime -p)"
