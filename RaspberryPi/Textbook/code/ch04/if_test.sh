#!/bin/bash
# if_test.sh : 4.19절  if 와 test([ ]), 숫자·문자열·파일 검사, read 로 입력받기

read -r -p "파일 이름을 입력하세요: " f

if [ -z "$f" ]; then                 # -z : 문자열 길이가 0이면 참
    echo "아무것도 입력하지 않았다."
    exit 1
elif [ -d "$f" ]; then               # -d : 디렉터리이면 참
    echo "'$f' 은(는) 디렉터리이다."
elif [ -f "$f" ]; then               # -f : 일반 파일이면 참
    lines=$(wc -l < "$f")
    if [ "$lines" -gt 10 ]; then     # -gt : 숫자 비교 (greater than)
        echo "'$f' 은(는) $lines 줄짜리 긴 파일이다."
    else
        echo "'$f' 은(는) $lines 줄짜리 짧은 파일이다."
    fi
    if [ -x "$f" ]; then             # -x : 실행 권한이 있으면 참
        echo "실행 권한(x)도 있다."
    fi
else
    echo "'$f' 은(는) 없다."
    exit 2
fi
