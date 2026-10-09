/*
 * process_demo.c : 실습 11-2  프로세스 식별 번호와 fork()의 복사(copy-on-write) 확인
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -O2 -o process_demo process_demo.c   (또는 make process_demo)
 * 실행 : ./process_demo
 *
 * 원본 : 「ARM 리눅스」 슬라이드 '프로세스의 식별' 예제
 * 고친 점
 *   1) main()의 반환형이 없고 return도 없었다 -> int main(void), return 0.
 *   2) pid_t, uid_t는 printf의 %d와 크기가 같다는 보장이 없으므로 (long)으로 바꿔 출력한다.
 *   3) 처음의 sleep(5)는 다른 터미널에서 ps로 확인할 시간을 주려는 것으로 보여 인자로 바꿨다.
 *   4) fork() 뒤에 부모와 자식이 "같은 주소, 다른 값"을 갖는 것을 보이는 부분을 추가했다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int counter = 100;                       /* 전역 변수(.data) */

int main(int argc, char *argv[])
{
    int local = 7;                       /* 지역 변수(스택) */
    pid_t pid;

    if (argc > 1)
        sleep((unsigned)atoi(argv[1]));  /* ./process_demo 30 : 30초 동안 ps로 관찰 가능 */

    printf("Process ID         = %ld\n", (long)getpid());
    printf("Parent process ID  = %ld\n", (long)getppid());
    printf("Real User ID       = %ld\n", (long)getuid());
    printf("Effective User ID  = %ld\n", (long)geteuid());
    printf("Real group ID      = %ld\n", (long)getgid());
    printf("Effective group ID = %ld\n\n", (long)getegid());

    fflush(stdout);                      /* fork 전에 버퍼를 비운다(비우지 않으면 자식도 같은 내용을 또 출력) */
    pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {                      /* ---- 자식 프로세스 ---- */
        counter += 1;                    /* 자식이 쓰는 순간 그 페이지만 복사된다 */
        local += 1;
        printf("[자식] PID=%ld PPID=%ld  counter=%d (%p)  local=%d (%p)\n",
               (long)getpid(), (long)getppid(),
               counter, (void *)&counter, local, (void *)&local);
        return 3;                        /* 종료 상태 3을 부모에게 돌려준다 */
    }

    /* ---- 부모 프로세스 ---- */
    int status;
    waitpid(pid, &status, 0);            /* 자식이 끝날 때까지 기다리고 종료 상태를 거둔다 */
    printf("[부모] PID=%ld 자식=%ld  counter=%d (%p)  local=%d (%p)\n",
           (long)getpid(), (long)pid,
           counter, (void *)&counter, local, (void *)&local);
    if (WIFEXITED(status))
        printf("[부모] 자식의 종료 상태 = %d\n", WEXITSTATUS(status));
    return 0;
}
