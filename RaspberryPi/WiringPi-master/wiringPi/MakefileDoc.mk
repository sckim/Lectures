#################################################################################
# wiringPi 라이브러리를 위한 Makefile
# 이 파일은 wiringPi 라이브러리를 컴파일하고 설치하는 과정을 자동화합니다.
#################################################################################

# 버전 정보를 ../VERSION 파일에서 읽어옴
VERSION=$(shell cat ../VERSION)
# 설치될 기본 디렉토리 경로 (/usr)
DESTDIR?=/usr
# 설치될 하위 디렉토리 (/local)
PREFIX?=/local

# 라이브러리 캐시 업데이트 명령
LDCONFIG?=ldconfig

# 빌드 출력 제어 (자세한 출력을 보려면 V=1로 설정)
ifneq ($V,1)
Q ?= @
endif

# 생성될 라이브러리 파일명
STATIC=libwiringPi.a            # 정적 라이브러리
DYNAMIC=libwiringPi.so.$(VERSION)   # 동적 라이브러리

# 컴파일러 최적화 옵션
#DEBUG = -g -O0    # 디버깅용 (최적화 없음)
DEBUG = -O2        # 릴리즈용 (최적화 레벨 2)

# 사용할 컴파일러 지정 (기본값: gcc)
CC  ?= gcc

# 컴파일러 옵션 설정
INCLUDE = -I.                  # 헤더 파일 검색 경로
DEFS    = -D_GNU_SOURCE       # GNU 확장 기능 활성화
CFLAGS  = $(DEBUG) $(DEFS) -Wformat=2 -Wall -Wextra -Winline $(INCLUDE) -pipe -fPIC $(EXTRA_CFLAGS)
#CFLAGS	= $(DEBUG) $(DEFS) -Wformat=2 -Wall -Wextra -Wconversion -Winline $(INCLUDE) -pipe -fPIC

# -Wall: 모든 경고 활성화
# -Wextra: 추가 경고 활성화
# -Winline: 인라인 함수 관련 경고
# -pipe: 파이프 사용하여 컴파일 속도 향상
# -fPIC: 위치 독립적 코드 생성

# 링크할 라이브러리들 (build할 때 필요한 외부 라이브러리)
LIBS    = -lm -lpthread -lrt -lcrypt

###############################################################################
# 컴파일할 소스 파일 목록
SRC     =   SRC     =   wiringPi.c            \  # 기본 GPIO 함수
            wiringSerial.c wiringShift.c      \  # 시리얼 통신과 시프트 레지스터
            piHiPri.c piThread.c              \  # 우선순위와 스레드 관리
            wiringPiSPI.c wiringPiI2C.c       \  # SPI, I2C 통신
            softPwm.c softTone.c              \  # 소프트웨어 PWM과 톤 생성
            mcp23008.c mcp23016.c mcp23017.c  \  # MCP230xx I2C GPIO 확장칩 드라이버
            mcp23s08.c mcp23s17.c             \  # MCP23Sxx SPI GPIO 확장칩 드라이버
            sr595.c                           \  # 74HC595 시프트 레지스터 드라이버
            pcf8574.c pcf8591.c               \  # PCF8574 I2C GPIO / PCF8591 ADC/DAC
            mcp3002.c mcp3004.c               \  # MCP3002/3004 SPI ADC 드라이버
            mcp4802.c mcp3422.c               \  # MCP4802 DAC / MCP3422 ADC 드라이버
            max31855.c max5322.c              \  # MAX31855 온도센서 / MAX5322 DAC
            ads1115.c                         \  # ADS1115 16비트 ADC 드라이버
            sn3218.c                          \  # SN3218 LED 드라이버
            bmp180.c                          \  # BMP180 기압/온도 센서
            htu21d.c                          \  # HTU21D 습도/온도 센서
            ds18b20.c                         \  # DS18B20 온도 센서
            rht03.c                           \  # RHT03 습도/온도 센서
            drcSerial.c drcNet.c              \  # DRC 시리얼/네트워크 통신
            pseudoPins.c                      \  # 가상 GPIO 핀 구현
            wpiExtensions.c                   \  # wiringPi 확장 기능 관리
            wiringPiLegacy.c                  \  # 레거시 기능 지원

# 헤더 파일 목록
HEADERS = $(shell ls *.h)

# 오브젝트 파일 목록 (.c를 .o로 변경)
OBJ     = $(SRC:.c=.o)

# 기본 타겟: 동적 라이브러리 생성
all:        $(DYNAMIC)

# 정적 라이브러리 빌드를 더 이상 지원하지 않음을 알림
.PHONY: static
static:     
   $Q cat noMoreStatic

# 동적 라이브러리(.so) 생성 규칙
# $(OBJ) 파일들을 링크하여 공유 라이브러리 생성
$(DYNAMIC): $(OBJ)
   $Q echo "[Link (Dynamic)]"
   $Q $(CC) -shared -Wl,-soname,libwiringPi.so$(WIRINGPI_SONAME_SUFFIX) -o libwiringPi.so.$(VERSION) $(OBJ) $(LIBS)

# .c 파일을 .o 파일로 컴파일하는 규칙
# $<는 첫 번째 전제조건(소스 파일)을 의미
.c.o:
   $Q echo [Compile] $
   $Q $(CC) -c $(CFLAGS) $< -o $@

# 생성된 파일들을 정리하는 clean 규칙
.PHONY: clean
clean:
   $Q echo "[Clean]"
   $Q rm -f $(OBJ) $(OBJ_I2C) *~ core tags Makefile.bak libwiringPi.*

# 소스 코드의 태그 파일 생성 (코드 탐색용)
.PHONY: tags
tags: $(SRC)
   $Q echo [ctags]
   $Q ctags $(SRC)

# 라이브러리 설치 규칙
.PHONY: install
install: $(DYNAMIC)
   # 헤더 파일 설치
   $Q echo "[Install Headers]"
   $Q install -m 0755 -d                      $(DESTDIR)$(PREFIX)/include
   $Q install -m 0644 $(HEADERS)              $(DESTDIR)$(PREFIX)/include
   # 라이브러리 파일 설치
   $Q echo "[Install Dynamic Lib]"
   $Q install -m 0755 -d                      $(DESTDIR)$(PREFIX)/lib
   $Q install -m 0755 libwiringPi.so.$(VERSION)   $(DESTDIR)$(PREFIX)/lib/libwiringPi.so.$(VERSION)
   # 심볼릭 링크 생성
   $Q ln -sf $(DESTDIR)$(PREFIX)/lib/libwiringPi.so.$(VERSION)    $(DESTDIR)/lib/libwiringPi.so
   $Q $(LDCONFIG)

# Debian 패키지 설치 디렉토리 확인
.PHONY: check-deb-destdir
check-deb-destdir:
ifndef DEB_DESTDIR
   $(error DEB_DESTDIR is undefined)
endif

# Debian 패키지용 설치 규칙
.PHONY: install-deb
install-deb: $(DYNAMIC) check-deb-destdir
   # Debian 패키지용 헤더 파일 설치
   $Q echo "[Install Headers: deb]"
   $Q install -m 0755 -d                      $(DEB_DESTDIR)/usr/include
   $Q install -m 0644 $(HEADERS)              $(DEB_DESTDIR)/usr/include
   # Debian 패키지용 라이브러리 파일 설치
   $Q echo "[Install Dynamic Lib: deb]"
   install -m 0755 -d                         $(DEB_DESTDIR)/usr/lib
   install -m 0755 libwiringPi.so.$(VERSION)      $(DEB_DESTDIR)/usr/lib/libwiringPi.so.$(VERSION)
   ln -sf $(DEB_DESTDIR)/usr/lib/libwiringPi.so.$(VERSION)    $(DEB_DESTDIR)/usr/lib/libwiringPi.so

# 라이브러리 제거 규칙
.PHONY: uninstall
uninstall:
   $Q echo "[UnInstall]"
   $Q cd $(DESTDIR)$(PREFIX)/include/ && rm -f $(HEADERS)
   $Q cd $(DESTDIR)$(PREFIX)/lib/     && rm -f libwiringPi.*
   $Q $(LDCONFIG)

# 의존성 생성 규칙
# makedepend 도구를 사용하여 소스 파일의 의존성 정보 생성
.PHONY: depend
depend:
   makedepend -Y $(SRC) $(SRC_I2C)

# 의존성 정보 (어떤 헤더 파일이 변경되었을 때 다시 컴파일해야 하는지)
wiringPi.o: softPwm.h softTone.h wiringPi.h ../version.h
wiringSerial.o: wiringSerial.h
wiringShift.o: wiringPi.h wiringShift.h
piHiPri.o: wiringPi.h
piThread.o: wiringPi.h
wiringPiSPI.o: wiringPi.h wiringPiSPI.h
wiringPiI2C.o: wiringPi.h wiringPiI2C.h
softPwm.o: wiringPi.h softPwm.h
softTone.o: wiringPi.h softTone.h
mcp23008.o: wiringPi.h wiringPiI2C.h mcp23x0817.h mcp23008.h
mcp23016.o: wiringPi.h wiringPiI2C.h mcp23016.h mcp23016reg.h
mcp23017.o: wiringPi.h wiringPiI2C.h mcp23x0817.h mcp23017.h
mcp23s08.o: wiringPi.h wiringPiSPI.h mcp23x0817.h mcp23s08.h
mcp23s17.o: wiringPi.h wiringPiSPI.h mcp23x0817.h mcp23s17.h
sr595.o: wiringPi.h sr595.h
pcf8574.o: wiringPi.h wiringPiI2C.h pcf8574.h
pcf8591.o: wiringPi.h wiringPiI2C.h pcf8591.h
mcp3002.o: wiringPi.h wiringPiSPI.h mcp3002.h
mcp3004.o: wiringPi.h wiringPiSPI.h mcp3004.h
mcp4802.o: wiringPi.h wiringPiSPI.h mcp4802.h
mcp3422.o: wiringPi.h wiringPiI2C.h mcp3422.h
max31855.o: wiringPi.h wiringPiSPI.h max31855.h
max5322.o: wiringPi.h wiringPiSPI.h max5322.h
ads1115.o: wiringPi.h wiringPiI2C.h ads1115.h
sn3218.o: wiringPi.h wiringPiI2C.h sn3218.h
bmp180.o: wiringPi.h wiringPiI2C.h bmp180.h
htu21d.o: wiringPi.h wiringPiI2C.h htu21d.h
ds18b20.o: wiringPi.h ds18b20.h
drcSerial.o: wiringPi.h wiringSerial.h drcSerial.h
pseudoPins.o: wiringPi.h pseudoPins.h
wpiExtensions.o: wiringPi.h mcp23008.h mcp23016.h mcp23017.h mcp23s08.h
wpiExtensions.o: mcp23s17.h sr595.h pcf8574.h pcf8591.h mcp3002.h mcp3004.h
wpiExtensions.o: mcp4802.h mcp3422.h max31855.h max5322.h ads1115.h sn3218.h
wpiExtensions.o: drcSerial.h pseudoPins.h bmp180.h htu21d.h ds18b20.h
wpiExtensions.o: wpiExtensions.h