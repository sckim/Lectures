/* endian.c - 바이트 순서(엔디언)와 정렬(alignment)을 직접 확인한다
 *
 * 빌드: gcc -Wall -O1 -o endian endian.c
 * 실행: ./endian
 */
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

union word {               /* 같은 4바이트를 두 가지 방식으로 본다 */
    uint32_t value;        /* 4바이트 정수로 보기 */
    uint8_t  bytes[4];     /* 바이트 배열로 보기 */
};

struct sample {            /* 정렬 때문에 생기는 빈칸(padding) 확인용 */
    char     c;            /* 1바이트 */
    uint32_t i;            /* 4바이트: 4의 배수 위치에 놓인다 */
    uint16_t h;            /* 2바이트 */
};

int main(void)
{
    uint32_t x = 0x12345678;
    uint8_t *p = (uint8_t *)&x;    /* x를 바이트 단위로 읽는 포인터 */
    union word w;
    int i;

    printf("[1] pointer: 0x%08X in memory\n", (unsigned)x);
    for (i = 0; i < 4; i++)
        printf("    address +%d : 0x%02X\n", i, p[i]);

    w.value = 0x12345678;
    printf("[2] union bytes[0..3] : %02X %02X %02X %02X\n",
           w.bytes[0], w.bytes[1], w.bytes[2], w.bytes[3]);

    if (p[0] == 0x78)
        printf("    => little-endian (LSB at the lowest address)\n");
    else if (p[0] == 0x12)
        printf("    => big-endian (MSB at the lowest address)\n");
    else
        printf("    => unknown byte order\n");

    printf("[3] sizeof: char=%zu short=%zu int=%zu long=%zu "
           "long long=%zu pointer=%zu\n",
           sizeof(char), sizeof(short), sizeof(int), sizeof(long),
           sizeof(long long), sizeof(void *));

    printf("[4] struct sample: size=%zu, offset c=%zu i=%zu h=%zu\n",
           sizeof(struct sample), offsetof(struct sample, c),
           offsetof(struct sample, i), offsetof(struct sample, h));
    printf("    (address of x) %% 4 = %lu\n",
           (unsigned long)((uintptr_t)&x % 4));
    return 0;
}
