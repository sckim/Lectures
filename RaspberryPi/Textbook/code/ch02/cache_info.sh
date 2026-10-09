#!/bin/sh
# cache_info.sh - CPU0의 캐시 계층 정보를 sysfs에서 읽어 한 줄씩 출력한다
# 실행: sh cache_info.sh

CACHE=/sys/devices/system/cpu/cpu0/cache

if [ ! -d "$CACHE" ]; then
    echo "$CACHE 가 없습니다. 이 커널은 캐시 정보를 sysfs로 알려 주지 않습니다."
    exit 1
fi

printf "%-7s %-6s %-12s %-6s %-6s %-5s %s\n" \
       "index" "level" "type" "size" "line" "ways" "shared_cpus"
for d in "$CACHE"/index*; do
    printf "%-7s %-6s %-12s %-6s %-6s %-5s %s\n" \
        "$(basename "$d")" \
        "L$(cat "$d/level")" \
        "$(cat "$d/type")" \
        "$(cat "$d/size")" \
        "$(cat "$d/coherency_line_size" 2>/dev/null)B" \
        "$(cat "$d/ways_of_associativity" 2>/dev/null)" \
        "$(cat "$d/shared_cpu_list")"
done
