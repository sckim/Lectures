CC      = gcc
CFLAGS  = -Wall -O2
# pigpio C 라이브러리(직접 하드웨어 접근, sudo 실행)
LIBS_PIGPIO = -lpigpio -lrt -pthread
# pigpiod 데몬 클라이언트(sudo 불필요, 데몬 필요)
LIBS_IF2    = -lpigpiod_if2 -lrt -pthread

DIRECT = led_blink button_led led_sweep
CLIENT = led_blink_if2

.PHONY: all clean

all: $(DIRECT) $(CLIENT)

$(DIRECT): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_PIGPIO)

$(CLIENT): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_IF2)

clean:
	rm -f $(DIRECT) $(CLIENT)
