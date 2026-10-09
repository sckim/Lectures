# 9장  pigpio 심화 예제 빌드
#   make        : C 예제 전부 (모두 -lpigpio 직접 접근 -> sudo로 실행, pigpiod는 꺼 둔다)
#   make check  : 셸·파이썬 스크립트 문법 검사 (bash -n, python3 -m py_compile)
#   make clean  : 실행 파일 삭제
#   pwm_fade.sh, remote_button.py 는 pigpiod 데몬 클라이언트라 빌드하지 않는다.

CC          = gcc
CFLAGS      = -Wall -O2
LIBS_PIGPIO = -lpigpio -lrt -pthread

PROGS = button_poll button_alert debounce_test hwpwm_sweep servo_sweep \
        hcsr04 wave_pulse
MATH  = led_fade

.PHONY: all check clean

all: $(PROGS) $(MATH)

$(PROGS): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_PIGPIO)

# pow(), lround()를 쓰므로 수학 라이브러리(-lm)를 추가로 링크한다
$(MATH): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_PIGPIO) -lm

check:
	bash -n pwm_fade.sh
	python3 -m py_compile remote_button.py

clean:
	rm -f $(PROGS) $(MATH)
	rm -rf __pycache__
