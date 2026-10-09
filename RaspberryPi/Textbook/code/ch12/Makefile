CC      = gcc
CFLAGS  = -Wall -O2
# pigpio C 라이브러리(직접 하드웨어 접근, sudo 실행, pigpiod는 꺼 둔다)
LIBS_PIGPIO = -lpigpio -lrt -pthread

# pigpio를 쓰는 실습 프로그램
PIGPIO = uart_loopback uart_cmd i2c_scan lcd_pcf8574 ds3231_rtc \
         mcp3008_adc ds1302_rtc bmp280
# 비교용: 커널 인터페이스(termios, i2c-dev, spidev)만 쓰는 프로그램 (sudo 불필요)
KERNEL = uart_termios i2c_dev_ds3231 mcp3008_spidev

.PHONY: all clean

all: $(PIGPIO) $(KERNEL)

$(PIGPIO): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_PIGPIO)

$(KERNEL): %: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(PIGPIO) $(KERNEL)
