/* asm_demo.c - C 함수가 ARM 명령어로 어떻게 바뀌는지 보기 위한 예제
 *
 * 어셈블리 보기 : make asm   (asm_demo.s 생성)
 * 기계어 보기   : make dis   (objdump로 역어셈블)
 */

/* 1) 덧셈: 인자 a, b는 레지스터로 들어오고 결과도 레지스터로 돌아간다.
 *    noinline: 컴파일러가 이 함수를 호출하는 쪽에 끼워 넣지(inline) 못하게 해서
 *    4)에서 함수 호출(BL) 명령이 그대로 보이도록 한다. */
__attribute__((noinline)) int add(int a, int b)
{
    return a + b;
}

/* 2) if/else: 비교(CMP)한 뒤 조건에 따라 둘 중 하나를 고른다 */
int max_of(int a, int b)
{
    if (a > b)
        return a;
    else
        return b;
}

/* 3) 반복문: 비교와 조건 분기(B.cond)가 되풀이된다 */
int sum_to(int n)
{
    int s = 0;

    for (int i = 1; i <= n; i++)
        s += i;
    return s;
}

/* 4) 함수 호출: BL로 add를 부르고, 돌아올 주소(LR)를 스택에 보관한다 */
int add_ten_plus_one(int x)
{
    return add(x, 10) + 1;
}
