# 11장  프로세스와 동시성 실습 빌드
#   make          : 전부 (Raspberry Pi에서. pigpio 판은 sudo로 실행)
#   make host     : GPIO를 쓰지 않는 예제만 (PC의 WSL/Linux에서도 빌드·실행 가능)
#   make gpio     : pigpio 예제만 (semaphore_led, button_queue, periodic_gpio)
#   make tsan     : ThreadSanitizer로 race condition을 찾아내는 판 (shared_counter_tsan)
#   make membug   : 메모리 실수 예제 (uaf, leak). valgrind --leak-check=full ./uaf 로 검사
#   make asan     : AddressSanitizer 판 (uaf_asan, leak_asan)
#   make asm      : shared_counter의 세 판을 어셈블리(.s)로 (count++가 몇 개의 명령어인지 보기)
#   make clean    : 만든 파일 지우기

CC          = gcc
CFLAGS      = -Wall -O2
THREADS     = -pthread
LIBS_PIGPIO = -lpigpio -lrt -pthread

# 주소·스택 관찰용: 최적화하면 함수가 합쳐지거나 재귀가 반복문이 되어 관찰이 어렵다
O0_PROGS = memory_layout stack_overflow
PROC     = process_demo fork_exec zombie pipe_demo
THR      = thread_args deadlock semaphore_basic prodcons periodic_jitter
COUNTER  = shared_counter shared_counter_mutex shared_counter_atomic
GPIO     = semaphore_led button_queue periodic_gpio
# 메모리 실수 예제: 줄 번호가 보이도록 -g, 최적화가 실수를 지우지 않도록 -O0
MEMBUG   = uaf leak

HOST = $(O0_PROGS) $(PROC) $(THR) $(COUNTER)

.PHONY: all host gpio tsan membug asan asm clean

all: host gpio

host: $(HOST)

gpio: $(GPIO)

$(O0_PROGS): %: %.c
	$(CC) -Wall -O0 -o $@ $<

$(PROC): %: %.c
	$(CC) $(CFLAGS) -o $@ $<

$(THR): %: %.c
	$(CC) $(CFLAGS) $(THREADS) -o $@ $<

shared_counter: shared_counter.c
	$(CC) $(CFLAGS) $(THREADS) -o $@ $<

shared_counter_mutex: shared_counter.c
	$(CC) $(CFLAGS) $(THREADS) -DUSE_MUTEX -o $@ $<

shared_counter_atomic: shared_counter.c
	$(CC) $(CFLAGS) $(THREADS) -DUSE_ATOMIC -o $@ $<

tsan: shared_counter_tsan

shared_counter_tsan: shared_counter.c
	$(CC) -Wall -O1 -g -fsanitize=thread $(THREADS) -o $@ $<

membug: $(MEMBUG)

$(MEMBUG): %: %.c
	$(CC) -Wall -g -O0 -o $@ $<

asan: uaf_asan leak_asan

%_asan: %.c
	$(CC) -Wall -g -O0 -fsanitize=address -o $@ $<

asm: shared_counter.c
	$(CC) $(CFLAGS) -S -fno-asynchronous-unwind-tables -fno-unwind-tables -o shared_counter.s $<
	$(CC) $(CFLAGS) -S -fno-asynchronous-unwind-tables -fno-unwind-tables -DUSE_MUTEX -o shared_counter_mutex.s $<
	$(CC) $(CFLAGS) -S -fno-asynchronous-unwind-tables -fno-unwind-tables -DUSE_ATOMIC -o shared_counter_atomic.s $<

$(GPIO): %: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS_PIGPIO)

clean:
	rm -f $(HOST) $(GPIO) shared_counter_tsan $(MEMBUG) uaf_asan leak_asan *.s
