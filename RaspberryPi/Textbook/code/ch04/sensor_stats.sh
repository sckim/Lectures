#!/bin/bash
# sensor_stats.sh : 실습 4-4(3)  센서 로그에서 센서별 통계(개수·최소·최대·평균)와 오류 수를 구한다
# 사용법 : ./sensor_stats.sh [로그파일]        (생략하면 sample.log)
# 로그 형식 : 날짜 시각 레벨 센서 값 메시지...
#   예) 2025-10-16 09:00:00 INFO temp1 23.4 boot ok

log="${1:-sample.log}"

# --- 입력 확인 -------------------------------------------------------
if [ ! -f "$log" ]; then
    echo "오류: 로그 파일 '$log' 이(가) 없습니다." >&2
    exit 1
fi
if [ ! -r "$log" ]; then
    echo "오류: '$log' 을(를) 읽을 권한이 없습니다." >&2
    exit 1
fi

# --- 함수: 센서 하나의 통계 ------------------------------------------
# $1 = 센서 이름. 값(5번째 필드)이 숫자인 줄만 계산에 넣는다.
stats() {
    awk -v s="$1" '
        $4 == s && $5 ~ /^[0-9]+(\.[0-9]+)?$/ {
            n++; sum += $5
            if (n == 1 || $5 < min) min = $5
            if (n == 1 || $5 > max) max = $5
        }
        END {
            if (n > 0) printf "%-6s n=%-3d min=%5.1f max=%5.1f avg=%5.2f\n", s, n, min, max, sum / n
            else       printf "%-6s 유효한 값 없음\n", s
        }' "$log"
}

echo "== 로그 파일: $log ($(wc -l < "$log") 줄) =="

# --- 1. 형식이 맞지 않는 줄 세기 (필드가 6개 미만) ------------------
bad=$(awk 'NF < 6' "$log" | wc -l)
echo "형식 오류 줄: $bad"

# --- 2. 레벨별 줄 수: while read 로 한 줄씩 -------------------------
info=0; warn=0; error=0
while read -r d t level rest; do
    case "$level" in
        INFO)  info=$((info + 1)) ;;
        WARN)  warn=$((warn + 1)) ;;
        ERROR) error=$((error + 1)) ;;
    esac
done < "$log"
echo "INFO=$info  WARN=$warn  ERROR=$error"

# --- 3. 센서 목록을 로그에서 뽑아 for 로 돌기 ------------------------
sensors=$(awk 'NF >= 6 { print $4 }' "$log" | sort -u)
echo
for s in $sensors; do
    stats "$s"
done

# --- 4. 오류가 있으면 종료 코드 3 으로 알린다 ------------------------
if [ "$error" -gt 0 ]; then
    detail=$(awk '$3 == "ERROR" { print $4 }' "$log" | sort | uniq -c | awk '{ printf " %s=%s", $2, $1 }')
    echo
    echo "주의: ERROR $error 건 (센서별:$detail)"
    exit 3
fi
exit 0
