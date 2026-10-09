/*
 * isr_pigpio.c : 부록 B  입력 핀의 하강 에지를 콜백으로 세기 (기본: BTN0 하나)
 *
 * 회로 : BTN0 = GPIO26 (물리 핀 37) -- 버튼 -- GND (물리 핀 39), 내부 풀업
 *        누르는 순간이 하강 에지(1 -> 0)이다. 버튼이 없으면 아래 "시험"처럼
 *        내부 풀업/풀다운을 바꿔 에지를 만든다.
 * 빌드 : gcc -Wall -pthread -o isr_pigpio isr_pigpio.c -lpigpio -lrt
 *        gcc -Wall -pthread -DUSE_ISR -o isr_pigpio_isr isr_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./isr_pigpio
 * 시험 : 다른 터미널에서 (pigs는 pigpiod가 필요해 이 프로그램과 함께 쓸 수 없다)
 *            pinctrl set 26 pd      # 풀다운 -> 하강 에지 (Int on GPIO26)
 *            pinctrl set 26 pu      # 풀업  -> 상승 에지 (세지 않음)
 *
 * 원본 : wiringpi/isr.c (Raspberry Pi Codes §4.4.1)
 *        wiringPiISR(pin, INT_EDGE_FALLING, &myInterruptN)  x 8
 *          -> gpioSetAlertFunc(gpio, on_edge)  x 핀 수  (콜백 하나가 gpio 인자로 핀을 구별)
 *        핀: 원본은 wPi 0~7(GPIO17,18,27,22,23,24,25,4) 8개를 풀다운 입력으로 썼다.
 *            교재 표준 배선에서 그 핀들은 LED 바·PWM·DHT 자리이고 입력은 BTN0 하나뿐이므로
 *            pins[]에 BTN0만 둔다. 콜백 하나가 gpio 인자로 여러 핀을 구별하는 구조는
 *            그대로 두었다(pins[]의 원소 수가 곧 감시하는 핀 수이다).
 *        고친 점: 원본 main은 바쁜 대기(busy loop)로 CPU 한 코어를 100% 쓴다.
 *                 여기서는 10 ms마다 확인한다.
 *
 * 두 가지 방식
 *   기본      gpioSetAlertFunc : pigpio가 DMA로 GPIO 레벨을 5 us마다 샘플링하고,
 *             바뀐 것을 콜백으로 알려 준다. 모든 변화(상승·하강)가 오므로 level로 거른다.
 *             gpioGlitchFilter로 디바운스할 수 있다.
 *   -DUSE_ISR gpioSetISRFunc   : 커널 GPIO 인터럽트(sysfs edge)를 쓴다. 지정한 에지만 온다.
 *             pigpio v79는 sysfs 번호를 BCM 번호 그대로 쓰므로, sysfs 번호에
 *             오프셋(예: 512)이 붙는 최신 커널에서는 등록이 실패할 수 있다(실기 확인 필요).
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

/* 감시할 입력 핀 (BCM). 기본은 BTN0 하나 */
static const unsigned pins[] = { 26 };
#define N_PINS       (sizeof(pins) / sizeof(pins[0]))
#define DEBOUNCE_US  1000                /* 1 ms 이상 유지된 변화만 인정 */

static volatile int globalCounter[N_PINS];   /* 콜백 스레드가 쓰고 main이 읽는다 */
static int index_of[32];                 /* BCM 번호 -> pins[] 인덱스 */
static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 모든 핀이 이 함수 하나를 콜백으로 쓴다. gpio 인자로 어느 핀인지 안다. */
static void on_edge(int gpio, int level, uint32_t tick)
{
    (void)tick;
    if (level == 0)                      /* 0 = 하강 에지 (1 = 상승, 2 = 타임아웃) */
        ++globalCounter[index_of[gpio]];
}

int main(void)
{
    int myCounter[N_PINS] = {0};
    unsigned i;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    for (i = 0; i < N_PINS; i++) {
        index_of[pins[i]] = i;
        gpioSetMode(pins[i], PI_INPUT);
        gpioSetPullUpDown(pins[i], PI_PUD_UP);   /* 원본 PUD_DOWN -> 풀업(active-low) */
#ifdef USE_ISR
        if (gpioSetISRFunc(pins[i], FALLING_EDGE, 0, on_edge) != 0)
            fprintf(stderr, "GPIO%u: gpioSetISRFunc 실패 (sysfs 번호 문제일 수 있음)\n", pins[i]);
#else
        gpioGlitchFilter(pins[i], DEBOUNCE_US);
        gpioSetAlertFunc(pins[i], on_edge);
#endif
    }

    printf("Waiting ... (Ctrl+C로 종료)\n");
    while (running) {
        for (i = 0; i < N_PINS; i++) {
            int now = globalCounter[i];
            if (now != myCounter[i]) {
                printf(" Int on GPIO%-2u: Counter: %5d\n", pins[i], now);
                myCounter[i] = now;
            }
        }
        gpioDelay(10000);                /* 10 ms: 바쁜 대기 대신 잠깐 쉰다 */
    }

    for (i = 0; i < N_PINS; i++) {       /* 콜백 해제 */
#ifdef USE_ISR
        gpioSetISRFunc(pins[i], FALLING_EDGE, 0, NULL);
#else
        gpioSetAlertFunc(pins[i], NULL);
#endif
    }
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
