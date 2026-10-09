# 실습 6-2  일반 C 예제 (하드웨어를 쓰지 않으므로 PC의 Linux/WSL에서도 빌드된다)
CC     = gcc
CFLAGS = -Wall -O0

PROGS = calculate_pi calculate_pi2 triangle logic

.PHONY: all clean

all: $(PROGS)

# 수학 함수를 쓰는 triangle만 libm(-lm)을 추가로 링크한다
triangle: triangle.c
	$(CC) $(CFLAGS) -o $@ $< -lm

# 나머지는 표준 C 라이브러리만 쓴다(자동 링크)
calculate_pi calculate_pi2 logic: %: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(PROGS)
