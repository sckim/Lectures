#include <stdio.h>

#define SCALE 10000
#define MAX_ARRAY 2800
#define ARRAY_INIT 2000

int main(void)
{
    int i, j, sum, carry = 0;
    int array[MAX_ARRAY + 1];
    for (i = 0; i <= MAX_ARRAY; ++i)
    {

        array[i] = ARRAY_INIT; // array 배열 초기화
    }
    for (i = MAX_ARRAY; i; i -= 14)
    {
        sum = 0;
        for (j = i; j > 0; --j)
        {
            sum = sum * j + SCALE * array[j];
            array[j] = sum % (j * 2 - 1);

            sum /= (j * 2 - 1);
        }
        printf("%04d", carry + sum / SCALE);
        carry = sum % SCALE;
    }
    printf("\n");
    
    return 0;
}
