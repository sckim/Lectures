/*
 * wave_pulse.c : 실습 9-7 (선택)  웨이브폼(gpioWave*)으로 정확한 펄스열 만들기
 *
 * 회로 : GPIO17 (물리 핀 11) = 데이터 펄스, GPIO27 (물리 핀 13) = 프레임 표시(마커)
 *        Analog Discovery 2: DIO0 <- GPIO17, DIO3 <- GPIO27, GND 공통 (10장 표준 배선)
 * 동작 : 1 ms 길이의 프레임 하나를 DMA가 끝없이 반복해서 내보낸다.
 *
 *   시간(us)  0    10   20        40   50             90  100                 1000
 *   GPIO17    ‾‾‾‾‾|____|‾‾‾‾‾‾‾‾‾|____|‾‾‾‾‾‾‾‾‾‾‾‾‾‾|_________________________
 *   GPIO27    ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____________________
 *             (GPIO17: 10, 20, 40 us 펄스 / GPIO27: 100 us 마커)
 *
 * 빌드 : gcc -Wall -pthread -o wave_pulse wave_pulse.c -lpigpio -lrt
 * 실행 : sudo ./wave_pulse          반복 송신 (Ctrl+C로 종료)
 *        sudo ./wave_pulse once     한 번만 송신
 * 주의 : 웨이브폼을 보내면 하드웨어 PWM(실습 9-4)은 꺼진다. 동시에 실행하지 않는다.
 */
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <pigpio.h>

#define DATA_GPIO    17
#define MARK_GPIO    27

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    /* {켤 GPIO 비트마스크, 끌 GPIO 비트마스크, 다음 펄스까지 지연(us)} */
    gpioPulse_t frame[] = {
        { (1u << DATA_GPIO) | (1u << MARK_GPIO), 0,  10 },   /*  0 us: 둘 다 High */
        { 0, (1u << DATA_GPIO),                      10 },   /* 10 us: 데이터 Low */
        { (1u << DATA_GPIO), 0,                      20 },   /* 20 us: 20 us 펄스 */
        { 0, (1u << DATA_GPIO),                      10 },   /* 40 us */
        { (1u << DATA_GPIO), 0,                      40 },   /* 50 us: 40 us 펄스 */
        { 0, (1u << DATA_GPIO),                      10 },   /* 90 us */
        { 0, (1u << MARK_GPIO),                     900 },   /* 100 us: 마커 Low, 프레임 끝까지 */
    };
    int once = (argc > 1 && strcmp(argv[1], "once") == 0);
    int wave_id, cbs;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(DATA_GPIO, PI_OUTPUT);
    gpioSetMode(MARK_GPIO, PI_OUTPUT);
    gpioWrite(DATA_GPIO, 0);
    gpioWrite(MARK_GPIO, 0);

    gpioWaveClear();                                         /* 1. 이전 웨이브폼 삭제 */
    gpioWaveAddGeneric(sizeof(frame) / sizeof(frame[0]), frame);  /* 2. 펄스 추가 */
    printf("프레임 길이 %d us\n", gpioWaveGetMicros());
    wave_id = gpioWaveCreate();                              /* 3. 웨이브폼 만들기 */
    if (wave_id < 0) {
        fprintf(stderr, "gpioWaveCreate 실패 (%d)\n", wave_id);
        gpioTerminate();
        return 1;
    }

    cbs = gpioWaveTxSend(wave_id, once ? PI_WAVE_MODE_ONE_SHOT  /* 4. 송신 */
                                       : PI_WAVE_MODE_REPEAT);
    printf("웨이브폼 %d 송신 시작 (DMA 제어 블록 %d개, %s)\n",
           wave_id, cbs, once ? "한 번" : "반복, Ctrl+C로 종료");

    while (running && gpioWaveTxBusy())                      /* CPU는 기다리기만 한다 */
        gpioDelay(100000);

    gpioWaveTxStop();                                        /* 반복 송신 중단 */
    gpioWaveDelete(wave_id);
    gpioWrite(DATA_GPIO, 0);
    gpioWrite(MARK_GPIO, 0);
    gpioSetMode(DATA_GPIO, PI_INPUT);
    gpioSetMode(MARK_GPIO, PI_INPUT);
    gpioTerminate();
    printf("정상 종료\n");
    return 0;
}
