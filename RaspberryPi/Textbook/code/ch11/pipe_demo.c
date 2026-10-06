/*
 * pipe_demo.c : 11.6절  파이프로 부모 -> 자식에게 데이터 보내기 (가장 간단한 IPC)
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -O2 -o pipe_demo pipe_demo.c   (또는 make pipe_demo)
 * 실행 : ./pipe_demo
 *
 * 부모는 "센서 값"을 한 줄씩 파이프에 쓰고, 자식은 읽어서 출력한다.
 * 두 프로세스는 메모리를 공유하지 않으므로, 커널이 관리하는 파이프 버퍼를 통해서만 데이터가 오간다.
 * 셸의 "명령1 | 명령2"도 이렇게 만든 파이프로 두 프로세스를 잇는 것이다(4장).
 */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void)
{
    int fd[2];                       /* fd[0] = 읽는 쪽, fd[1] = 쓰는 쪽 */
    pid_t pid;

    if (pipe(fd) < 0) {
        perror("pipe");
        return 1;
    }

    pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {                  /* ---- 자식: 읽기만 한다 ---- */
        char buf[64];
        ssize_t n;

        close(fd[1]);                /* 쓰는 쪽은 닫는다(안 닫으면 EOF가 오지 않는다) */
        while ((n = read(fd[0], buf, sizeof(buf) - 1)) > 0) {
            buf[n] = '\0';
            printf("[자식 %ld] 받음: %s", (long)getpid(), buf);
        }
        printf("[자식] EOF - 부모가 쓰는 쪽을 닫았다\n");
        close(fd[0]);
        fflush(stdout);              /* _exit()는 stdio 버퍼를 비우지 않는다 */
        _exit(0);
    }

    /* ---- 부모: 쓰기만 한다 ---- */
    close(fd[0]);
    for (int i = 1; i <= 3; i++) {
        char msg[32];
        int len = snprintf(msg, sizeof(msg), "temp=%d.%d C\n", 24 + i, i);

        if (write(fd[1], msg, (size_t)len) != len) {
            perror("write");
            break;
        }
        printf("[부모 %ld] 보냄: %s", (long)getpid(), msg);
        fflush(stdout);
        sleep(1);
    }
    close(fd[1]);                    /* 닫으면 자식의 read()가 0(EOF)을 돌려준다 */
    waitpid(pid, NULL, 0);
    return 0;
}
