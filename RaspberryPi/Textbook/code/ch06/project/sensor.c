/*
 * sensor.c : 실습 6-5  가상 온도 센서 (하드웨어 없이 동작)
 */
#include "sensor.h"

/* static: 이 파일 안에서만 쓰는 변수·함수(다른 파일에서는 보이지 않는다) */
static const int fake_mC[] = { 23100, 23250, 23400, 23300, 23550, 23700, 23600, 23800 };
static int next_index;

int sensor_init(void)
{
    next_index = 0;
    return 0;
}

int sensor_read_mC(void)
{
    int n = sizeof(fake_mC) / sizeof(fake_mC[0]);
    int v = fake_mC[next_index];

    next_index = (next_index + 1) % n;
    return v;
}
