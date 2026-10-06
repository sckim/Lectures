/*
 * sensor.h : 실습 6-5  (가상) 온도 센서 모듈의 인터페이스
 *
 * 실제 센서 대신 미리 정해 둔 값을 차례로 돌려준다.
 * 12장에서 I2C 센서를 읽는 코드로 sensor.c만 바꾸면 main.c는 그대로 쓸 수 있다.
 */
#ifndef SENSOR_H
#define SENSOR_H

#define SENSOR_SAMPLES 8                /* 한 번에 읽을 샘플 수 */

int  sensor_init(void);                 /* 성공하면 0 */
int  sensor_read_mC(void);              /* 온도를 밀리도(m°C) 정수로 돌려준다 */

#endif /* SENSOR_H */
