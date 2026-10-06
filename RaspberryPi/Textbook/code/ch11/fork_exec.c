/*
 * fork_exec.c : 실습 11-2  fork() + exec() + waitpid()로 다른 프로그램 실행하기 (셸이 하는 일)
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -O2 -o fork_exec fork_exec.c   (또는 make fork_exec)
 * 실행 : ./fork_exec                    자식이 "ls -1"을 실행 (슬라이드 원본과 같은 동작)
 *        ./fork_exec date               자식이 date를 실행
 *        ./fork_exec false              종료 상태 1
 *        ./fork_exec nosuchcmd          exec 실패 -> 종료 상태 127
 *        ./fork_exec sleep 30           다른 터미널에서 kill <자식 PID> -> 시그널로 끝남
 *
 * 원본 : 「ARM 리눅스」 슬라이드 'fork()와 exec()를 이용한 프로세스 생성'
 * 고친 점
 *   1) execl(... ,(char *)0)); 의 괄호가 하나 많아 컴파일되지 않았다.
 *   2) fatal() 함수가 선언만 있고 정의가 없었다 -> perror()와 _exit()로 바꿨다.
 *   3) main()에 반환형이 없었다 -> int main(int argc, char *argv[]).
 *   4) <stdio.h>, <stdlib.h>, <sys/wait.h>가 빠져 있었다.
 *   5) wait((int *)0)은 종료 상태를 버린다 -> waitpid()로 받아 WIFEXITED/WIFSIGNALED로 해석한다.
 *   "ls -1"의 -1(숫자 1)은 오타가 아니라 "한 줄에 하나씩 출력" 옵션이다. 그대로 두었다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    pid_t pid;
    int status;

    pid = fork();
    switch (pid) {
    case -1:                                    /* 실패 */
        perror("fork failed");
        exit(1);

    case 0:                                     /* 자식 프로세스 */
        printf("[자식 %ld] exec 직전\n", (long)getpid());
        fflush(stdout);
        if (argc > 1)
            execvp(argv[1], &argv[1]);          /* PATH에서 argv[1]을 찾아 실행 */
        else
            execl("/bin/ls", "ls", "-1", (char *)NULL);
        /* exec가 성공하면 이 아래는 절대 실행되지 않는다. 여기 왔다면 실패한 것이다 */
        perror("exec failed");
        _exit(127);                             /* 셸과 같은 관례: 명령을 못 찾으면 127 */

    default:                                    /* 부모 프로세스 */
        printf("[부모 %ld] 자식 %ld 를 기다린다\n", (long)getpid(), (long)pid);
        if (waitpid(pid, &status, 0) < 0) {
            perror("waitpid");
            exit(1);
        }
        if (WIFEXITED(status))
            printf("[부모] 자식이 끝났다: 종료 상태 %d\n", WEXITSTATUS(status));
        else if (WIFSIGNALED(status))
            printf("[부모] 자식이 시그널 %d 로 끝났다\n", WTERMSIG(status));
    }
    return 0;
}
