#!/bin/bash
# install_kernel_on_pi.sh : 실습 7-3  Pi에서 실행. ~/mykernel 의 커널을 "새 이름"으로 설치한다
# 사용 : sudo bash install_kernel_on_pi.sh             설치 (config.txt 에 kernel= 줄 추가)
#        sudo bash install_kernel_on_pi.sh --tryboot   한 번만 시험 부팅 (tryboot.txt 사용)
#        sudo bash install_kernel_on_pi.sh --rollback  기본 커널로 되돌리기
# 원칙 : 기본 커널(kernel8.img)과 기본 모듈은 절대 덮어쓰지 않는다. 문제가 생기면 한 줄만 지우면 된다.

set -euo pipefail

BOOT=/boot/firmware
CONFIG="$BOOT/config.txt"
TRYBOOT="$BOOT/tryboot.txt"
SRC_DIR="${SRC_DIR:-/home/${SUDO_USER:-$USER}/mykernel}"   # scp로 복사해 둔 폴더
MARK_BEGIN="# >>> ch07 custom kernel >>>"
MARK_END="# <<< ch07 custom kernel <<<"
MODE="${1:---install}"

# root 권한 확인 (부트 파티션과 /lib/modules 는 root만 쓸 수 있다)
if [ "$(id -u)" -ne 0 ]; then
    echo "오류: sudo 로 실행하세요. 예) sudo bash $0" >&2
    exit 1
fi

# config.txt 에서 이 스크립트가 넣은 구역(MARK_BEGIN ~ MARK_END)을 지운다
remove_block() {
    sed -i "/^$MARK_BEGIN\$/,/^$MARK_END\$/d" "$1"
}

backup_config() {
    local stamp
    stamp=$(date +%Y%m%d-%H%M%S)
    cp "$CONFIG" "$CONFIG.bak-$stamp"
    echo "백업: $CONFIG.bak-$stamp"
}

# ----- 되돌리기 -----
if [ "$MODE" = "--rollback" ]; then
    backup_config
    remove_block "$CONFIG"
    rm -f "$TRYBOOT"
    sync
    echo "config.txt 에서 kernel= 구역을 지웠습니다. sudo reboot 후 기본 커널로 부팅합니다."
    exit 0
fi

# ----- 설치 준비: 파일 확인 -----
for f in kernelrelease.txt imagename.txt; do
    if [ ! -f "$SRC_DIR/$f" ]; then
        echo "오류: $SRC_DIR/$f 가 없습니다. PC에서 scp 로 먼저 복사하세요." >&2
        exit 1
    fi
done
KREL=$(cat "$SRC_DIR/kernelrelease.txt")       # 예: 6.12.47-v8-custom+
IMG=$(cat "$SRC_DIR/imagename.txt")            # 예: kernel-custom.img
case "$KREL" in
    ""|*/*|.*) echo "오류: kernelrelease.txt 내용이 이상합니다: '$KREL'" >&2; exit 1 ;;
esac
MODTAR="$SRC_DIR/modules-$KREL.tar.gz"
for f in "$SRC_DIR/$IMG" "$MODTAR"; do
    if [ ! -f "$f" ]; then
        echo "오류: $f 가 없습니다." >&2
        exit 1
    fi
done

# 안전 장치 1: 기본 커널 파일 이름이면 거절한다
case "$IMG" in
    kernel8.img|kernel_2712.img|kernel7l.img|kernel7.img|kernel.img)
        echo "오류: $IMG 는 기본 커널 이름입니다. build_kernel.sh 의 MYTAG 를 바꾸세요." >&2
        exit 1 ;;
esac
# 안전 장치 2: 지금 돌고 있는 커널과 릴리스 이름이 같으면 모듈을 덮어쓰게 되므로 거절한다
if [ "$KREL" = "$(uname -r)" ]; then
    echo "오류: $KREL 은 지금 실행 중인 커널과 이름이 같습니다. LOCALVERSION 을 바꾸세요." >&2
    exit 1
fi
MODEL=$(tr -d '\0' < /proc/device-tree/model)
case "$MODEL" in
    *"Raspberry Pi 4"*) ;;
    *) echo "경고: 이 실습은 Raspberry Pi 4 기준입니다. 현재 보드: $MODEL" ;;
esac

# ----- 1) 커널 이미지를 새 이름으로 복사 -----
cp "$SRC_DIR/$IMG" "$BOOT/$IMG"
echo "커널 이미지: $BOOT/$IMG"

# ----- 2) 모듈 설치: /lib/modules/<릴리스>/ 에 풀고 의존성 목록을 만든다 -----
rm -rf "/lib/modules/$KREL"                     # 예전에 설치한 같은 이름(내 커널)만 지운다
tar -C /lib/modules -xzf "$MODTAR"
depmod -a "$KREL"
echo "모듈: /lib/modules/$KREL"

# ----- 3) 부팅 설정 -----
backup_config
remove_block "$CONFIG"
if [ "$MODE" = "--tryboot" ]; then
    # tryboot.txt = 지금 config.txt + 내 커널 한 줄. 'reboot 0 tryboot' 때 한 번만 쓰인다
    cp "$CONFIG" "$TRYBOOT"
    printf '%s\n[all]\nkernel=%s\n%s\n' "$MARK_BEGIN" "$IMG" "$MARK_END" >> "$TRYBOOT"
    sync
    echo "준비 완료. 다음 명령으로 한 번만 시험 부팅합니다:  sudo reboot '0 tryboot'"
    echo "부팅에 실패하면 전원을 뺐다 꽂기만 해도 기본 커널로 돌아옵니다."
else
    printf '%s\n[all]\nkernel=%s\n%s\n' "$MARK_BEGIN" "$IMG" "$MARK_END" >> "$CONFIG"
    sync
    echo "config.txt 끝에 'kernel=$IMG' 를 추가했습니다."
    echo "sudo reboot 후 'uname -r' 결과가 $KREL 이면 성공입니다."
    echo "되돌리기: sudo bash $0 --rollback  (부팅이 안 되면 PC에서 config.txt 의 해당 줄을 지운다)"
fi
