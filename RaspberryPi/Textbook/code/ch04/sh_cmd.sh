#!/bin/bash
# sh_cmd.sh : 실습 4-4(1)  명령이 셸 내장(builtin)인지 외부 프로그램(파일)인지 확인
# 실행 : bash sh_cmd.sh   또는  chmod +x sh_cmd.sh && ./sh_cmd.sh
# 출처 : Linux 백서 탭A의 sh_cmd 예제를 확장

echo "== 1. type 으로 하나씩 확인 =="
for cmd in cd pwd echo ls grep cat type which; do
    echo "$cmd: $(type "$cmd")"
done

echo
echo "== 2. type -a : 같은 이름이 여러 곳에 있으면 모두 보여 준다 =="
type -a echo
type -a kill

echo
echo "== 3. which 는 PATH 안의 '파일'만 찾는다 =="
echo "which cd  -> $(which cd)"         # 내장 전용이라 아무것도 출력되지 않는다
echo "which pwd -> $(which pwd)"        # 내장이지만 같은 이름의 파일도 있다
echo "command -v cd -> $(command -v cd)"
echo "command -v ls -> $(command -v ls)"
