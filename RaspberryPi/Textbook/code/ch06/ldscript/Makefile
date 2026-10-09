# 6.7절  링커 스크립트 실험 (OS 없는 펌웨어를 흉내 낸 배치만 관찰한다)
CC      = gcc
LD      = ld
OBJDUMP = objdump
NM      = nm
# -ffreestanding: 표준 라이브러리가 없다고 가정  -fno-pic: 절대 주소로 배치
CFLAGS  = -O1 -ffreestanding -fno-pic -fno-asynchronous-unwind-tables

.PHONY: all show clean

all: show

bare.o: bare.c
	$(CC) $(CFLAGS) -c $< -o $@

bare.elf: bare.o bare.ld
	$(LD) -T bare.ld -o $@ bare.o

show: bare.elf
	$(OBJDUMP) -h bare.elf
	$(NM) -n bare.elf

clean:
	rm -f bare.o bare.elf
