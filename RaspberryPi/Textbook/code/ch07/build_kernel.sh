#!/bin/bash
# build_kernel.sh : 실습 7-3  WSL2(Ubuntu)에서 Raspberry Pi 4용 64비트 커널을 교차 빌드한다
# 실행 : bash build_kernel.sh            (WSL의 리눅스 홈 아래에서. /mnt/c 아래 금지)
#        MENUCONFIG=1 bash build_kernel.sh   (menuconfig 화면을 직접 보고 싶을 때)
# 결과 : $WORK/out/ 에 kernel-<태그>.img, modules-<릴리스>.tar.gz, kernelrelease.txt
# 참고 : https://www.raspberrypi.com/documentation/computers/linux_kernel.html

set -euo pipefail          # 오류가 나면 즉시 멈춘다 (빌드가 반쯤 된 상태로 넘어가지 않게)

# ===== 1. 사용자 설정 (필요하면 여기만 고친다) =====
BRANCH="${BRANCH:-rpi-6.12.y}"     # Pi에서 uname -r 의 앞부분(예: 6.12)과 같은 계열을 고른다
MYTAG="${MYTAG:-custom}"           # 내 커널 꼬리표. 영문 소문자·숫자·하이픈만 (예: s2025123)
WORK="${WORK:-$HOME/rpi-kernel}"   # 작업 폴더. 반드시 리눅스 파일 시스템(/home/...) 안
JOBS="${JOBS:-$(nproc)}"           # 동시에 돌릴 컴파일 작업 수. 메모리 오류가 나면 2~4로 줄인다

SRC="$WORK/linux"                  # 커널 소스가 들어갈 곳
STAGE="$WORK/stage"                # modules_install 결과를 임시로 모으는 곳
OUT="$WORK/out"                    # Pi로 보낼 결과물을 모으는 곳
IMG_NAME="kernel-$MYTAG.img"       # Pi의 부트 파티션에 들어갈 새 커널 파일 이름

# make를 부를 때마다 아키텍처와 교차 컴파일러 접두어를 붙인다
kmake() {
    make -C "$SRC" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- "$@"
}

# ===== 2. 작업 위치 점검: /mnt/c 아래면 멈춘다 =====
case "$WORK" in
    /mnt/*)
        echo "오류: WORK=$WORK 는 Windows 드라이브입니다. 'cd ~' 후 리눅스 홈에서 실행하세요." >&2
        exit 1 ;;
esac
case "$MYTAG" in
    *[!a-z0-9-]*|"")
        echo "오류: MYTAG 는 영문 소문자, 숫자, 하이픈(-)만 쓸 수 있습니다: '$MYTAG'" >&2
        exit 1 ;;
esac

# ===== 3. 필요한 도구가 있는지 확인 =====
missing=0
for tool in git make bc bison flex depmod aarch64-linux-gnu-gcc; do
    if ! command -v "$tool" > /dev/null 2>&1; then
        echo "없음: $tool"
        missing=1
    fi
done
if [ "$missing" -eq 1 ]; then
    echo "다음 명령으로 설치한 뒤 다시 실행하세요:" >&2
    echo "  sudo apt update" >&2
    echo "  sudo apt install git bc bison flex libssl-dev make libc6-dev libncurses-dev kmod crossbuild-essential-arm64" >&2
    exit 1
fi

# ===== 4. 커널 소스 받기 (이미 있으면 건너뛴다) =====
mkdir -p "$WORK"
if [ ! -d "$SRC/.git" ]; then
    echo "[1/6] 커널 소스 받기: $BRANCH (기록 없이 최신 상태만)"
    git clone --depth=1 --branch "$BRANCH" https://github.com/raspberrypi/linux "$SRC"
else
    CUR=$(git -C "$SRC" rev-parse --abbrev-ref HEAD)
    if [ "$CUR" != "$BRANCH" ]; then
        echo "오류: $SRC 는 $CUR 브랜치입니다. BRANCH=$CUR 로 실행하거나 폴더를 지우세요." >&2
        exit 1
    fi
    echo "[1/6] 커널 소스가 이미 있습니다: $SRC ($CUR)"
fi

# ===== 5. 설정: Pi 4 기본 설정 + 내 꼬리표(LOCALVERSION) =====
echo "[2/6] bcm2711_defconfig 적용 (Pi 4의 기본 .config 만들기)"
kmake bcm2711_defconfig
"$SRC/scripts/config" --file "$SRC/.config" --set-str LOCALVERSION "-v8-$MYTAG"
kmake olddefconfig > /dev/null           # 바뀐 값에 맞춰 나머지 설정을 정리
if [ "${MENUCONFIG:-0}" = "1" ]; then
    kmake menuconfig                     # General setup > Local version 에서 확인할 수 있다
fi
grep '^CONFIG_LOCALVERSION=' "$SRC/.config"

# ===== 6. 빌드: 커널 이미지(Image) + 모듈(modules) + device tree(dtbs) =====
echo "[3/6] 빌드 시작 (작업 $JOBS 개). 처음에는 수십 분 걸릴 수 있다"
time kmake -j"$JOBS" Image modules dtbs
KREL=$(cat "$SRC/include/config/kernel.release")   # 빌드가 만든 릴리스 이름. 예: 6.12.47-v8-custom+
echo "커널 릴리스 이름: $KREL"

# ===== 7. 모듈을 임시 폴더에 설치 (내 PC의 /lib/modules 는 건드리지 않는다) =====
echo "[4/6] 모듈을 $STAGE 에 설치"
rm -rf "$STAGE"
kmake INSTALL_MOD_PATH="$STAGE" INSTALL_MOD_STRIP=1 modules_install > /dev/null
# build, source 는 PC의 소스 폴더를 가리키는 링크라 Pi에서는 쓸모가 없으므로 지운다
rm -f "$STAGE/lib/modules/$KREL/build" "$STAGE/lib/modules/$KREL/source"

# ===== 8. Pi로 보낼 결과물 정리 =====
echo "[5/6] 결과물을 $OUT 에 모으기"
rm -rf "$OUT"
mkdir -p "$OUT/dtb" "$OUT/overlays"
cp "$SRC/arch/arm64/boot/Image" "$OUT/$IMG_NAME"
# 모듈 묶음 안에는 "<릴리스>/..." 만 넣는다. Pi에서 /lib/modules 아래에 그대로 풀린다
tar -C "$STAGE/lib/modules" -czf "$OUT/modules-$KREL.tar.gz" "$KREL"
echo "$KREL" > "$OUT/kernelrelease.txt"
echo "$IMG_NAME" > "$OUT/imagename.txt"
# 참고용: 이번 실습은 Pi에 이미 있는 dtb·overlays를 그대로 쓰므로 복사만 해 둔다
cp "$SRC"/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb "$OUT/dtb/"
cp "$SRC"/arch/arm64/boot/dts/overlays/*.dtbo "$OUT/overlays/"

echo "[6/6] 완료"
ls -lh "$OUT"
echo
echo "다음 단계 (PC에서, ID와 IP는 자기 것으로):"
echo "  ssh <ID>@192.168.0.xx mkdir -p mykernel"
echo "  scp $OUT/$IMG_NAME $OUT/modules-$KREL.tar.gz $OUT/kernelrelease.txt $OUT/imagename.txt <ID>@192.168.0.xx:~/mykernel/"
