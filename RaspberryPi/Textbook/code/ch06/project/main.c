/*
 * main.c : 실습 6-5  여러 파일로 나눈 프로젝트의 진입점
 *
 * 빌드 : make          (Makefile이 sensor.c, util.c, main.c를 각각 컴파일한 뒤 링크)
 * 실행 : ./templog
 */
#include <stdio.h>
#include "sensor.h"
#include "util.h"

int main(void)
{
    int samples[SENSOR_SAMPLES];

    if (sensor_init() != 0) {
        fprintf(stderr, "센서 초기화 실패\n");
        return 1;
    }
    for (int i = 0; i < SENSOR_SAMPLES; i++) {
        samples[i] = sensor_read_mC();
        util_print_bar("raw", samples[i] / 1000.0, 23.0, 0.05);
    }
    printf("mean   = %.3f C\n", util_mean(samples, SENSOR_SAMPLES) / 1000.0);
    printf("stddev = %.3f C\n", util_stddev(samples, SENSOR_SAMPLES) / 1000.0);
    return 0;
}
