CC      = gcc
CFLAGS  = -Wall -O2
# pigpio C 라이브러리(직접 하드웨어 접근, sudo 실행, pigpiod는 꺼 둔다)
LIBS    = -lpigpio -lrt -pthread

PROGS = toggle_max pad_strength pwm_measure uart_send i2c_probe spi_send latency_echo

.PHONY: all clean

all: $(PROGS)

$(PROGS): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	rm -f $(PROGS)
