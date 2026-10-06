#!/bin/bash
# bt_enable.sh : 실습 13-0  3장에서 끈 Bluetooth를 다시 켠다 (config.txt 수정 + 서비스 활성화)
# 사용법 : sudo bash bt_enable.sh      -> 끝나면 sudo reboot
# 하는 일 : 1) /boot/firmware/config.txt 백업
#           2) dtoverlay=disable-bt 줄 앞에 # 를 붙여 주석 처리
#           3) hciuart(칩 초기화), bluetooth(bluetoothd) 서비스를 부팅 때 켜지도록 enable
#           4) rfkill 소프트 차단 해제
# 되돌리기 : 백업 파일을 config.txt로 복사하고 재부팅(3장 UART 설정으로 돌아간다)

set -eu
CFG=/boot/firmware/config.txt

if [ "$(id -u)" -ne 0 ]; then
    echo "root 권한이 필요하다: sudo bash $0" >&2
    exit 1
fi
if [ ! -f "$CFG" ]; then
    echo "$CFG 가 없다 (Bookworm이 맞는가?)" >&2
    exit 1
fi

# --- 1. 백업 -------------------------------------------------------------
BAK="$CFG.bak.$(date +%Y%m%d-%H%M%S)"
cp "$CFG" "$BAK"
echo "백업: $BAK"

# --- 2. disable-bt 주석 처리 ----------------------------------------------
if grep -Eq '^[[:space:]]*dtoverlay=disable-bt' "$CFG"; then
    sed -i -E 's/^([[:space:]]*)dtoverlay=disable-bt/\1#dtoverlay=disable-bt/' "$CFG"
    echo "dtoverlay=disable-bt 를 주석 처리했다"
else
    echo "활성화된 dtoverlay=disable-bt 줄이 없다 (이미 주석이거나 없음)"
fi
echo "--- 현재 config.txt의 UART·Bluetooth 관련 줄 ---"
grep -nE 'enable_uart|uart_2ndstage|disable-bt|miniuart-bt|core_freq' "$CFG" || true

# --- 3. 서비스 활성화 -----------------------------------------------------
for svc in hciuart bluetooth; do
    if systemctl list-unit-files "$svc.service" --no-legend | grep -q "^$svc.service"; then
        systemctl enable "$svc.service"
        echo "$svc.service: $(systemctl is-enabled "$svc.service")"
    else
        echo "$svc.service 가 없다 -> sudo apt install bluez pi-bluetooth 확인" >&2
    fi
done

# --- 4. rfkill 소프트 차단 해제 -------------------------------------------
rfkill unblock bluetooth || true

echo "완료. 재부팅 후 bash bt_check.sh 로 확인한다: sudo reboot"
