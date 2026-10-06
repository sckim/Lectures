#!/bin/bash
# args.sh : 4.19절  위치 매개변수($0 $1 $# $@)와 "$@" 따옴표의 의미

echo "스크립트 이름 \$0 = $0"
echo "인자 개수     \$# = $#"
echo "첫 번째 인자  \$1 = $1"
echo "두 번째 인자  \$2 = $2"

echo '--- for a in "$@" (따옴표 있음: 인자 그대로) ---'
for a in "$@"; do
    echo "[$a]"
done

echo '--- for a in $@ (따옴표 없음: 공백에서 또 쪼개진다) ---'
for a in $@; do
    echo "[$a]"
done
