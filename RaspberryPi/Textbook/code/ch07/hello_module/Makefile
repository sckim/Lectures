# Makefile : 실습 7-4  커널 모듈(hello.ko) 빌드
# Pi에서      : make            (지금 실행 중인 커널의 헤더 /lib/modules/$(uname -r)/build 사용)
# 다른 커널용 : make KDIR=~/rpi-kernel/linux ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
# 정리        : make clean

obj-m := hello.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
