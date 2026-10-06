# 실습 6-6  gdb 디버깅 실습
CC     = gcc
# -g  : 소스 줄 번호·변수 이름 같은 디버깅 정보를 실행 파일에 넣는다
# -O0 : 최적화를 끈다(변수가 사라지거나 줄 순서가 뒤바뀌지 않게)
CFLAGS = -Wall -g -O0

.PHONY: all debug clean

all: scores

scores: scores.c
	$(CC) $(CFLAGS) -o $@ $<

debug: scores
	gdb ./scores

clean:
	rm -f scores
