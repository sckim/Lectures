# 부록 B  WiringPi 예제의 pigpio 대응판 빌드
#   make            : pigpio 판 전부 (sudo로 실행, pigpiod가 떠 있으면 먼저 멈춘다)
#   make variants   : 컴파일 옵션을 바꾼 판 (isr_pigpio_isr, softTone_dma)
#   make gpiod      : libgpiod 판 (sudo apt install libgpiod-dev 필요)
#   wiringpi/ 폴더의 원본은 참고용이라 빌드하지 않는다(WiringPi 미설치 가정).
#   8장 대응판(led_blink, button_led, led_sweep)은 ../ch08 에서 빌드한다.

CC          = gcc
CFLAGS      = -Wall -O2
LIBS_PIGPIO = -lpigpio -lrt -pthread
LIBS_GPIOD  = -lgpiod

PROGS = blink8_pigpio blink12_pigpio blink_thread_pigpio blink_thread2_pigpio \
        sharedCounter_pigpio semaphore_led_pigpio pullupdown_pigpio speed_pigpio \
        readall_pigpio isr_pigpio wiringPiISR_pigpio serialTest_pigpio \
        serialTest2_pigpio pwm1_pigpio softpwm_pigpio softTone_pigpio \
        dht11_pigpio rht03_pigpio
VARIANTS = isr_pigpio_isr softTone_dma
GPIOD    = led_blink_gpiod

.PHONY: all variants gpiod clean

all: $(PROGS)

variants: $(VARIANTS)

gpiod: $(GPIOD)

$(PROGS): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_PIGPIO)

isr_pigpio_isr: isr_pigpio.c
	$(CC) $(CFLAGS) -DUSE_ISR -o $@ $< $(LIBS_PIGPIO)

softTone_dma: softTone_pigpio.c
	$(CC) $(CFLAGS) -DUSE_DMA_PWM -o $@ $< $(LIBS_PIGPIO)

$(GPIOD): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_GPIOD)

clean:
	rm -f $(PROGS) $(VARIANTS) $(GPIOD)
