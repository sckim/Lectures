#!/bin/sh
# sudo-gdb.sh : 실습 6-7  VS Code 디버거가 gdb를 root 권한으로 실행하게 하는 래퍼
#
# launch.json의 "miDebuggerPath"가 /usr/bin/gdb 대신 이 파일을 가리키면,
# VS Code가 넘겨 주는 인자("$@")를 그대로 붙여 sudo로 gdb를 실행한다.
#
# 준비 : chmod +x .vscode/sudo-gdb.sh
# 조건 : 비밀번호 없이 sudo가 되어야 한다. 확인: sudo -n true && echo OK
#        (VS Code는 비밀번호 입력 창을 띄울 수 없으므로 -n 으로 실행해
#         비밀번호가 필요하면 기다리지 않고 바로 실패하게 했다)
# 주의 : 디버깅하는 프로그램 전체가 root로 실행된다. 수업용 Pi에서만 쓴다.
exec sudo -n /usr/bin/gdb "$@"
