# 6.4절  자주 만나는 빌드 오류를 일부러 일으켜 본다
# 사용법: make <타깃>   예) make err-lm
# 오류를 보는 것이 목적이므로 일부 타깃은 실패(Error 1)로 끝나는 것이 정상이다.
CC     = gcc
CFLAGS = -Wall -O0
CH08   = ../../ch08
NUM    = ../numeric

.PHONY: help err-implicit err-header err-undef err-cannot-find err-lm fix-lm \
        err-multi fix-multi clean

help:
	@echo "make err-implicit     헤더 누락 → implicit declaration 경고"
	@echo "make err-header       헤더 파일 자체가 없음 → fatal error"
	@echo "make err-undef        라이브러리 누락 → undefined reference"
	@echo "make err-cannot-find  라이브러리 파일이 없음 → cannot find -lpigpio"
	@echo "make err-lm / fix-lm  -lm 누락과 수정"
	@echo "make err-multi / fix-multi  multiple definition과 수정"

err-implicit:
	$(CC) $(CFLAGS) -o no_unistd no_unistd.c

# pigpio가 설치되지 않은 PC(WSL)에서 실행하면 오류가 난다. Pi에서는 성공한다.
err-header:
	$(CC) $(CFLAGS) -c -o led_blink.o $(CH08)/led_blink.c

# 헤더는 찾았지만(-I는 Pi에서는 필요 없음) -lpigpio를 빼고 링크한다
err-undef:
	$(CC) $(CFLAGS) -o led_blink $(CH08)/led_blink.c

err-cannot-find:
	$(CC) $(CFLAGS) -o led_blink $(CH08)/led_blink.c -lpigpio -lrt -pthread

err-lm:
	$(CC) $(CFLAGS) -o triangle $(NUM)/triangle.c

fix-lm:
	$(CC) $(CFLAGS) -o triangle $(NUM)/triangle.c -lm

err-multi:
	$(CC) $(CFLAGS) -o counter counter_a.c counter_b.c

fix-multi:
	$(CC) $(CFLAGS) -DFIX -o counter counter_a.c counter_b.c

clean:
	rm -f no_unistd led_blink led_blink.o triangle counter
