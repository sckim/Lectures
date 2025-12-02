#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>

const int BCM12_PWM0 = 12; // 각 하드웨어 pwm 핀을 변수로 선언
const int BCM13_PWM1 = 13;
const int BCM18_PWM0 = 18;

int main()
{
    int intensity;       // 빛의 밝기 조절용 변수
    wiringPiSetupGpio(); // BCM핀 번호를 사용하겠다고 선언

    pwmSetMode(PWM_MODE_MS); // PWM을 마크-스페이스 모드로 사용 선언

    pinMode(BCM12_PWM0, PWM_OUTPUT); // 12번 핀을 하드웨어 PWM 모드로 설정
    pinMode(BCM18_PWM0, PWM_OUTPUT); // 18번 핀을 하드웨어 PWM 모드로 설정
    pinMode(BCM13_PWM1, PWM_OUTPUT); // 13번 핀을 하드웨어 PWM 모드로 설정

    while (1)
    {

        for (intensity = 0; intensity < 1024; ++intensity)
        {                                           // 0에서 1024까지의 단계로 밝기 조절
            pwmWrite(BCM12_PWM0, 500);              // 12번 핀은 500의 강도로 설정
            pwmWrite(BCM18_PWM0, intensity);        // 18번 핀은 intensity에 따라 강도 조절
            pwmWrite(BCM13_PWM1, 1024 - intensity); //  13번 핀은 18번과 반대로 강도 조절
            delay(1);
        }

        for (intensity = 1023; intensity >= 0; --intensity)
        {                                           // 1023에서 0의 단계로 밝기 조절
            pwmWrite(BCM12_PWM0, 500);              // 12번은 500으로 강도 설정
            pwmWrite(BCM18_PWM0, intensity);        // 18번은 intesity에 따라 강도 설정
            pwmWrite(BCM13_PWM1, 1024 - intensity); // 13번은 18번과 반대로 강도 조절

            delay(1);
        }
        delay(1);
    }

    return 0;
}
