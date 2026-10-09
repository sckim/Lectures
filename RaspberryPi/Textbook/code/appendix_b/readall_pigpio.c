/*
 * readall_pigpio.c : 부록 B  "gpio readall" 흉내 - 40핀 헤더의 모드와 레벨을 표로 출력
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -pthread -o readall_pigpio readall_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./readall_pigpio
 *
 * 원본 : WiringPi의 gpio 유틸리티 "gpio readall" (wiringpi/readall.c)
 *        gpio readall은 BCM 번호, wPi 번호, 이름, 모드, 레벨(V), 물리 핀 번호를
 *        한 표에 보여 준다. 여기서는 pigpio의 gpioGetMode()와 gpioRead()만으로
 *        같은 모양의 표를 만든다(BCM 0~27이 모두 나온다).
 *
 * 한계 : BCM2711은 풀업/풀다운 "설정값"을 읽는 레지스터를 제공하지만 pigpio에는
 *        읽기 함수가 없다. 풀 상태까지 보려면 pinctrl을 쓴다(8장).
 *            pinctrl -p        (물리 핀 순서로 모드·풀·레벨 표시)
 *        이 프로그램도 gpioInitialise()를 부르므로 pigpiod가 떠 있으면 실패한다.
 */
#include <stdio.h>
#include <pigpio.h>

struct pin {
    int bcm;                    /* -1 이면 전원/GND */
    int wpi;
    const char *name;
};

/* 물리 핀 1~40 (인덱스 0 = 물리 핀 1) */
static const struct pin hdr[40] = {
    {-1, -1, "3.3v"},    {-1, -1, "5v"},
    { 2,  8, "SDA.1"},   {-1, -1, "5v"},
    { 3,  9, "SCL.1"},   {-1, -1, "0v"},
    { 4,  7, "GPIO.7"},  {14, 15, "TxD"},
    {-1, -1, "0v"},      {15, 16, "RxD"},
    {17,  0, "GPIO.0"},  {18,  1, "GPIO.1"},
    {27,  2, "GPIO.2"},  {-1, -1, "0v"},
    {22,  3, "GPIO.3"},  {23,  4, "GPIO.4"},
    {-1, -1, "3.3v"},    {24,  5, "GPIO.5"},
    {10, 12, "MOSI"},    {-1, -1, "0v"},
    { 9, 13, "MISO"},    {25,  6, "GPIO.6"},
    {11, 14, "SCLK"},    { 8, 10, "CE0"},
    {-1, -1, "0v"},      { 7, 11, "CE1"},
    { 0, 30, "SDA.0"},   { 1, 31, "SCL.0"},
    { 5, 21, "GPIO.21"}, {-1, -1, "0v"},
    { 6, 22, "GPIO.22"}, {12, 26, "GPIO.26"},
    {13, 23, "GPIO.23"}, {-1, -1, "0v"},
    {19, 24, "GPIO.24"}, {16, 27, "GPIO.27"},
    {26, 25, "GPIO.25"}, {20, 28, "GPIO.28"},
    {-1, -1, "0v"},      {21, 29, "GPIO.29"},
};

/* gpioGetMode()의 반환값 -> 이름 (pigpio.h: PI_INPUT 0, PI_OUTPUT 1, PI_ALT0 4 ...) */
static const char *mode_name(int m)
{
    static const char *names[8] = {
        "IN", "OUT", "ALT5", "ALT4", "ALT0", "ALT1", "ALT2", "ALT3"
    };
    return (m >= 0 && m < 8) ? names[m] : "?";
}

static void print_left(const struct pin *p)
{
    if (p->bcm < 0)
        printf(" |     |     | %7s |      |   |", p->name);
    else
        printf(" | %3d | %3d | %7s | %4s | %d |", p->bcm, p->wpi, p->name,
               mode_name(gpioGetMode(p->bcm)), gpioRead(p->bcm));
}

static void print_right(const struct pin *p)
{
    if (p->bcm < 0)
        printf("|   |      | %-7s |     |     |\n", p->name);
    else
        printf("| %d | %-4s | %-7s | %3d | %3d |\n", gpioRead(p->bcm),
               mode_name(gpioGetMode(p->bcm)), p->name, p->wpi, p->bcm);
}

int main(void)
{
    const char *line =
        " +-----+-----+---------+------+---+----------+---+------+---------+-----+-----+\n";
    const char *head =
        " | BCM | wPi |   Name  | Mode | V | Physical | V | Mode | Name    | wPi | BCM |\n";
    int i;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패 (sudo? pigpiod가 떠 있지 않은가?)\n");
        return 1;
    }

    printf("%s%s%s", line, head, line);
    for (i = 0; i < 40; i += 2) {
        print_left(&hdr[i]);
        printf(" %2d || %-2d ", i + 1, i + 2);
        print_right(&hdr[i + 1]);
    }
    printf("%s%s%s", line, head, line);
    printf(" (pigpio v%u, hardware revision 0x%x)\n",
           gpioVersion(), gpioHardwareRevision());

    gpioTerminate();
    return 0;
}
