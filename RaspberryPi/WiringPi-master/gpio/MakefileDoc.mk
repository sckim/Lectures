# gpio 프로그램을 빌드하기 위한 Makefile

# 설치 디렉토리 설정
DESTDIR?=/usr         # 기본 설치 경로 /usr
PREFIX?=/local        # 하위 설치 경로 /local (결과적으로 /usr/local)

# 빌드 출력 제어 (V=1로 설정하면 자세한 출력을 볼 수 있음)
ifneq ($V,1)
Q ?= @                # @ 기호는 명령어를 화면에 출력하지 않도록 함
endif

# 컴파일러 최적화 옵션
#DEBUG = -g -O0      # 디버깅용 (최적화 없음, 디버그 정보 포함)
DEBUG = -O2          # 릴리즈용 (최적화 레벨 2)

# 컴파일러 설정
CC ?= gcc           # 기본 컴파일러로 gcc 사용
INCLUDE = -I$(DESTDIR)$(PREFIX)/include    # 헤더 파일을 찾을 경로 지정
# 컴파일러 플래그 설정
CFLAGS = $(DEBUG) -Wall -Wextra $(INCLUDE) -Winline -pipe $(EXTRA_CFLAGS)
# -Wall: 모든 경고 메시지 표시
# -Wextra: 추가 경고 메시지
# -Winline: 인라인 함수 관련 경고
# -pipe: 파이프 사용하여 컴파일 속도 향상

# 링커 설정
LDFLAGS = -L$(DESTDIR)$(PREFIX)/lib    # 라이브러리 파일을 찾을 경로
# 필요한 라이브러리 목록
LIBS = -lwiringPi -lwiringPiDev -lpthread -lrt -lm -lcrypt
# -lwiringPi: wiringPi 라이브러리
# -lwiringPiDev: wiringPi 장치 라이브러리
# -lpthread: POSIX 스레드 라이브러리
# -lrt: 실시간 확장 라이브러리
# -lm: 수학 라이브러리
# -lcrypt: 암호화 라이브러리

###############################################################################
# 소스 파일 목록
SRC = gpio.c readall.c    # 컴파일할 소스 파일들

# 오브젝트 파일 목록 (.c를 .o로 변경)
OBJ = $(SRC:.c=.o)       # gpio.c → gpio.o, readall.c → readall.o

# 기본 타겟: gpio 프로그램 빌드
all: gpio

# 버전 정보 파일 생성
version.h: ../VERSION
   $Q echo Need to run newVersion above.

# gpio 실행 파일 생성 규칙
gpio: $(OBJ)
   $Q echo [Link]
   $Q $(CC) -o $@ $(OBJ) $(LDFLAGS) $(LIBS)

# .c 파일을 .o 파일로 컴파일하는 규칙
.c.o:
   $Q echo [Compile] $
   $Q $(CC) -c $(CFLAGS) $< -o $@

# 청소 규칙: 생성된 파일들 삭제
.PHONY: clean
clean:
   $Q echo "[Clean]"
   $Q rm -f $(OBJ) gpio *~ core tags *.bak

# 소스 코드 태그 파일 생성 (개발용)
.PHONY: tags
tags: $(SRC)
   $Q echo [ctags]
   $Q ctags $(SRC)

# gpio 프로그램 설치
.PHONY: install
install: gpio
   $Q echo "[Install]"
   # 실행 파일 설치
   $Q mkdir -p        $(DESTDIR)$(PREFIX)/bin
   $Q cp gpio        $(DESTDIR)$(PREFIX)/bin
# root 권한 설정 (WIRINGPI_SUID가 0이 아닌 경우)
ifneq ($(WIRINGPI_SUID),0)
   $Q chown root:root    $(DESTDIR)$(PREFIX)/bin/gpio
   $Q chmod 4755        $(DESTDIR)$(PREFIX)/bin/gpio
endif
   # 매뉴얼 페이지 설치
   $Q mkdir -p        $(DESTDIR)$(PREFIX)/share/man/man1
   $Q cp gpio.1        $(DESTDIR)$(PREFIX)/share/man/man1

# Debian 패키지 설치 디렉토리 확인
.PHONY: check-deb-destdir
check-deb-destdir:
ifndef DEB_DESTDIR
   $(error DEB_DESTDIR is undefined)
endif

# Debian 패키지용 설치
.PHONY: install-deb
install-deb: gpio check-deb-destdir
   $Q echo "[Install: deb]"
   # Debian 패키지용 실행 파일 및 매뉴얼 설치
   $Q install -m 0755 -d                            $(DEB_DESTDIR)/usr/bin
   $Q install -m 0755 gpio                          $(DEB_DESTDIR)/usr/bin
   $Q install -m 0755 -d                            $(DEB_DESTDIR)/usr/share/man/man1
   $Q install -m 0644 gpio.1                        $(DEB_DESTDIR)/usr/share/man/man1

# 프로그램 제거
.PHONY: uninstall
uninstall:
   $Q echo "[UnInstall]"
   $Q rm -f $(DESTDIR)$(PREFIX)/bin/gpio
   $Q rm -f $(DESTDIR)$(PREFIX)/share/man/man1/gpio.1

# 의존성 생성
.PHONY: depend
depend:
   makedepend -Y $(SRC)

# 의존성 정보 (자동 생성됨)
gpio.o: ../version.h