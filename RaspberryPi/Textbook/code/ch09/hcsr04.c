/*
 * hcsr04.c : 실습 9-6  HC-SR04 초음파 거리 측정 (알림 콜백의 tick으로 펄스 폭 재기)
 *
 * 회로 : 레벨 시프터(BSS138 4채널 양방향) LV -> 3.3 V (물리 핀 1), HV -> 5 V (물리 핀 2),
 *        GND -> GND (물리 핀 34)
 *        HC-SR04 VCC  -> 5 V (물리 핀 2),  HC-SR04 GND -> GND (물리 핀 34)
 *        GPIO20 (물리 핀 38) -> 시프터 LV3,  시프터 HV3 -> HC-SR04 TRIG
 *        HC-SR04 ECHO -> 시프터 HV4,  시프터 LV4 -> GPIO21 (물리 핀 40)
 *        (시프터 1·2번 채널은 12장 I2C LCD의 SDA·SCL 몫이다)
 *                        ※ ECHO는 5 V 출력이다. 시프터 없이 직결하면 GPIO가 손상될 수 있다.
 *                          (시프터가 없을 때의 대안: ECHO -> 1 kΩ -> GPIO21, GPIO21 -> 2 kΩ -> GND)
 * 동작 : TRIG에 10 us 펄스를 주고, ECHO가 High인 시간(왕복 시간)을 콜백의 tick으로 잰다.
 *        거리 = 왕복 시간 x 음속 / 2.  60 ms 안에 답이 없으면 시간 초과로 처리한다.
 * 빌드 : gcc -Wall -pthread -o hcsr04 hcsr04.c -lpigpio -lrt
 * 실행 : sudo ./hcsr04 [기온_섭씨]      예) sudo ./hcsr04 25
 *
 * 원본 : Linux 백서 PIGIO 탭의 초음파 예제(gpioRead 바쁜 대기, 시간 초과 없음, ECHO 직결)를
 *        콜백 방식으로 다시 썼다. pigpio EXAMPLES/Python/SONAR_RANGER 의 방식을 참고하였다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <stdatomic.h>
#include <pigpio.h>

#define TRIG_GPIO     20        /* 물리 핀 38, 레벨 시프터 경유 */
#define ECHO_GPIO     21        /* 물리 핀 40, 레벨 시프터 경유 */
#define TRIG_US       10        /* 트리거 펄스 폭 (gpioTrigger는 1~100 us) */
#define TIMEOUT_US    60000     /* 이 시간 안에 ECHO가 끝나지 않으면 실패 */
#define MAX_ECHO_US   25000     /* 약 4.3 m. 이보다 길면 "범위 밖"으로 본다 */
#define PERIOD_US     100000    /* 측정 간격 100 ms (잔향이 사라질 시간) */

static volatile sig_atomic_t running = 1;

/* 콜백과 main이 함께 쓰는 측정 상태. userdata로 콜백에 넘긴다. */
struct sonar {
    atomic_uint rise_tick;      /* ECHO 상승 시각 */
    atomic_int  have_rise;      /* 상승 에지를 보았는가 */
    atomic_uint width_us;       /* ECHO High 폭 */
    atomic_int  done;           /* 1이면 width_us가 새 값 */
};

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* gpioSetAlertFuncEx 콜백: 네 번째 인자로 struct sonar의 주소가 온다. */
static void on_echo(int gpio, int level, uint32_t tick, void *userdata)
{
    struct sonar *s = userdata;

    (void)gpio;
    if (level == 1) {                            /* ECHO 상승: 초음파 발사 */
        atomic_store(&s->rise_tick, tick);
        atomic_store(&s->have_rise, 1);
    } else if (level == 0 && atomic_load(&s->have_rise)) {   /* ECHO 하강: 반사파 수신 */
        atomic_store(&s->width_us, tick - atomic_load(&s->rise_tick));
        atomic_store(&s->have_rise, 0);
        atomic_store(&s->done, 1);               /* 값을 먼저 쓰고 마지막에 깃발 */
    }
}

int main(int argc, char *argv[])
{
    static struct sonar s;                       /* 0으로 초기화된다 */
    double temp_c = (argc > 1) ? atof(argv[1]) : 20.0;
    double sound_mps = 331.3 + 0.606 * temp_c;   /* 기온에 따른 음속(근사식) */
    uint32_t t0;
    unsigned w;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(TRIG_GPIO, PI_OUTPUT);
    gpioWrite(TRIG_GPIO, 0);
    gpioSetMode(ECHO_GPIO, PI_INPUT);
    gpioSetPullUpDown(ECHO_GPIO, PI_PUD_OFF);    /* 레벨은 시프터(또는 분압기)가 정해 준다 */
    gpioSetAlertFuncEx(ECHO_GPIO, on_echo, &s);

    printf("기온 %.1f도, 음속 %.1f m/s. Ctrl+C로 종료\n", temp_c, sound_mps);
    gpioDelay(100000);                           /* 센서 안정화 */

    while (running) {
        atomic_store(&s.done, 0);
        atomic_store(&s.have_rise, 0);
        gpioTrigger(TRIG_GPIO, TRIG_US, 1);      /* 10 us High 펄스 */

        t0 = gpioTick();                         /* 시간 초과가 있는 기다림 */
        while (!atomic_load(&s.done) && (uint32_t)(gpioTick() - t0) < TIMEOUT_US)
            gpioDelay(1000);

        if (!atomic_load(&s.done)) {
            printf("시간 초과: ECHO 응답 없음 (배선·레벨 시프터·전원 확인)\n");
        } else {
            w = atomic_load(&s.width_us);
            if (w > MAX_ECHO_US)
                printf("범위 밖 (ECHO %u us)\n", w);
            else
                printf("ECHO %5u us -> 거리 %6.1f cm\n",
                       w, w * 1e-6 * sound_mps / 2.0 * 100.0);
        }
        gpioDelay(PERIOD_US);
    }

    gpioSetAlertFuncEx(ECHO_GPIO, NULL, NULL);
    gpioSetMode(TRIG_GPIO, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
