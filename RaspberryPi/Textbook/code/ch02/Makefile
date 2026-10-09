# 2장 실습 코드 빌드 (Raspberry Pi OS 64비트에서 실행)
CC      = gcc
CFLAGS  = -Wall -O1
# 어셈블리를 읽기 쉽게: 예외 처리·디버깅용 .cfi 지시어를 만들지 않는다
ASMFLAGS = -O1 -S -fno-asynchronous-unwind-tables -fno-unwind-tables

.PHONY: all asm dis enc enc32 clean

all: endian asm_demo

endian: endian.c
	$(CC) $(CFLAGS) -o $@ $<

asm_demo: asm_main.c asm_demo.c
	$(CC) $(CFLAGS) -o $@ asm_main.c asm_demo.c

# C -> 어셈블리 (asm_demo.s)
asm: asm_demo.c
	$(CC) $(ASMFLAGS) -o asm_demo.s asm_demo.c

# 목적 파일을 역어셈블하여 기계어(16진수)와 명령어를 나란히 본다
dis: asm_demo.o
	objdump -d asm_demo.o

asm_demo.o: asm_demo.c
	$(CC) $(CFLAGS) -c -o $@ $<

# A64 명령어의 기계어 확인 (Pi의 기본 어셈블러 사용)
enc: enc_a64.s
	as -o enc_a64.o enc_a64.s
	objdump -d enc_a64.o

# (선택) A32 명령어의 기계어 확인: sudo apt install binutils-arm-linux-gnueabihf
enc32: enc_a32.s
	arm-linux-gnueabihf-as -o enc_a32.o enc_a32.s
	arm-linux-gnueabihf-objdump -d enc_a32.o

clean:
	rm -f endian asm_demo asm_demo.o asm_demo.s enc_a64.o enc_a32.o
