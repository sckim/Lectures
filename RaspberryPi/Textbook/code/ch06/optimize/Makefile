# 6.8절  최적화 수준(-O0, -O2)에 따른 차이 관찰
CC     = gcc
CFLAGS = -Wall
# 어셈블리를 읽기 쉽게: .cfi 지시어를 만들지 않는다(2장 실습 2-3과 같은 옵션)
ASMFLAGS = -S -fno-asynchronous-unwind-tables -fno-unwind-tables

.PHONY: all run asm clean

all: opt_O0 opt_O2

opt_O0: opt_demo.c
	$(CC) $(CFLAGS) -O0 -o $@ $<

opt_O2: opt_demo.c
	$(CC) $(CFLAGS) -O2 -o $@ $<

run: opt_O0 opt_O2
	@echo "== -O0 =="; ./opt_O0
	@echo "== -O2 =="; ./opt_O2

asm: opt_demo.c
	$(CC) $(CFLAGS) -O0 $(ASMFLAGS) -o opt_O0.s $<
	$(CC) $(CFLAGS) -O2 $(ASMFLAGS) -o opt_O2.s $<

clean:
	rm -f opt_O0 opt_O2 opt_O0.s opt_O2.s
