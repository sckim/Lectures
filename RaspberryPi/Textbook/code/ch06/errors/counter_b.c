/*
 * counter_b.c : 6.4절  multiple definition 오류 관찰 (counter_a.c와 함께 빌드)
 */
#ifdef FIX
extern int counter;             /* 선언(declaration): "다른 파일에 있다"고 알리기만 한다 */
#else
int counter;                    /* 잘못: counter_a.c와 같은 이름을 또 정의했다 */
#endif

void count_up(void)
{
    counter++;
}
