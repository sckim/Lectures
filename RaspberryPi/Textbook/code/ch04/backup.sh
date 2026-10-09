#!/bin/bash
# backup.sh : 실습 4-4(2)  디렉터리를 날짜가 붙은 tar.gz 파일로 백업
# 사용법 : ./backup.sh <원본_디렉터리> [백업_저장_디렉터리]
#   예   : ./backup.sh ~/project            -> ~/backup/project_20251016_093000.tar.gz
#          ./backup.sh ~/project /tmp/bak   -> /tmp/bak/project_20251016_093000.tar.gz

# --- 1. 인자 개수 확인 ---------------------------------------------
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "사용법: $0 <원본_디렉터리> [백업_저장_디렉터리]" >&2
    exit 1
fi

src="${1%/}"                      # 끝에 붙은 / 하나를 떼어 낸다 (project/ -> project)
dest="${2:-$HOME/backup}"         # 두 번째 인자가 없으면 ~/backup

# --- 2. 원본 확인 --------------------------------------------------
if [ ! -d "$src" ]; then
    echo "오류: '$src' 은(는) 디렉터리가 아닙니다." >&2
    exit 2
fi

# --- 3. 저장 위치 준비 --------------------------------------------
mkdir -p "$dest" || { echo "오류: '$dest' 를 만들 수 없습니다." >&2; exit 3; }

# --- 4. 파일 이름 만들기: 원본이름_연월일_시분초.tar.gz ------------
stamp=$(date +%Y%m%d_%H%M%S)
name="$(basename "$src")_${stamp}.tar.gz"
archive="$dest/$name"

# --- 5. 묶고 압축하기 ----------------------------------------------
# -C 로 원본의 부모 디렉터리에 들어가서 묶어야 압축 파일 안의 경로가 짧아진다.
if tar -czf "$archive" -C "$(dirname "$src")" "$(basename "$src")"; then
    count=$(tar -tzf "$archive" | wc -l)
    size=$(du -h "$archive" | cut -f1)
    echo "백업 완료: $archive ($count 항목, $size)"
else
    echo "오류: tar 실패" >&2
    exit 4
fi
