/*
 * scores.c : 실습 6-6  gdb로 찾아야 하는 버그가 두 개 들어 있는 프로그램
 *
 * 다섯 학생 점수의 평균, 최저점, 최고점을 구한다.
 * 기대 결과 : average = 78.0, min = 65, max = 90
 *
 * 빌드 : gcc -Wall -g -O0 -o scores scores.c     (-g: 디버깅 정보, -O0: 최적화 끔)
 * 디버깅 : gdb ./scores
 *
 * 컴파일 오류도 경고도 없지만 결과가 틀린다(논리 오류). 버그를 찾아 고친 뒤
 * 다시 빌드해 기대 결과가 나오는지 확인한다.
 */
#include <stdio.h>

#define N 5

struct record {
    int score[N];       /* 점수 다섯 개 */
    int count;          /* 학생 수(= N). 배열 바로 뒤에 놓인다 */
};

static double average(const struct record *r)
{
    int sum = 0;

    for (int i = 0; i <= r->count; i++)     /* 버그 1: 어디가 이상한가? */
        sum += r->score[i];
    return (double)sum / r->count;
}

static int min_score(const struct record *r)
{
    int min = 0;                             /* 버그 2: 어디가 이상한가? */

    for (int i = 0; i < r->count; i++)
        if (r->score[i] < min)
            min = r->score[i];
    return min;
}

static int max_score(const struct record *r)
{
    int max = r->score[0];

    for (int i = 1; i < r->count; i++)
        if (r->score[i] > max)
            max = r->score[i];
    return max;
}

int main(void)
{
    struct record r = { { 70, 85, 90, 65, 80 }, N };

    printf("average = %.1f\n", average(&r));
    printf("min     = %d\n", min_score(&r));
    printf("max     = %d\n", max_score(&r));
    return 0;
}
