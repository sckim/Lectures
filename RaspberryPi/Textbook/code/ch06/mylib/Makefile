# 실습 6-3  정적 라이브러리(libmylib.a)와 공유 라이브러리(libmylib.so) 만들기
CC     = gcc
CFLAGS = -Wall -O2

.PHONY: all clean

all: main_static main_shared main_rpath

# ---- 정적 라이브러리: 목적 파일을 ar로 묶은 "보관함(archive)" ----
mathutil.o: mathutil.c mathutil.h
	$(CC) $(CFLAGS) -c mathutil.c -o $@

libmylib.a: mathutil.o
	ar rcs $@ $^

# ---- 공유 라이브러리: 위치 독립 코드(-fPIC)로 컴파일한 뒤 -shared로 링크 ----
mathutil.pic.o: mathutil.c mathutil.h
	$(CC) $(CFLAGS) -fPIC -c mathutil.c -o $@

libmylib.so: mathutil.pic.o
	$(CC) -shared -o $@ $^

# ---- 사용하는 프로그램 ----
# 같은 폴더에 .a와 .so가 함께 있으면 -lmylib은 .so를 고른다.
# 정적 라이브러리를 확실히 쓰려고 -l:libmylib.a 로 파일 이름을 직접 지정했다.
main_static: main.c mathutil.h libmylib.a
	$(CC) $(CFLAGS) -o $@ main.c -L. -l:libmylib.a

# 실행할 때 LD_LIBRARY_PATH=. 가 필요하다
main_shared: main.c mathutil.h libmylib.so
	$(CC) $(CFLAGS) -o $@ main.c -L. -lmylib

# rpath: 실행 파일 안에 "라이브러리는 실행 파일과 같은 폴더($ORIGIN)에 있다"고 적어 둔다
main_rpath: main.c mathutil.h libmylib.so
	$(CC) $(CFLAGS) -o $@ main.c -L. -lmylib -Wl,-rpath,'$$ORIGIN'

clean:
	rm -f *.o libmylib.a libmylib.so main_static main_shared main_rpath
