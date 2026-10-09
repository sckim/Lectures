#!/bin/bash
# bt_check.sh : 실습 13-0  Bluetooth가 살아났는지, UART 콘솔이 어디로 갔는지 한 번에 확인한다
# 사용법 : bash bt_check.sh          (일부 항목은 sudo 암호를 물을 수 있다)
# 읽기만 하고 아무것도 바꾸지 않는다.

# rfkill은 /usr/sbin에 있다. ssh 'bash bt_check.sh'처럼 실행하면 PATH에 없을 수 있어서 더해 둔다
PATH="$PATH:/usr/sbin"

section() { printf '\n===== %s =====\n' "$1"; }

section "1. config.txt (disable-bt 앞에 # 가 있어야 한다)"
grep -nE 'enable_uart|disable-bt|miniuart-bt|core_freq' /boot/firmware/config.txt || echo "(관련 줄 없음)"

section "2. 시리얼 별명: serial0이 ttyS0(mini UART)이면 정상 (Bookworm은 serial1이 없어도 정상)"
ls -l /dev/serial* 2>/dev/null || echo "(/dev/serial* 없음: enable_uart 확인)"

section "3. 서비스 상태 (bluetooth가 active면 정상, hciuart는 inactive여도 정상)"
for svc in hciuart bluetooth; do
    printf '%-10s enabled=%-9s active=%s\n' "$svc" \
        "$(systemctl is-enabled "$svc" 2>/dev/null)" "$(systemctl is-active "$svc" 2>/dev/null)"
done

section "4. rfkill (Soft blocked: no 여야 한다)"
rfkill list bluetooth 2>/dev/null || echo "(rfkill 없음)"

section "5. bluetoothctl show (Controller 줄과 Powered: yes)"
bluetoothctl --version 2>/dev/null
timeout 5 bluetoothctl show 2>&1 | head -12

section "6. btmgmt info (커널 관리 인터페이스에서 본 hci0)"
timeout 5 sudo btmgmt info 2>&1 | head -8

section "7. 내 사용자의 그룹 (Bookworm은 bluetooth 그룹이 없어도 sudo 없이 BLE 사용 가능)"
id -nG

section "8. 커널 로그의 Bluetooth 줄 (최근 10줄)"
journalctl -k -b --no-pager 2>/dev/null | grep -iE 'bluetooth|hci0' | tail -10
