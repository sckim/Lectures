/*
 * wiringPiISR_pigpio.c : 부록 B  wiringPiISR()의 내부 구조(핸들러 스레드 + 대기)를 pigpio로 재현
 *
 * 회로 : BTN0 = GPIO26 (물리 핀 37) -- 버튼 -- GND (물리 핀 39), 내부 풀업
 *        누르는 순간이 하강 에지이다(isr.c의 wPi 0 = GPIO17·풀다운 대신 교재 표준 BTN0을 쓴다).
 *        버튼 없이 시험: 다른 터미널에서  pinctrl set 26 pd  /  pinctrl set 26 pu
 * 빌드 : gcc -Wall -pthread -o wiringPiISR_pigpio wiringPiISR_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./wiringPiISR_pigpio
 *
 * 원본 : wiringpi/wiringPiISR.c (Raspberry Pi Codes §4.4.2, 라이브러리 내부 코드 발췌)
 *   원본의 구조
 *     wiringPiISR(pin, mode, f)
 *       1) "gpio edge <pin> falling"으로 sysfs에 에지를 설정하고 value 파일을 연다
 *       2) 핸들러 스레드를 만든다
 *     interruptHandler 스레드
 *       for (;;) if (waitForInterrupt(pin, -1) > 0) f();   <- poll()로 잠들어 있다가 깨어남
 *   원본 발췌본의 문제
 *     - pthread_create(..., &pin): 함수의 지역 변수(인자) pin의 주소를 넘긴다.
 *       wiringPiISR가 먼저 반환하면 스레드가 읽을 때 그 메모리는 이미 다른 용도로
 *       쓰일 수 있다. (원 WiringPi 2.x는 뮤텍스와 전역 변수로 이 문제를 피했다)
 *     - 끝부분이 잘려 있고 modes, fName 선언이 없어 컴파일되지 않는다.
 *
 * 이 파일의 구조 (같은 생각을 pigpio로)
 *     my_wiringPiISR(gpio, edge, f)
 *       1) gpioSetAlertFunc(gpio, on_alert) : pigpio가 에지를 감지해 on_alert를 부른다
 *       2) 핸들러 스레드를 만든다. 인자는 전역(static) 배열 원소의 주소 -> 수명 문제 없음
 *     on_alert (pigpio의 콜백 스레드)
 *       원하는 에지이면 pending++ 후 조건 변수로 핸들러 스레드를 깨운다
 *     handler 스레드
 *       wait_for_edge()로 잠들어 있다가 깨어나 사용자 함수 f()를 부른다
 *   이렇게 하면 사용자 함수가 오래 걸려도 pigpio의 콜백 스레드를 막지 않는다.
 *
 *   pigpio에는 이 일을 한 번에 해 주는 gpioSetISRFunc()도 있다(내부에서 sysfs와
 *   poll 스레드를 쓴다. isr_pigpio.c -DUSE_ISR 참고).
 *   원본의 piHiPri(55)는 pthread_setschedparam(SCHED_FIFO)로 바꿀 수 있다(11장).
 */
#include <stdio.h>
#include <signal.h>
#include <pthread.h>
#include <pigpio.h>

#define BUTTON_GPIO  26                  /* BTN0, 물리 핀 37 */

struct isr_slot {
    unsigned gpio;
    unsigned edge;                       /* RISING_EDGE, FALLING_EDGE, EITHER_EDGE */
    void (*func)(void);
    unsigned pending;                    /* 아직 처리하지 않은 에지 수 */
    pthread_mutex_t lock;
    pthread_cond_t cond;
    pthread_t thread;
    int used;
};

static struct isr_slot slots[32];        /* BCM 0~31, 프로그램 끝까지 살아 있다 */
static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* pigpio의 알림 스레드에서 불린다. 짧게 끝내야 한다. */
static void on_alert(int gpio, int level, uint32_t tick)
{
    struct isr_slot *s = &slots[gpio];
    int want;

    (void)tick;
    if (level == PI_TIMEOUT)
        return;
    want = (s->edge == EITHER_EDGE) ||
           (s->edge == RISING_EDGE  && level == 1) ||
           (s->edge == FALLING_EDGE && level == 0);
    if (!want)
        return;

    pthread_mutex_lock(&s->lock);
    s->pending++;
    pthread_cond_signal(&s->cond);       /* 핸들러 스레드 깨우기 */
    pthread_mutex_unlock(&s->lock);
}

/* waitForInterrupt()에 해당: 에지가 올 때까지 잠든다. 종료 요청이면 0 */
static int wait_for_edge(struct isr_slot *s)
{
    int got = 0;

    pthread_mutex_lock(&s->lock);
    while (s->pending == 0 && running)
        pthread_cond_wait(&s->cond, &s->lock);
    if (s->pending > 0) {
        s->pending--;
        got = 1;
    }
    pthread_mutex_unlock(&s->lock);
    return got && running;
}

/* interruptHandler()에 해당 */
static void *handler(void *arg)
{
    struct isr_slot *s = arg;

    while (wait_for_edge(s))
        s->func();                       /* 사용자 함수는 이 스레드에서 실행된다 */
    return NULL;
}

static int my_wiringPiISR(unsigned gpio, unsigned edge, void (*f)(void))
{
    struct isr_slot *s;

    if (gpio > 31)
        return -1;
    s = &slots[gpio];
    s->gpio = gpio;
    s->edge = edge;
    s->func = f;
    s->pending = 0;
    pthread_mutex_init(&s->lock, NULL);
    pthread_cond_init(&s->cond, NULL);

    if (pthread_create(&s->thread, NULL, handler, s) != 0)
        return -1;
    s->used = 1;
    return gpioSetAlertFunc(gpio, on_alert);
}

static void stop_all_isr(void)
{
    for (unsigned g = 0; g < 32; g++) {
        struct isr_slot *s = &slots[g];
        if (!s->used)
            continue;
        gpioSetAlertFunc(g, NULL);
        pthread_mutex_lock(&s->lock);
        pthread_cond_broadcast(&s->cond);    /* running == 0 을 보고 빠져나오게 */
        pthread_mutex_unlock(&s->lock);
        pthread_join(s->thread, NULL);
    }
}

/* ---------------- 사용자 코드 (isr.c의 myInterrupt와 같은 모양) ---------------- */
static volatile int counter;

static void myInterrupt(void)
{
    ++counter;
    printf("  falling edge #%d on GPIO%d\n", counter, BUTTON_GPIO);
}

int main(void)
{
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);   /* active-low: 누르면 1 -> 0 */
    gpioGlitchFilter(BUTTON_GPIO, 5000);     /* 5 ms 디바운스 */

    if (my_wiringPiISR(BUTTON_GPIO, FALLING_EDGE, myInterrupt) != 0) {
        fprintf(stderr, "ISR 등록 실패\n");
        gpioTerminate();
        return 1;
    }

    printf("GPIO%d 하강 에지 대기 중 (Ctrl+C로 종료)\n", BUTTON_GPIO);
    while (running)
        gpioDelay(100000);               /* main은 다른 일을 해도 된다 */

    stop_all_isr();
    gpioTerminate();
    printf("\n정상 종료 (에지 %d회)\n", counter);
    return 0;
}
