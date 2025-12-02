#include <stdio.h>
#include <math.h>

#define M_PI 3.14159265358979323846 /* pi */

static double getRadian(double degree)
{
    return degree * (M_PI / 180.0);
}

int main(void)
{
    double result1 = 0.0, result2 = 0.0, result3 = 0.0;
    double num = getRadian(60);
    // double num = 3.14159*60/180;

    result1 = sin(num);
    result2 = cos(num);
    result3 = tan(num);
    printf("sin60 : %5.4lf\n", result1);
    printf("cos60 : %5.4lf\n", result2);
    printf("tan60 : %5.4lf\n", result3);
    return 0;
}
