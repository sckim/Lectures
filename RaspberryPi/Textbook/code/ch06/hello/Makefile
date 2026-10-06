# 실습 6-1  hello.c를 단계별로 빌드해 중간 산출물을 확인한다
CC     = gcc
CFLAGS = -Wall

.PHONY: all stages clean

all: hello hello_sleep

# 1) 전처리: #include, #define 처리 → hello.i (아직 C 코드)
hello.i: hello.c
	$(CC) -E hello.c -o hello.i

# 2) 컴파일: C → 어셈블리 → hello.s
hello.s: hello.i
	$(CC) $(CFLAGS) -S hello.i -o hello.s

# 3) 어셈블: 어셈블리 → 기계어 목적 파일 → hello.o
hello.o: hello.s
	$(CC) -c hello.s -o hello.o

# 4) 링크: 목적 파일 + C 라이브러리 + 시작 코드 → 실행 파일 hello
hello: hello.o
	$(CC) hello.o -o hello

stages: hello
	@ls -l hello.c hello.i hello.s hello.o hello

hello_sleep: hello_sleep.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f hello hello.i hello.s hello.o hello_sleep
