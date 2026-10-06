#!/bin/bash
# boot_report.sh : 실습 7-1  부팅 과정의 "증거"를 한 번에 모아 보여 준다
# 실행 : bash boot_report.sh            (중간에 sudo 암호를 물을 수 있다)
#        bash boot_report.sh > report.txt  (과제용으로 파일에 저장)
# 결과 : 화면 출력 + 현재 폴더에 boot.svg (systemd-analyze plot 그림)

section() { printf '\n===== %s =====\n' "$1"; }

section "1. 보드와 커널"
echo "Model   : $(tr -d '\0' < /proc/device-tree/model)"
echo "Kernel  : $(uname -r)"
echo "Version : $(cat /proc/version)"

section "2. 커널이 실제로 받은 명령줄 (/proc/cmdline)"
cat /proc/cmdline

section "3. 펌웨어(start4.elf) 로그 앞부분 (vclog)"
if command -v vclog > /dev/null 2>&1; then
    sudo vclog --msg | head -n 25
else
    echo "vclog 명령이 없습니다 (UART의 uart_2ndstage 로그로 대신 확인)"
fi

section "4. 커널 로그에서 이정표 찾기 (dmesg, [초] = 커널 시작 후 경과 시간)"
sudo dmesg | grep -E "Booting Linux|Machine model|Kernel command line|started at EL|Run .* as init process|Mounted root|EXT4-fs \(mmcblk0p2\)|systemd\[1\]: systemd [0-9]" | head -n 20

section "5. 부팅에 걸린 시간 (systemd-analyze)"
systemd-analyze || echo "아직 부팅이 끝나지 않았습니다. 잠시 후 다시 실행하세요."

section "6. 오래 걸린 서비스 상위 10개 (systemd-analyze blame)"
systemd-analyze blame | head -n 10

section "7. 기본 목표(target)까지의 핵심 경로 (systemd-analyze critical-chain)"
systemctl get-default
systemd-analyze critical-chain | head -n 20

section "8. 그림 저장"
if systemd-analyze plot > boot.svg; then
    echo "boot.svg 저장 완료 → PC로 복사해 웹 브라우저로 연다"
fi
