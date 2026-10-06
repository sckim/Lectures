/*
 * zombie.c : 실습 11-2  좀비 프로세스와 고아 프로세스 관찰
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -O2 -o zombie zombie.c   (또는 make zombie)
 * 실행 : ./zombie &            좀비: 자식은 바로 끝나지만 부모가 15초 동안 wait를 하지 않는다
 *        ps -o pid,ppid,stat,cmd --ppid $!     STAT 칸의 Z와 <defunct>를 확인
 *        ./zombie orphan       고아: 부모가 먼저 끝나면 자식의 PPID가 바뀐다
 */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

static void zombie_demo(void)
{
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        return;
    }
    if (pid == 0) {                         /* 자식: 바로 끝난다 */
        printf("[자식 %ld] 바로 종료한다\n", (long)getpid());
        fflush(stdout);                     /* _exit()는 stdio 버퍼를 비우지 않는다 */
        _exit(0);
    }

    printf("[부모 %ld] 자식 %ld 은 끝났지만 15초 동안 wait하지 않는다 -> 좀비\n",
           (long)getpid(), (long)pid);
    fflush(stdout);
    sleep(15);                              /* 이 동안 ps로 보면 자식이 Z 상태 */

    waitpid(pid, NULL, 0);                  /* 이제 거둔다(reap) -> 좀비가 사라진다 */
    printf("[부모] waitpid로 자식을 거뒀다. 5초 더 기다린 뒤 끝난다\n");
    fflush(stdout);
    sleep(5);
}

static void orphan_demo(void)
{
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        return;
    }
    if (pid == 0) {                         /* 자식: 부모보다 오래 산다 */
        printf("[자식 %ld] 지금 부모 = %ld\n", (long)getpid(), (long)getppid());
        fflush(stdout);
        sleep(2);                           /* 그 사이 부모가 끝난다 */
        printf("[자식 %ld] 2초 뒤 부모 = %ld  (입양됨)\n", (long)getpid(), (long)getppid());
        fflush(stdout);
        _exit(0);
    }
    printf("[부모 %ld] 자식을 두고 먼저 끝난다\n", (long)getpid());
}

int main(int argc, char *argv[])
{
    if (argc > 1 && strcmp(argv[1], "orphan") == 0)
        orphan_demo();
    else
        zombie_demo();
    return 0;
}
