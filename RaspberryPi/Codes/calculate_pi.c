#include <stdio.h> //라이프니츠의 공식

int main(void)
{
    double pi = 0, temp = 1, p = -1, num = 1;

    while (num < 10000000)
    {
        p *= -1;
        pi += p * 1.0 / temp;
        temp += 2;
        num++;
    }
    
    printf("%.10f", 4 * pi);
}
