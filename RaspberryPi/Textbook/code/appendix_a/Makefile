# 부록 A  실습 A-3(MATLAB Coder 생성 코드 + main.c), 실습 A-6(필터 C 구현)
#
#   make          filter_demo 빌드 (MATLAB 없이 바로 된다)
#   make ma       bio_signal_processor 빌드 (codegen/lib/moving_average 폴더가 있어야 한다)
#   make clean    실행 파일과 결과 파일 삭제

CC     = gcc
CFLAGS = -Wall -O2
LDLIBS = -lm

# MATLAB Coder가 만든 소스 폴더. 그 안의 .c를 모두 모은다(examples/ 하위 폴더는 제외됨)
GEN     = codegen/lib/moving_average
GEN_SRC = $(wildcard $(GEN)/*.c)

.PHONY: all ma clean

all: filter_demo

filter_demo: filter_demo.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

ma: bio_signal_processor

bio_signal_processor: main.c $(GEN_SRC)
	@test -d $(GEN) || { echo "$(GEN) 폴더가 없다. PC에서 build_ma.m을 실행해 만든 뒤 복사하라."; exit 1; }
	$(CC) $(CFLAGS) -I$(GEN) -o $@ main.c $(GEN_SRC) $(LDLIBS)

clean:
	rm -f filter_demo bio_signal_processor filter_out.csv signal_output.log
