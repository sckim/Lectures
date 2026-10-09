# 부록 C. 명령어 요약과 오류 모음

> **이 부록을 쓰는 법**
> - 이 부록은 처음부터 읽는 장이 아니라, 실습하다가 **찾아보는** 장이다. 명령어·함수·설정 이름이나 오류 메시지의 문구로 찾는다(브라우저나 편집기의 찾기 기능, Ctrl+F).
> - 표의 각 행은 그 내용을 **자세히 설명한 장**으로 연결된다. 여기서는 한 줄 요약만 하므로, 처음 보는 명령이나 오류라면 꼭 링크를 따라가 본문을 읽는다.
> - 핀 번호는 이 책의 규칙대로 `GPIO17 (물리 핀 11)`처럼 BCM 번호와 물리 핀 번호를 함께 적는다. 40핀 헤더 전체 표는 [8장](08_gpio_pigpio.md) 8.2.1절에 있다.

| 절 | 내용 | 이럴 때 펼친다 |
|---|---|---|
| C.1 | Linux 명령어 빠른 참조 | "그 명령이 뭐였더라?" |
| C.2 | pigpio API 빠른 참조 | C 함수 이름·인자, `pigs` 명령이 기억나지 않을 때 |
| C.3 | 설정 파일 빠른 참조 | `config.txt`, `cmdline.txt`, systemd 유닛, Makefile을 고칠 때 |
| C.4 | 핀 배치 요약 | 표준 핀 계획에서 어느 핀이 어떤 역할이고 어느 실습이 쓰는지, 옛 자료의 핀을 어떻게 바꿔 읽는지 확인할 때 |
| C.5 | 자주 나오는 오류 모음 | 오류 메시지가 떴을 때 |
| C.6 | 용어집 | 용어의 뜻과 처음 나온 장을 찾을 때 |
| C.7 | 참고 자료 | 공식 문서로 더 깊이 확인할 때 |

---

## C.1 Linux 명령어 빠른 참조

명령마다 `--help`나 `man 명령`으로 도움말을 볼 수 있다. 셸 내장 명령(`cd`, `export`, `jobs` 등)은 `help 명령`으로 본다([4장](04_linux_shell.md)). `sudo`가 붙은 예는 관리자 권한이 필요한 명령이다. "다루는 장"은 그 명령을 처음 자세히 설명한 장이다.

> **원본 자료 정정:** 강의 자료의 명령어 요약(`linux_command.md`)을 이 절에 합치면서 다음을 바로잡았다.
> - `reboot -h now`는 끄기(`shutdown -h now`)와 섞인 표기이다. 재부팅은 `sudo reboot`, 끄기는 `sudo poweroff` 또는 `sudo shutdown -h now`이다([5장](05_sysadmin.md)).
> - `ifconfig`는 Bookworm에 기본 설치되어 있지 않은 옛 도구(net-tools)이다. `ip addr`를 쓴다([3장](03_rpi_hw_os.md)).
> - `apt-get`도 여전히 동작하지만 대화형으로는 `apt`를 쓴다([5장](05_sysadmin.md)).
> - Raspberry Pi OS의 root에는 암호가 없어 `su root`는 `Authentication failure`가 난다. 꼭 필요할 때만 `sudo -i`를 쓰고, 끝나면 바로 `exit`한다([5장](05_sysadmin.md)).
> - `emacs`는 기본 설치가 아니다. 기본 편집기는 `nano`와 `vi`(`vim.tiny`)이다([4장](04_linux_shell.md)).
> - `fdisk /dev/sda`처럼 장치 이름만 주면 **파티션 편집 모드**로 들어간다. 정보만 볼 때는 `sudo fdisk -l`을 쓴다([5장](05_sysadmin.md)).
> - `bluetoothctl`은 이 책의 설정(3장의 `dtoverlay=disable-bt`)에서는 컨트롤러가 없다고 나온다. [13장](13_ble_iot.md) 실습 13-0으로 Bluetooth를 다시 켠 뒤 쓴다.

### C.1.1 파일과 디렉터리

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `pwd` | 현재 디렉터리 출력 | `pwd` | [4장](04_linux_shell.md) |
| `ls` | 파일 목록. `-l` 자세히, `-a` 숨김 파일 포함, `-i` inode 번호, `-d` 디렉터리 자신 | `ls -la`, `ls -ld /tmp` | [4장](04_linux_shell.md) |
| `cd` | 디렉터리 이동. `cd`만 치면 홈, `cd -`는 직전 위치 | `cd ~/code/ch08`, `cd ..` | [4장](04_linux_shell.md) |
| `mkdir` / `rmdir` | 디렉터리 만들기(`-p` 중간 경로까지) / 빈 디렉터리 지우기 | `mkdir -p a/b/c` | [4장](04_linux_shell.md) |
| `touch` | 빈 파일 만들기, 수정 시각 갱신 | `touch new.txt` | [4장](04_linux_shell.md) |
| `cp` | 복사. `-r` 디렉터리째, `-i` 덮어쓰기 전 확인 | `cp -r ch08 ch08_bak` | [4장](04_linux_shell.md) |
| `mv` | 이동·이름 바꾸기 | `mv a.txt b.txt` | [4장](04_linux_shell.md) |
| `rm` | 지우기. `-r` 디렉터리째, `-f` 묻지 않음. **휴지통이 없다** | `rm -i old.log` | [4장](04_linux_shell.md) |
| `ln` | 링크 만들기. `-s`는 심볼릭 링크, 없으면 하드 링크 | `ln -s /boot/firmware/config.txt cfg` | [4장](04_linux_shell.md) |
| `cat` | 파일 내용 출력(짧은 파일). `-n` 줄 번호, `-A` 숨은 문자(`^M`, 탭) 보기 | `cat -A x.sh` | [4장](04_linux_shell.md) |
| `less` / `more` | 긴 파일을 한 화면씩 보기. `/단어` 찾기, `q` 끝 | `less /var/log/syslog` | [4장](04_linux_shell.md) |
| `head` / `tail` | 앞·뒤 몇 줄. `tail -f`는 늘어나는 파일을 계속 보기 | `tail -n 20 sample.log` | [4장](04_linux_shell.md) |
| `file` | 파일 종류 판별(ELF·CPU 종류, CRLF 여부) | `file led_blink` | [4장](04_linux_shell.md), [6장](06_c_build.md) |
| `stat` | inode, 크기, 권한, 시각 등 자세한 정보 | `stat hello.sh` | [4장](04_linux_shell.md) |
| `find` | 조건으로 파일 찾기 | `find . -name "*.c"`, `find ~ -type d` | [4장](04_linux_shell.md) |
| `which` / `whereis` / `type` / `command -v` | 명령이 어디 있는지, 내장 명령인지 외부 프로그램인지 | `type cd`, `which gcc` | [4장](04_linux_shell.md) |
| `tar` | 여러 파일을 하나로 묶기·풀기. `c` 묶기, `x` 풀기, `z` gzip, `v` 목록, `f` 파일 이름 | `tar czvf ch08.tar.gz ch08/`, `tar xzvf ch08.tar.gz` | [4장](04_linux_shell.md) |
| `gzip` / `gunzip` / `zcat` | 파일 하나 압축·해제·압축 상태로 보기 | `zcat sample.log.gz \| head -n 2` | [4장](04_linux_shell.md) |
| `tree` | 디렉터리 구조를 나무 모양으로(기본 설치 아님: `sudo apt install tree`) | `tree -L 2` | [5장](05_sysadmin.md) |

### C.1.2 권한과 사용자

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `chmod` | 권한 바꾸기. 숫자(`755`) 또는 기호(`u+x`). **`chmod 777`은 쓰지 않는다** | `chmod +x hello.sh`, `chmod 644 a.service` | [4장](04_linux_shell.md) |
| `chown` | 소유자·그룹 바꾸기 | `sudo chown -R student:student ~/code` | [4장](04_linux_shell.md) |
| `umask` | 새 파일의 기본 권한에서 뺄 비트 | `umask` (보통 `0022`) | [4장](04_linux_shell.md) |
| `id` / `groups` | 내 UID·GID와 소속 그룹 | `id -nG` | [4장](04_linux_shell.md), [5장](05_sysadmin.md) |
| `sudo` | 관리자 권한으로 한 명령 실행 | `sudo apt update` | [5장](05_sysadmin.md) |
| `sudo tee` | root만 쓸 수 있는 파일에 쓰기(`sudo echo … >`는 실패한다) | `echo 1 \| sudo tee /sys/…` | [4장](04_linux_shell.md) |
| `sudo -i` | root 셸 열기. 실수 한 번이 시스템 전체에 미치므로 꼭 필요할 때만 | `sudo -i` → 작업 → `exit` | [5장](05_sysadmin.md) |
| `adduser` / `deluser` | 사용자 만들기 / 지우기(`--remove-home` 홈까지) | `sudo adduser guest` | [5장](05_sysadmin.md) |
| `usermod -aG` | 사용자를 그룹에 **추가**(`-a` 빠뜨리면 다른 그룹에서 빠진다). 다시 로그인해야 적용 | `sudo usermod -aG gpio,i2c,dialout $USER` | [5장](05_sysadmin.md) |
| `passwd` | 암호 바꾸기 | `passwd` | [5장](05_sysadmin.md) |
| `getent` | 사용자·그룹 데이터베이스 조회 | `getent group gpio` | [5장](05_sysadmin.md) |

### C.1.3 텍스트 처리와 셸

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `echo` / `printf` | 문자열 출력. `printf`는 형식 지정 | `echo $PATH` | [4장](04_linux_shell.md) |
| `grep` | 패턴이 든 줄 찾기. `-i` 대소문자 무시, `-r` 하위 폴더, `-n` 줄 번호, `-v` 반대, `-E` 확장 정규식 | `grep -n ERROR sample.log` | [4장](04_linux_shell.md) |
| `sort` / `uniq` | 정렬 / 이웃한 같은 줄 합치기(`-c` 개수). `uniq` 앞에는 `sort` | `sort \| uniq -c \| sort -rn` | [4장](04_linux_shell.md) |
| `cut` | 구분자로 나눈 열 고르기 | `cut -d' ' -f3` | [4장](04_linux_shell.md) |
| `awk` | 열 단위 처리·계산 | `awk '{s+=$5} END{print s/NR}'` | [4장](04_linux_shell.md) |
| `sed` | 줄 단위 치환·삭제 | `sed -i 's/\r$//' x.sh` (CRLF 제거) | [4장](04_linux_shell.md) |
| `tr` | 글자 바꾸기·지우기 | `tr 'a-z' 'A-Z'` | [4장](04_linux_shell.md) |
| `wc` | 줄·단어·바이트 수 | `wc -l sample.log` | [4장](04_linux_shell.md) |
| `tee` | 표준 출력을 화면과 파일에 동시에 | `make 2>&1 \| tee build.log` | [4장](04_linux_shell.md) |
| `diff` | 두 파일의 차이 | `diff config.txt config.txt.bak` | [5장](05_sysadmin.md) |
| `>`, `>>`, `2>&1`, `\|` | 덮어쓰기, 덧붙이기, 오류도 같은 곳으로, 파이프 | `./prog > out.txt 2>&1` | [4장](04_linux_shell.md) |
| `export` / `source` | 환경 변수를 자식 프로세스에 넘기기 / 파일을 현재 셸에서 실행 | `source ~/.bashrc` | [4장](04_linux_shell.md) |
| `alias` | 명령 별명(스크립트 안에서는 안 펼쳐진다) | `alias ll='ls -la'` | [4장](04_linux_shell.md) |
| `history` | 지난 명령 목록. `!번호`로 다시 실행 | `history \| grep apt` | [4장](04_linux_shell.md) |
| `man` / `help` | 매뉴얼 / 내장 명령 도움말 | `man 3 printf`, `help cd` | [4장](04_linux_shell.md) |
| `bash -n` | 스크립트를 실행하지 않고 문법만 검사 | `bash -n backup.sh` | [4장](04_linux_shell.md) |
| `nano` / `vi` | 텍스트 편집기. nano는 Ctrl+O 저장, Ctrl+X 끝. vi는 `i` 입력, Esc → `:wq` 저장 후 끝, `:q!` 저장 없이 끝 | `nano config.txt` | [4장](04_linux_shell.md) |
| `strace` | 프로그램이 부르는 시스템 콜 추적 | `strace -e trace=openat,read,write cat /etc/hostname` | [4장](04_linux_shell.md) |

### C.1.4 프로세스

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `ps` | 프로세스 목록. `aux`·`-ef` 전체, `-L` 스레드까지, `-o` 열 지정 | `ps aux \| grep pigpio`, `ps -L -o tid,stat,wchan:20 -p PID` | [5장](05_sysadmin.md), [11장](11_process_concurrency.md) |
| `pstree` | 부모-자식 관계를 나무로 | `pstree -p` | [5장](05_sysadmin.md) |
| `top` / `htop` | 실시간 CPU·메모리 사용량(`htop`은 설치 필요할 수 있음) | `top` | [5장](05_sysadmin.md) |
| `kill` | 시그널 보내기. 기본 SIGTERM, `-9`는 SIGKILL(마지막 수단) | `kill 1234`, `kill -9 1234` | [5장](05_sysadmin.md) |
| `killall` / `pkill` / `pgrep` | 이름으로 종료 / 조건으로 종료 / 이름으로 PID 찾기 | `sudo killall pigpiod`, `pgrep -a led` | [5장](05_sysadmin.md) |
| `jobs` / `fg` / `bg` | 셸 작업 목록 / 앞으로 / 뒤에서 계속 | Ctrl+Z → `bg %1` | [5장](05_sysadmin.md) |
| `nohup` | 로그아웃해도 계속 실행(SIGHUP 무시) | `nohup ./worker.sh &` | [5장](05_sysadmin.md) |
| `nice` / `renice` | 우선순위(nice 값) 주고 실행 / 바꾸기 | `nice -n 10 ./job` | [5장](05_sysadmin.md) |
| `timeout` | 정한 시간 뒤 자동 종료 | `timeout 5 ./prog` | [5장](05_sysadmin.md) |
| `watch` | 명령을 주기적으로 반복 실행 | `watch -n 1 vcgencmd measure_temp` | [5장](05_sysadmin.md) |
| `chrt` | 실시간 스케줄링 정책(SCHED_FIFO/RR)으로 실행(`sudo` 필요) | `sudo chrt -f 50 ./periodic_gpio` | [11장](11_process_concurrency.md) |
| `ulimit` | 셸의 자원 한도(스택 크기, 코어 파일 등) | `ulimit -s` | [11장](11_process_concurrency.md) |
| `time` | 실행 시간 측정(real/user/sys) | `time make -j4` | [6장](06_c_build.md), [7장](07_boot_kernel.md) |

### C.1.5 패키지

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `apt update` | 저장소의 패키지 목록(카탈로그) 갱신. 설치 전에 먼저 | `sudo apt update` | [5장](05_sysadmin.md) |
| `apt upgrade` / `full-upgrade` | 설치된 패키지 올리기 / 의존성 변화(제거 포함)까지 허용해 올리기 | `sudo apt full-upgrade` | [5장](05_sysadmin.md) |
| `apt install` / `remove` / `purge` | 설치 / 지우기 / 설정 파일까지 지우기 | `sudo apt install i2c-tools` | [5장](05_sysadmin.md) |
| `apt search` / `apt show` | 패키지 찾기 / 정보 보기 | `apt show pigpio` | [5장](05_sysadmin.md) |
| `apt-cache policy` | 설치·후보 버전과 저장소 | `apt-cache policy gcc` | [5장](05_sysadmin.md) |
| `apt-mark` | 패키지 표시 관리: `showmanual` 직접 설치한 것, `hold` 업그레이드 막기 | `apt-mark showmanual \| grep tree` | [5장](05_sysadmin.md) |
| `apt clean` / `autoremove` | 내려받은 패키지 파일 / 필요 없어진 패키지 지우기 | `sudo apt clean` | [5장](05_sysadmin.md) |
| `dpkg -l` / `-L` / `-S` | 설치 목록 / 패키지가 설치한 파일 / 이 파일이 어느 패키지 것인지 | `dpkg -S /bin/ls` | [5장](05_sysadmin.md) |
| `dpkg --configure -a` | 중단된 설치 마무리 | `sudo dpkg --configure -a` | [5장](05_sysadmin.md) |
| `python3 -m venv` | Python 가상 환경 만들기(Bookworm에서 `pip`는 그 안에서) | `python3 -m venv ~/ch13/.venv` | [5장](05_sysadmin.md), [13장](13_ble_iot.md) |
| `source …/activate` / `pip install` | 가상 환경 켜기 / 그 안에 패키지 설치 | `pip install -r requirements.txt` | [13장](13_ble_iot.md) |

### C.1.6 서비스·로그·시간

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `systemctl start` / `stop` / `restart` | 서비스 켜기 / 끄기 / 다시 켜기 | `sudo systemctl stop pigpiod` | [5장](05_sysadmin.md) |
| `systemctl enable` / `disable` (`--now`) | 부팅 때 자동 실행 켜기 / 끄기(`--now`면 지금도) | `sudo systemctl enable --now ssh` | [5장](05_sysadmin.md) |
| `systemctl status` | 상태와 최근 로그 | `systemctl status pigpiod` | [5장](05_sysadmin.md) |
| `systemctl daemon-reload` | 유닛 파일을 고친 뒤 다시 읽기 | `sudo systemctl daemon-reload` | [5장](05_sysadmin.md) |
| `systemctl list-units` / `list-timers` / `set-default` | 유닛 목록 / 타이머 목록 / 기본 target | `sudo systemctl set-default multi-user.target` | [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| `journalctl` | systemd 로그. `-u` 서비스, `-f` 따라가기, `-b` 이번 부팅, `-n` 줄 수, `-k` 커널 | `journalctl -u heartbeat -n 30 --no-pager` | [5장](05_sysadmin.md) |
| `dmesg` | 커널 메시지 | `sudo dmesg \| grep -i i2c` | [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| `systemd-analyze` | 부팅 시간. `blame` 서비스별, `critical-chain` 가장 긴 사슬, `verify` 유닛 검사 | `systemd-analyze blame` | [7장](07_boot_kernel.md) |
| `crontab -e` / `-l` | 예약 작업 편집 / 목록 | `*/5 * * * * /home/student/log.sh` | [5장](05_sysadmin.md) |
| `timedatectl` | 시각·시간대·NTP 동기화 상태 | `timedatectl` | [5장](05_sysadmin.md) |
| `reboot` / `poweroff` | 재부팅 / 끄기 | `sudo reboot` | [5장](05_sysadmin.md) |
| `raspi-config` | Pi 설정 메뉴(인터페이스, 로캘, 로그 등) | `sudo raspi-config` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |

### C.1.7 디스크와 메모리

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `lsblk` | 블록 장치와 파티션 나무. `-f` 파일 시스템, `-o NAME,PARTUUID` | `lsblk -f` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| `df` | 파일 시스템별 사용량. `-h` 읽기 쉽게, `-i` inode | `df -h` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| `du` | 디렉터리 크기 | `du -sh ~/*` | [5장](05_sysadmin.md) |
| `fdisk -l` / `blkid` | 파티션 표 보기 / UUID·종류 보기 | `sudo fdisk -l /dev/mmcblk0` | [5장](05_sysadmin.md) |
| `mount` / `umount` / `findmnt` | 붙이기 / 떼기 / 마운트 상태 보기 | `sudo mount /dev/sda1 /mnt/usb` | [5장](05_sysadmin.md) |
| `mkfs.vfat` / `mkfs.ext4` | 파일 시스템 만들기(**내용이 지워진다**) | `sudo mkfs.ext4 /dev/sda1` | [5장](05_sysadmin.md) |
| `dd` | 장치 통째로 복사(SD 카드 백업). `of=`를 틀리면 디스크를 지운다 | `sudo dd if=/dev/sdb of=pi.img bs=4M status=progress conv=fsync` | [5장](05_sysadmin.md) |
| `sync` | 버퍼의 내용을 저장장치에 쓰기 | `sync` | [5장](05_sysadmin.md) |
| `e2fsck` / `resize2fs` | ext4 검사 / 크기 바꾸기 | `sudo e2fsck -f /dev/sda3` | [7장](07_boot_kernel.md) |
| `lsof` / `fuser` | 그 파일·마운트를 쓰는 프로세스 | `sudo lsof /mnt/usb` | [5장](05_sysadmin.md) |
| `free` | 메모리·스왑 사용량 | `free -h` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| `swapon` / `dphys-swapfile` | 스왑 상태 / Pi의 스왑 파일 관리 | `swapon --show` | [5장](05_sysadmin.md) |

### C.1.8 네트워크와 원격 접속

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `ip addr` / `ip link` / `ip route` | 주소 / 인터페이스 / 경로(게이트웨이) | `ip addr show eth0` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| `hostname -I` | 내 IP 주소만 간단히 | `hostname -I` | [3장](03_rpi_hw_os.md) |
| `ping` | 연결 확인. `-c` 횟수 | `ping -c 4 192.168.0.1` | [3장](03_rpi_hw_os.md) |
| `nmcli` | NetworkManager 설정(고정 IP, Wi-Fi) | `nmcli connection show`, `sudo nmcli radio wifi off` | [3장](03_rpi_hw_os.md) |
| `ss` | 열린 포트와 연결(`-tulpn`) | `sudo ss -tulpn` | [5장](05_sysadmin.md) |
| `ssh` | 원격 셸 접속 | `ssh student@192.168.0.xx` | [3장](03_rpi_hw_os.md), [6장](06_c_build.md) |
| `scp` | SSH로 파일 복사 | `scp Image student@192.168.0.xx:~/mykernel/` | [6장](06_c_build.md), [7장](07_boot_kernel.md) |
| `ssh-keygen` | 키 만들기, `-R` 바뀐 호스트 키 지우기 | `ssh-keygen -R 192.168.0.xx` | [3장](03_rpi_hw_os.md), [6장](06_c_build.md) |
| `curl` / `wget` | URL에서 내려받기·HTTP 요청 | `curl -O https://…/file.zip` (출처를 모르는 `curl … \| sudo bash`는 쓰지 않는다) | [5장](05_sysadmin.md) |

### C.1.9 시스템 정보와 Raspberry Pi 전용 도구

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `uname` | 커널 정보. `-a` 전체, `-r` 릴리스, `-m` CPU 종류(`aarch64`) | `uname -a` | [1장](01_embedded_system.md), [3장](03_rpi_hw_os.md) |
| `lscpu` / `cat /proc/cpuinfo` | CPU 종류·코어·캐시 | `lscpu` | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md) |
| `cat /proc/device-tree/model` | 보드 모델 이름 | `cat /proc/device-tree/model` | [1장](01_embedded_system.md), [7장](07_boot_kernel.md) |
| `getconf` | 시스템 상수(페이지 크기, 캐시 줄 크기) | `getconf PAGESIZE` | [2장](02_computer_arch_arm.md), [11장](11_process_concurrency.md) |
| `sudo cat /proc/iomem` | 물리 주소 공간의 배치(주변장치 레지스터 위치) | `sudo grep -i gpio /proc/iomem` | [2장](02_computer_arch_arm.md) |
| `uptime` | 켜진 시간과 부하 평균 | `uptime` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| `vcgencmd get_throttled` | 저전압·과열 스로틀링 비트(0이면 정상) | `vcgencmd get_throttled` | [3장](03_rpi_hw_os.md) |
| `vcgencmd measure_temp` / `measure_clock arm` / `measure_volts` | SoC 온도 / ARM 클록 / 전압 | `vcgencmd measure_temp` | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| `vcgencmd get_config` | 펌웨어가 실제로 적용한 `config.txt` 값 | `vcgencmd get_config arm_64bit` | [7장](07_boot_kernel.md) |
| `vclog --msg` | 펌웨어 로그(오버레이 적용 기록 등) | `sudo vclog --msg` | [7장](07_boot_kernel.md) |
| `rpi-eeprom-update` / `rpi-eeprom-config` | 부트로더 EEPROM 버전 확인·갱신 / 설정 보기 | `sudo rpi-eeprom-update` | [7장](07_boot_kernel.md) |
| `pinout` | 40핀 헤더 그림 | `pinout` | [3장](03_rpi_hw_os.md), [8장](08_gpio_pigpio.md) |
| `lsmod` / `modinfo` / `modprobe` | 올라온 모듈 / 모듈 정보 / 모듈 올리기(`-r` 내리기) | `sudo modprobe i2c-dev` | [7장](07_boot_kernel.md) |
| `insmod` / `rmmod` / `depmod` | 파일로 모듈 넣기 / 빼기 / 의존성 목록 갱신 | `sudo insmod hello.ko` | [7장](07_boot_kernel.md) |
| `dtc` | device tree 컴파일·역컴파일. `-I fs`로 살아 있는 트리 읽기 | `dtc -I fs /proc/device-tree \| less` | [7장](07_boot_kernel.md) |
| `dtoverlay -l` / `-h` | 실행 중에 적용한 오버레이 목록 / 오버레이 도움말 | `dtoverlay -h i2c-rtc` | [7장](07_boot_kernel.md) |

### C.1.10 하드웨어 인터페이스 도구

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `pinctrl get` | 핀의 기능(입력·출력·ALT)과 현재 레벨 | `pinctrl get 17`, `pinctrl get 2,3,7-11,14,15` | [8장](08_gpio_pigpio.md) |
| `pinctrl set` | 핀 설정. `op` 출력, `ip` 입력, `dh`/`dl` High/Low, `pu`/`pd`/`pn` 풀업/풀다운/없음 | `pinctrl set 17 op dh`, `pinctrl set 26 ip pu` | [8장](08_gpio_pigpio.md) |
| `pinctrl -p` / `funcs` / `poll` | 물리 핀 번호 순 표 / 핀의 ALT 기능 목록 / 레벨 변화 감시 | `pinctrl funcs 18` | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md) |
| `raspi-gpio` | `pinctrl` 이전의 같은 용도 도구(레거시) | `raspi-gpio get 17` | [8장](08_gpio_pigpio.md) |
| `pigs` | pigpiod 데몬에 명령 보내기(C.2절 표 참고) | `pigs w 17 1` | [8장](08_gpio_pigpio.md) |
| `gpiodetect` / `gpioinfo` | GPIO 칩 목록 / 줄(line)별 상태와 사용자(consumer) | `gpioinfo gpiochip0` | [8장](08_gpio_pigpio.md) |
| `gpioset` / `gpioget` / `gpiomon` | libgpiod 1.6 문법으로 출력 / 입력 / 에지 감시 | `gpioset --mode=time --sec=1 gpiochip0 17=1` | [8장](08_gpio_pigpio.md), [부록 B](appendix_b_gpio_libraries.md) |
| `i2cdetect` | I2C 버스의 주소 스캔(`UU`는 커널 드라이버 사용 중) | `sudo i2cdetect -y 1` | [7장](07_boot_kernel.md), [12장](12_communication.md) |
| `i2cget` / `i2cset` / `i2cdump` | 레지스터 1바이트 읽기 / 쓰기 / 전체 덤프 | `sudo i2cget -y 1 0x68 0x00` | [12장](12_communication.md) |
| `stty` | 시리얼 포트 설정 확인·변경 | `stty -F /dev/serial0 9600 cs8 -cstopb -parenb` | [10장](10_measurement.md) |
| `hwclock` | RTC 칩(커널 드라이버 사용 시)의 시각 읽기·쓰기 | `sudo hwclock -r` | [12장](12_communication.md) |
| `bluetoothctl` | Bluetooth 장치 스캔·페어링·GATT 탐색 | `bluetoothctl show`, `bluetoothctl scan on` | [13장](13_ble_iot.md) |
| `btmgmt` / `btmon` | 컨트롤러 정보 / HCI 수준 패킷 감시 | `sudo btmgmt info`, `sudo btmon` | [13장](13_ble_iot.md) |
| `rfkill` | 무선 장치 차단 상태 확인·해제 | `sudo rfkill unblock bluetooth` | [13장](13_ble_iot.md) |
| `sqlite3` | SQLite 데이터베이스 셸 | `sqlite3 temperature.db "SELECT COUNT(*) FROM temperature;"` | [13장](13_ble_iot.md) |

### C.1.11 빌드와 디버깅 도구

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `gcc` | C 컴파일·링크. `-E` 전처리만, `-S` 어셈블리까지, `-c` 목적 파일까지, `-o` 출력 이름, `-Wall` 경고, `-g` 디버그 정보, `-O0`~`-O3` 최적화, `-I`/`-L`/`-l` 헤더 경로·라이브러리 경로·라이브러리 | `gcc -Wall -o led_blink led_blink.c -lpigpio -lrt -pthread` | [6장](06_c_build.md) |
| `gcc -MMD -MP` | 헤더 의존성 파일(`.d`) 자동 생성 | Makefile의 `CFLAGS`에 넣는다 | [6장](06_c_build.md) |
| `gcc -fsanitize=thread` / `address` | 데이터 경쟁 / 메모리 오류 검사 빌드 | `gcc -g -fsanitize=thread -pthread …` | [11장](11_process_concurrency.md) |
| `aarch64-linux-gnu-gcc` | PC에서 Pi용(AArch64) 실행 파일 만들기(교차 컴파일러) | `aarch64-linux-gnu-gcc -o hello hello.c` | [6장](06_c_build.md), [7장](07_boot_kernel.md) |
| `make` | Makefile대로 빌드. `-B` 전부 다시, `-j4` 병렬, `clean` 같은 가짜 대상 | `make`, `make clean && make` | [6장](06_c_build.md) |
| `ar` | 정적 라이브러리(`.a`) 만들기 | `ar rcs libmylib.a mylib.o` | [6장](06_c_build.md) |
| `ldd` / `ldconfig` | 실행 파일이 쓰는 공유 라이브러리 / 라이브러리 캐시 갱신 | `ldd ./led_blink`, `sudo ldconfig` | [6장](06_c_build.md) |
| `nm` / `size` / `strings` / `strip` | 심볼 목록 / 섹션 크기 / 문자열 / 디버그·심볼 정보 제거 | `size hello`, `nm hello \| grep main` | [6장](06_c_build.md) |
| `objdump` | 역어셈블(`-d`), 섹션 헤더(`-h`) | `objdump -d asm_demo.o` | [2장](02_computer_arch_arm.md), [6장](06_c_build.md) |
| `readelf` | ELF 헤더(`-h`), 섹션(`-S`), 세그먼트(`-l`), 동적 정보(`-d`) | `readelf -S hello` | [6장](06_c_build.md) |
| `gdb` | 디버거. `break`, `run`, `next`, `step`, `finish`, `print`, `display`, `watch`, `backtrace`, `info breakpoints`, `continue`, `quit` | `gdb ./scores` | [6장](06_c_build.md) |
| `gdb -p` | 실행 중인 프로세스에 붙기. `thread apply all bt`로 모든 스레드의 호출 스택 | `sudo gdb -p $(pgrep -n deadlock) -batch -ex "thread apply all bt"` | [11장](11_process_concurrency.md) |
| `valgrind` | 메모리 누수 검사 | `valgrind --leak-check=full ./prog` | [11장](11_process_concurrency.md) |

### C.1.12 Git

| 명령 | 하는 일 | 예 | 다루는 장 |
|---|---|---|---|
| `git config --global` | 이름·이메일 등 설정(처음 한 번) | `git config --global user.name "홍길동"` | [6장](06_c_build.md) |
| `git init` / `git clone` | 새 저장소 만들기 / 원격 저장소 복제(`--depth=1` 최근 것만) | `git clone --depth=1 --branch rpi-6.12.y https://github.com/raspberrypi/linux` | [6장](06_c_build.md), [7장](07_boot_kernel.md) |
| `git status` / `git diff` | 바뀐 파일 / 바뀐 내용 | `git status --short` | [6장](06_c_build.md) |
| `git add` / `git commit` | 스테이징 / 커밋 | `git commit -m "LED 주기 변경"` | [6장](06_c_build.md) |
| `git log --oneline` | 커밋 이력 한 줄씩 | `git log --oneline` | [6장](06_c_build.md) |
| `git restore` | 작업 폴더의 변경 되돌리기 | `git restore led_blink.c` | [6장](06_c_build.md) |
| `git push` / `git pull` | 원격으로 올리기 / 받아 합치기 | `git pull` | [6장](06_c_build.md) |

---

## C.2 pigpio API 빠른 참조

pigpio를 쓰는 방법은 두 가지이다([8장](08_gpio_pigpio.md) 8.5절).

| 방식 | 헤더 / 링크 | 실행 | 특징 |
|---|---|---|---|
| **A. C 라이브러리 직접** | `#include <pigpio.h>`, `-lpigpio -lrt -pthread` | `sudo ./prog` | 하드웨어에 직접 접근. pigpiod가 돌고 있으면 `Can't lock /var/run/pigpio.pid`로 실패 |
| **B. 데몬 + 클라이언트** | `#include <pigpiod_if2.h>`, `-lpigpiod_if2 -lrt -pthread` | `./prog` (먼저 `sudo systemctl start pigpiod`) | 소켓으로 pigpiod에 요청. 함수 이름이 다르고 첫 인자가 `pi`. `pigs`와 Python 클라이언트도 이 방식 |

아래 표는 방식 A의 함수 이름이다. 반환값이 음수이면 오류이고, 오류 번호의 뜻은 `pigpio.h`의 `PI_*` 상수로 확인한다(예: `PI_BAD_ISR_INIT` = −123, `PI_NOT_HPWM_GPIO` = −95). `pigs` 열은 같은 일을 하는 셸 명령이다(대소문자 무관). WiringPi 함수와의 대응은 [부록 B](appendix_b_gpio_libraries.md)의 B.3절 대응표를 본다.

### C.2.1 초기화·기본 입출력·시간

| C 함수 | 하는 일 | `pigs` | 다루는 장 |
|---|---|---|---|
| `gpioInitialise()` | 라이브러리 시작. 성공하면 버전 번호(0 이상), 실패하면 `PI_INIT_FAILED` | — | [8장](08_gpio_pigpio.md) |
| `gpioTerminate()` | 라이브러리 종료(DMA·핀 정리). 프로그램 끝에 반드시 | — | [8장](08_gpio_pigpio.md) |
| `gpioVersion()` / `gpioHardwareRevision()` | pigpio 버전 / 보드 리비전 코드 | `pigpv` / `hwver` | [8장](08_gpio_pigpio.md) |
| `gpioSetSignalFunc(SIGINT, f)` | Ctrl+C 등의 시그널 처리 함수 등록(플래그만 세운다) | — | [8장](08_gpio_pigpio.md) |
| `gpioSetMode(g, mode)` | `PI_INPUT`, `PI_OUTPUT`, `PI_ALT0`~`PI_ALT5` | `m g r` / `m g w` | [8장](08_gpio_pigpio.md) |
| `gpioGetMode(g)` | 현재 모드 | `mg g` | [8장](08_gpio_pigpio.md) |
| `gpioSetPullUpDown(g, pud)` | `PI_PUD_UP`, `PI_PUD_DOWN`, `PI_PUD_OFF` (원본 자료의 `gpioSetPullUpDn`은 없는 이름) | `pud g u` / `d` / `o` | [8장](08_gpio_pigpio.md) |
| `gpioRead(g)` / `gpioWrite(g, level)` | 읽기 / 쓰기(0 또는 1) | `r g` / `w g 1` | [8장](08_gpio_pigpio.md) |
| `gpioDelay(us)` | μs 단위 지연 | `mics us` / `mils ms` | [8장](08_gpio_pigpio.md) |
| `time_sleep(sec)` | 초 단위(실수) 지연 | — | [8장](08_gpio_pigpio.md) |
| `gpioTick()` | 부팅 후 μs 카운터(32비트, 약 71.6분마다 0으로 돌아감). 차이는 `uint32_t` 뺄셈으로 | `t` | [9장](09_pigpio_advanced.md) |
| `gpioSetPad(pad, mA)` / `gpioGetPad(pad)` | 핀 그룹(pad)의 구동 세기 설정 / 읽기 | `pads` / `padg` | [10장](10_measurement.md) |
| `gpioCfgClock(us, periph, 0)` | 샘플링 주기·박자 주변장치 설정. **`gpioInitialise()` 전에** 부른다 | (`pigpiod -s`, `-t`) | [9장](09_pigpio_advanced.md) |

### C.2.2 콜백·인터럽트·타이머

| C 함수 | 하는 일 | `pigs` | 다루는 장 |
|---|---|---|---|
| `gpioSetAlertFunc(g, f)` | 레벨이 바뀌면 `f(gpio, level, tick)` 호출(DMA 샘플링, 별도 스레드). `f`에 `NULL`이면 해제 | — | [9장](09_pigpio_advanced.md), [11장](11_process_concurrency.md) |
| `gpioSetAlertFuncEx(g, f, userdata)` | 위와 같고 사용자 포인터를 함께 넘김 | — | [9장](09_pigpio_advanced.md) |
| `gpioSetISRFunc(g, edge, timeout, f)` | 커널 인터럽트(sysfs) 경로의 콜백. **pigpio v79 + 최신 커널에서 `PI_BAD_ISR_INIT`(−123)** → 알림 콜백을 쓴다 | — | [9장](09_pigpio_advanced.md), [부록 B](appendix_b_gpio_libraries.md) |
| `gpioSetISRFuncEx(…, userdata)` | 위와 같고 사용자 포인터 포함 | — | [부록 B](appendix_b_gpio_libraries.md) |
| `gpioGlitchFilter(g, steady_us)` | 그 시간 이상 유지된 변화만 알림(디바운스) | `fg g us` | [9장](09_pigpio_advanced.md) |
| `gpioNoiseFilter(g, steady, active)` | 잡음 구간 거르기 | `fn g …` | [9장](09_pigpio_advanced.md) |
| `gpioSetWatchdog(g, ms)` | 변화가 없으면 `level = PI_TIMEOUT`(2)으로 콜백 | `wdog g ms` | [9장](09_pigpio_advanced.md) |
| `gpioSetTimerFunc(timer, ms, f)` | 주기 타이머 콜백(타이머 0~9, 상대 시간 반복) | — | [11장](11_process_concurrency.md) |
| `gpioStartThread(f, arg)` / `gpioStopThread(t)` | pigpio의 스레드 도우미 | — | [11장](11_process_concurrency.md), [부록 B](appendix_b_gpio_libraries.md) |

### C.2.3 PWM·서보·펄스

| C 함수 | 하는 일 | `pigs` | 다루는 장 |
|---|---|---|---|
| `gpioPWM(g, duty)` | DMA(소프트웨어 타이밍) PWM. 듀티 0~range(기본 255). 아무 핀 | `p g duty` (**`p`는 듀티**) | [9장](09_pigpio_advanced.md) |
| `gpioSetPWMfrequency(g, f)` / `gpioGetPWMfrequency(g)` | 주파수 요청 / 실제 주파수(18개 허용값 중 가까운 값) | `pfs g f` / `pfg g` | [9장](09_pigpio_advanced.md) |
| `gpioSetPWMrange(g, r)` / `gpioGetPWMrange(g)` / `gpioGetPWMrealRange(g)` | 듀티 범위 설정 / 설정값 / 실제 분해능 | `prs` / `prg` / `prrg` | [9장](09_pigpio_advanced.md) |
| `gpioHardwarePWM(g, freq, duty)` | 하드웨어 PWM. **GPIO12/13/18/19만**, 듀티 0~1,000,000. 12·18과 13·19는 같은 채널 | `hp g f d` | [9장](09_pigpio_advanced.md), [10장](10_measurement.md) |
| `gpioHardwareClock(g, f)` | GPCLK 핀(GPIO4 등)에 클록 출력 | `hc g f` | [부록 B](appendix_b_gpio_libraries.md) |
| `gpioServo(g, us)` | 서보 펄스 폭 500~2500 μs(0이면 끔), 50 Hz | `s g us` | [9장](09_pigpio_advanced.md) |
| `gpioGetServoPulsewidth(g)` | 현재 서보 펄스 폭 | `gpw g` | [9장](09_pigpio_advanced.md) |
| `gpioTrigger(g, len_us, level)` | 1~100 μs 펄스 한 번(HC-SR04 TRIG) | `trig g len lvl` | [9장](09_pigpio_advanced.md) |

### C.2.4 웨이브폼

| C 함수 | 하는 일 | `pigs` | 다루는 장 |
|---|---|---|---|
| `gpioWaveClear()` | 만들던 펄스 지우기 | `wvclr` | [9장](09_pigpio_advanced.md) |
| `gpioWaveAddGeneric(n, pulses)` | 펄스 목록(켤 비트, 끌 비트, 지연) 추가 | `wvag …` | [9장](09_pigpio_advanced.md) |
| `gpioWaveAddSerial(…)` | 비트뱅 직렬 데이터 추가 | `wvas …` | [9장](09_pigpio_advanced.md) |
| `gpioWaveCreate()` | 지금까지의 펄스로 웨이브폼 만들기(ID 반환) | `wvcre` | [9장](09_pigpio_advanced.md) |
| `gpioWaveTxSend(id, mode)` | 보내기(`PI_WAVE_MODE_ONE_SHOT`, `…_REPEAT`) | `wvtx id` / `wvtxr id` | [9장](09_pigpio_advanced.md) |
| `gpioWaveTxBusy()` / `gpioWaveTxStop()` | 송신 중인지 / 멈추기 | `wvbsy` / `wvhlt` | [9장](09_pigpio_advanced.md) |
| `gpioWaveChain(buf, n)` | 여러 웨이브폼을 이어 보내기 | `wvcha …` | [9장](09_pigpio_advanced.md) |
| `gpioWaveGetMicros()` / `gpioWaveDelete(id)` | 웨이브폼 길이(μs) / 지우기 | `wvsm 0` / `wvdel id` | [9장](09_pigpio_advanced.md) |

### C.2.5 UART·I2C·SPI·비트뱅

| C 함수 | 하는 일 | `pigs` | 다루는 장 |
|---|---|---|---|
| `serOpen(tty, baud, 0)` | 시리얼 장치 열기(핸들 반환). 예: `serOpen("/dev/serial0", 115200, 0)` | `sero …` | [12장](12_communication.md) |
| `serWriteByte(h, b)` / `serReadByte(h)` | 1바이트 쓰기 / 읽기(데이터가 없으면 바로 음수) | `serwb` / `serrb` | [12장](12_communication.md) |
| `serWrite(h, buf, n)` / `serRead(h, buf, n)` | 여러 바이트 쓰기 / 읽기 | `serw` / `serr` | [12장](12_communication.md) |
| `serDataAvailable(h)` / `serClose(h)` | 받은 바이트 수 / 닫기 | `serda` / `serc` | [12장](12_communication.md) |
| `i2cOpen(bus, addr, 0)` | I2C 장치 열기(버스 1 = `/dev/i2c-1`, 7비트 주소) | `i2co 1 0x27 0` | [12장](12_communication.md) |
| `i2cWriteQuick(h, bit)` | 주소만 보내 ACK 확인(스캔) | `i2cwq` | [12장](12_communication.md) |
| `i2cWriteByte(h, b)` / `i2cReadByte(h)` | 레지스터 없이 1바이트 쓰기 / 읽기(PCF8574) | `i2cws` / `i2crs` | [12장](12_communication.md) |
| `i2cWriteByteData(h, reg, b)` / `i2cReadByteData(h, reg)` | 레지스터에 1바이트 쓰기 / 읽기 | `i2cwb` / `i2crb` | [12장](12_communication.md) |
| `i2cWriteWordData` / `i2cReadWordData` | 레지스터에 2바이트 쓰기 / 읽기 | `i2cww` / `i2crw` | [12장](12_communication.md) |
| `i2cWriteI2CBlockData(h, reg, buf, n)` / `i2cReadI2CBlockData(h, reg, buf, n)` | 레지스터부터 여러 바이트 쓰기 / 읽기(DS3231, BMP280) | `i2cwi` / `i2cri` | [12장](12_communication.md) |
| `i2cWriteDevice` / `i2cReadDevice` | 레지스터 개념 없이 원시 바이트열 | `i2cwd` / `i2crd` | [12장](12_communication.md) |
| `i2cClose(h)` | 닫기 | `i2cc` | [12장](12_communication.md) |
| `spiOpen(chan, baud, flags)` | SPI 열기. `chan` 0 = CE0(GPIO8), 1 = CE1(GPIO7). `flags` 하위 2비트가 모드. 커널 `spi=on` 불필요 | `spio` | [12장](12_communication.md) |
| `spiXfer(h, tx, rx, n)` | 전이중 교환(MCP3008) | `spix` | [12장](12_communication.md) |
| `spiRead` / `spiWrite` / `spiClose` | 읽기만 / 쓰기만 / 닫기 | `spir` / `spiw` / `spic` | [12장](12_communication.md) |
| `bbI2COpen(sda, scl, baud)` | 아무 GPIO로 소프트웨어 I2C(클록 스트레칭 대안) | `bi2co` | [12장](12_communication.md) |
| `bbSPIOpen` / `bbSPIXfer` / `bbSPIClose` | 아무 GPIO로 소프트웨어 SPI | `bspio` / `bspix` / `bspic` | [12장](12_communication.md) |

### C.2.6 데몬 클라이언트(`pigpiod_if2`)

| 방식 A 함수 | 방식 B 함수(`pigpiod_if2`) | 비고 |
|---|---|---|
| `gpioInitialise()` | `pi = pigpio_start(NULL, NULL)` | 원격이면 `pigpio_start("192.168.0.xx", "8888")`. 데몬이 원격을 허용해야 한다([8장](08_gpio_pigpio.md) 8.6절) |
| `gpioTerminate()` | `pigpio_stop(pi)` | |
| `gpioSetMode(g, m)` | `set_mode(pi, g, m)` | |
| `gpioSetPullUpDown(g, p)` | `set_pull_up_down(pi, g, p)` | |
| `gpioRead(g)` / `gpioWrite(g, v)` | `gpio_read(pi, g)` / `gpio_write(pi, g, v)` | |
| `gpioPWM(g, d)` | `set_PWM_dutycycle(pi, g, d)` | |
| `gpioHardwarePWM(g, f, d)` | `hardware_PWM(pi, g, f, d)` | |
| `gpioServo(g, us)` | `set_servo_pulsewidth(pi, g, us)` | |
| `gpioSetAlertFunc(g, f)` | `id = callback(pi, g, edge, f)` / `callback_cancel(id)` | 콜백 함수의 인자에 `pi`가 더 붙는다 |
| `gpioTick()` | `get_current_tick(pi)` | |

> 데몬 관리: `sudo systemctl start pigpiod`(지금 켜기), `enable`(부팅 때 켜기), `stop`/`disable`(끄기). 방식 A 프로그램을 실행하기 전에는 **반드시 데몬을 끈다.** 기본 데몬은 로컬 접속만 받는다(`-l`). 자세한 것은 [8장](08_gpio_pigpio.md) 8.5~8.7절.

---

## C.3 설정 파일 빠른 참조

### C.3.1 `/boot/firmware/config.txt`

펌웨어가 부팅 때 읽는 설정 파일이다. 철자가 틀려도 오류 없이 **무시**되므로, 적용 여부는 `vcgencmd get_config 이름`으로 확인한다. 고치기 전에 `config.txt.bak`을 만들고, 새 설정은 파일 끝의 `[all]` 아래에 쓴다([3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md)).

| 설정 | 뜻 | 다루는 장 |
|---|---|---|
| `enable_uart=1` | 기본 UART(GPIO14/15)를 켠다. UART 콘솔의 필수 조건 | [3장](03_rpi_hw_os.md) |
| `dtoverlay=disable-bt` | Bluetooth를 끄고 PL011(UART0)을 GPIO14/15로(`serial0 → ttyAMA0`). BLE를 쓰려면 이 줄을 주석 처리 | [3장](03_rpi_hw_os.md), [13장](13_ble_iot.md) |
| `uart_2ndstage=1` | 펌웨어(`start4.elf`)의 진단 메시지(`MESS:`)를 UART로 | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md) |
| `core_freq=250` | 코어 클록 고정. `miniuart-bt`처럼 mini UART를 보조 UART로 쓸 때 필요(기본 UART가 mini UART이면 `enable_uart=1`만으로 펌웨어가 250 MHz로 고정) | [13장](13_ble_iot.md) |
| `disable_splash=1` | 펌웨어의 **무지개 화면만** 끈다(부팅 로그와는 무관) | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md) |
| `arm_64bit=1` | 64비트 커널로 부팅 | [7장](07_boot_kernel.md) |
| `kernel=파일명` | 부팅할 커널 이미지(기본 `kernel8.img`). 직접 빌드한 커널은 **새 이름**으로 | [7장](07_boot_kernel.md) |
| `auto_initramfs=1` | 커널 이름에 맞는 initramfs를 자동으로 함께 읽기 | [7장](07_boot_kernel.md) |
| `os_prefix=` | 커널·DTB·overlays를 찾을 접두 경로(버전이 크게 다른 커널을 분리할 때) | [7장](07_boot_kernel.md) |
| `dtparam=i2c_arm=on`, `dtparam=i2c_arm_baudrate=100000` | I2C1(GPIO2/3) 켜기, 속도 설정 | [7장](07_boot_kernel.md), [12장](12_communication.md) |
| `dtparam=spi=on` | 커널 SPI0 드라이버(`/dev/spidev0.0`) 켜기. pigpio `spiOpen`에는 불필요 | [12장](12_communication.md) |
| `dtparam=audio=on` | 아날로그 오디오. 하드웨어 PWM과 주변장치를 공유한다 | [7장](07_boot_kernel.md), [9장](09_pigpio_advanced.md) |
| `dtoverlay=vc4-kms-v3d` | 그래픽(KMS) 드라이버 | [7장](07_boot_kernel.md) |
| `dtoverlay=i2c-rtc,ds3231` | DS3231을 커널 RTC 드라이버로(그러면 `i2cdetect`에 `UU`, pigpio로는 못 연다) | [12장](12_communication.md) |
| `dtoverlay=i2c-gpio` | GPIO로 만든 소프트웨어 I2C 버스. SoC 기본 핀은 SDA GPIO23, SCL GPIO24로 표준 배선의 LED3·LED4 자리이므로, 쓸 때는 `i2c_gpio_sda=`·`i2c_gpio_scl=`로 핀을 지정한다(이 책의 실습은 쓰지 않는다) | [12장](12_communication.md) |
| `dtoverlay=uart2`~`uart5`, `i2c3`~`i2c6`, `spi3-1cs` 등 | BCM2711의 추가 UART·I2C·SPI 켜기(핀이 다른 기능과 겹치는지 확인) | [12장](12_communication.md) |
| `enable_jtag_gpio=1` | GPIO22~27을 ARM JTAG로. 표준 배선의 LED1~LED5·BTN0 자리이므로 C.4.1의 ⚠ 핀 예외 ③대로 그 배선을 빼고 쓴다 | [7장](07_boot_kernel.md) |
| `gpu_mem=16` | 축소 펌웨어가 선택되어 카메라 등 일부 기능이 빠진다. 주의해서 쓴다 | [7장](07_boot_kernel.md) |
| `arm_freq`, `over_voltage`, `force_turbo` | 오버클록 관련. **수업에서는 쓰지 않는다**(보증에 영향을 주는 표시가 남을 수 있다) | [7장](07_boot_kernel.md) |
| `[all]`, `[pi4]`, `[gpio26=0]` 등 | 조건부 필터. 아래 줄들이 그 조건에서만 적용된다. 종류가 다른 필터를 연달아 쓰면 AND | [7장](07_boot_kernel.md) |

### C.3.2 `/boot/firmware/cmdline.txt`

커널에 넘기는 매개변수이다. **반드시 한 줄**이어야 한다(줄바꿈이 들어가면 둘째 줄부터 무시되어 부팅이 안 될 수 있다). 현재 값은 `cat /proc/cmdline`으로 본다.

| 매개변수 | 뜻 | 다루는 장 |
|---|---|---|
| `console=serial0,115200` | 커널 메시지와 로그인 콘솔을 UART로(115200 bps). UART를 내 프로그램이 쓸 때는 지운다 | [3장](03_rpi_hw_os.md), [12장](12_communication.md) |
| `console=tty1` | HDMI 화면 콘솔 | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md) |
| `root=PARTUUID=xxxxxxxx-02` | 루트 파일 시스템 파티션. 틀리면 `Kernel panic … Unable to mount root fs` | [7장](07_boot_kernel.md) |
| `rootfstype=ext4` | 루트 파일 시스템 종류 | [7장](07_boot_kernel.md) |
| `rootwait` | 루트 장치가 나타날 때까지 기다림 | [7장](07_boot_kernel.md) |
| `fsck.repair=yes` | 부팅 때 파일 시스템 자동 복구 | [7장](07_boot_kernel.md) |
| `quiet`, `loglevel=7`/`8` | 커널 메시지 줄이기 / 자세히 | [7장](07_boot_kernel.md) |
| `earlycon` | 콘솔 드라이버 준비 전의 아주 초기 메시지까지 출력(arm64에서 `earlyprintk`는 쓰지 않는다) | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md) |
| `init=/bin/sh` | systemd 대신 셸로 부팅(응급 복구용, 끝나면 반드시 지운다) | [5장](05_sysadmin.md) |
| `isolcpus=2,3` 등 | 특정 코어를 일반 스케줄링에서 빼기(실시간 실험) | [7장](07_boot_kernel.md) |

### C.3.3 systemd 유닛 파일

서비스 유닛은 `/etc/systemd/system/이름.service`에 두고, 고친 뒤에는 `sudo systemctl daemon-reload`를 한다. 유닛 파일 권한은 `644`이다([5장](05_sysadmin.md)).

| 절 | 키 | 뜻 |
|---|---|---|
| `[Unit]` | `Description=` | 설명 |
| | `After=` / `Wants=` / `Requires=` | 이 유닛 뒤에 시작 / 약한 의존(같이 시작 시도) / 강한 의존(그것이 실패하면 이것도) |
| `[Service]` | `Type=` | `simple`(기본), `oneshot`(한 번 실행하고 끝나는 작업) 등 |
| | `ExecStart=` | 실행할 명령. **절대 경로** |
| | `WorkingDirectory=` | 작업 디렉터리 |
| | `User=` / `DynamicUser=yes` | 실행 사용자 / 임시 사용자 자동 생성 |
| | `Environment=` / `EnvironmentFile=` | 환경 변수 / 환경 변수 파일(비밀 정보를 코드 밖에 둔다) |
| | `Restart=` / `RestartSec=` | 죽으면 다시 띄울 조건(`on-failure`, `always`) / 기다릴 시간 |
| | `KillSignal=` | 멈출 때 보낼 시그널(기본 SIGTERM) |
| `[Install]` | `WantedBy=multi-user.target` | `enable`할 때 어느 target에 걸지 |
| `[Timer]` (`.timer`) | `OnBootSec=` / `OnUnitActiveSec=` / `OnCalendar=` | 부팅 뒤 / 마지막 실행 뒤 / 달력 시각에 실행 |

> 서비스의 `printf`가 journal에 늦게 보이면 출력 버퍼링 때문이다. C는 `fflush(stdout)` 또는 `ExecStart=/usr/bin/stdbuf -oL …`, Python은 `Environment=PYTHONUNBUFFERED=1`([5장](05_sysadmin.md), [13장](13_ble_iot.md)).

### C.3.4 Makefile

레시피(명령) 줄은 반드시 **탭**으로 시작한다. 자동 변수는 [6장](06_c_build.md) 6.9절의 표를 그대로 옮겼다.

| 자동 변수 | 뜻 | 예 |
|---|---|---|
| `$@` | 규칙의 **대상** 이름 | `templog` |
| `$<` | **첫 번째** 의존 파일 이름 | `main.o` |
| `$^` | **모든** 의존 파일 이름(중복 제거, 공백으로 구분) | `main.o sensor.o util.o` |
| `$?` | 대상보다 **더 최근에 수정된** 의존 파일 **모두**(대상이 없으면 의존 파일 전부) | `util.h`만 고쳤다면 `main.o util.o` |
| `$*` | 패턴 규칙에서 `%`에 해당한 부분(줄기, stem) | `%.o: %.c`로 `util.o`를 만들 때 `util` |

| 관례적 변수·규칙 | 뜻 |
|---|---|
| `CC = gcc` | 컴파일러 |
| `CFLAGS = -Wall -O2 -g -MMD -MP` | 컴파일 옵션(경고, 최적화, 디버그 정보, 헤더 의존성 파일 생성) |
| `LDFLAGS` / `LDLIBS = -lpigpio -lrt -pthread` | 링크 옵션 / 라이브러리(소스·목적 파일 **뒤에** 온다) |
| `%.o: %.c` | 패턴 규칙: 같은 이름의 `.c`로 `.o`를 만든다 |
| `-include $(DEPS)` | `-MMD`가 만든 `.d` 파일을 읽어 헤더 의존성 반영 |
| `.PHONY: all clean` | 파일 이름이 아닌 가짜 대상 |

---

## C.4 핀 배치 요약

이 책은 **하나의 표준 핀 계획**만 쓴다. 한 핀에는 한 역할만 주고, 한 번 꽂은 부품(LED 바, 버튼, 레벨 시프터 등)은 학기 내내 그대로 두어도 다른 실습과 겹치지 않게 정했다. 배선 방법, 헤더 그림, 레벨 시프터의 원리는 [8장](08_gpio_pigpio.md) 8.2.4절 **이 교재의 표준 배선**에 있고, 40핀 헤더 전체 표와 전기적 특성은 8.2.1절과 8.1절에 있다. 여기서는 그 계획을 **BCM 번호 순으로** 다시 정리하고, 각 핀을 어느 장·실습·예제가 쓰는지 모았다.

### C.4.1 핀별 사용표

"LED 바 예제"는 [부록 B](appendix_b_gpio_libraries.md)의 `blink8_pigpio`, `blink12_pigpio`, `softpwm_pigpio`처럼 LED0~LED7 8개를 모두 쓰는 예제를 말한다. 부록 B 예제 이름에서는 `_pigpio`를 뺐다.

| BCM | 물리 핀 | 표준 역할 | 이 책에서 쓰는 곳 | AD2 DIO | 주의 |
|---|:-:|---|---|:-:|---|
| GPIO0 | 27 | **사용 금지** (HAT ID EEPROM, I2C0 SDA) | 쓰지 않는다 | | 예약 핀. 아무것도 꽂지 않는다 |
| GPIO1 | 28 | **사용 금지** (HAT ID EEPROM, I2C0 SCL) | 쓰지 않는다 | | 예약 핀 |
| GPIO2 | 3 | I2C1 SDA (보드에 1.8 kΩ 풀업) | [7장](07_boot_kernel.md) 실습 7-2(I2C 켜기), [10장](10_measurement.md) 실습 10-6, [12장](12_communication.md) 실습 12-3(LCD)·12-4(DS3231)·12-7(BMP280) | DIO15 | 3.3 V 장치는 직결. 5 V 장치(PCF8574 LCD)는 레벨 시프터 **LV1 ↔ HV1** |
| GPIO3 | 5 | I2C1 SCL (보드에 1.8 kΩ 풀업) | GPIO2와 같다 | DIO14 | 5 V 장치는 레벨 시프터 **LV2 ↔ HV2** |
| GPIO4 | 7 | DHT11 / RHT03 데이터 | [부록 B](appendix_b_gpio_libraries.md) `rht03`, `dht11`(B.4.16) | | 센서 전원 3.3 V, 데이터선 4.7~10 kΩ 풀업. GPCLK0 기능도 있다 |
| GPIO5 | 29 | LED6 | [8장](08_gpio_pigpio.md) 실습 8-4, 부록 B LED 바 예제 | | ⚠ 로터리 엔코더 A (아래 예외 ②) |
| GPIO6 | 31 | LED7 | GPIO5와 같다 | | ⚠ 로터리 엔코더 B (예외 ②) |
| GPIO7 | 26 | SPI0 CE1 | (예비. 이 책의 실습은 CE0만 쓴다) | | SPI0 핀이므로 다른 용도로 쓰지 않는다 |
| GPIO8 | 24 | SPI0 CE0 (MCP3008 CS) | [10장](10_measurement.md) 실습 10-7, [12장](12_communication.md) 실습 12-5, [부록 A](appendix_a_matlab_simulink.md) `spidev(rpi, 'CE0')` | DIO10 | MCP3008 전원은 3.3 V |
| GPIO9 | 21 | SPI0 MISO (MCP3008 DOUT) | 10장 실습 10-7, 12장 실습 12-5 | DIO13 | |
| GPIO10 | 19 | SPI0 MOSI (MCP3008 DIN) | 10장 실습 10-7, 12장 실습 12-5 | DIO12 | |
| GPIO11 | 23 | SPI0 SCLK (MCP3008 CLK) | 10장 실습 10-7, 12장 실습 12-5 | DIO11 | |
| GPIO12 | 32 | DS1302 CE | [12장](12_communication.md) 실습 12-6 | DIO4 | 하드웨어 PWM0 핀이지만 DS1302용 **일반 출력**으로만 쓰므로 GPIO18의 PWM과 충돌하지 않는다 |
| GPIO13 | 33 | 서보 신호 (하드웨어 PWM1) | [9장](09_pigpio_advanced.md) 실습 9-5(서보 파형은 AD2 DIO7로 관찰), [부록 B](appendix_b_gpio_libraries.md) `pwm1`(서보 대신 LED) | DIO7 | 서보 전원은 별도 5 V, GND 공통. `pwm1` 예제는 아래 "GPIO13 참고" |
| GPIO14 | 8 | UART TXD | [3장](03_rpi_hw_os.md) UART 콘솔, [7장](07_boot_kernel.md) 실습 7-1 부팅 로그, [10장](10_measurement.md) 실습 10-5, [12장](12_communication.md) 실습 12-1·12-2, [부록 B](appendix_b_gpio_libraries.md) `serialTest`, `serialTest2` | DIO8 | 시리얼 콘솔과 내 프로그램이 동시에 쓰지 않는다 |
| GPIO15 | 10 | UART RXD | GPIO14와 같다 | DIO9 | 5 V·RS-232 전압 금지 |
| GPIO16 | 36 | DS1302 I/O (양방향) | 12장 실습 12-6 | DIO6 | |
| GPIO17 | 11 | **LED0 (빨강)**: 책 전체의 기본 LED | [5장](05_sysadmin.md) `blink.service`, [6장](06_c_build.md) 실습 6-7, [8장](08_gpio_pigpio.md) 실습 8-1~8-6, [9장](09_pigpio_advanced.md) 실습 9-1·9-3·9-7(데이터 펄스)·9-8, [10장](10_measurement.md) 실습 10-1·10-2·10-8, [11장](11_process_concurrency.md) 실습 11-6~11-8, [12장](12_communication.md) 실습 12-2, [13장](13_ble_iot.md) 과제, [부록 A](appendix_a_matlab_simulink.md) 실습 A-2·A-4·A-5(빨강), [부록 B](appendix_b_gpio_libraries.md) `blink_thread`, `blink_thread2`, `semaphore_led`, `speed`, `pwm1`(DMA PWM 고정 밝기), `led_blink_gpiod`, LED 바 예제 | DIO0 | 실습 10-2(구동 세기·무부하 전압)는 LED0을 잠시 빼고 잰다(8.2.4절 규칙 2) |
| GPIO18 | 12 | 하드웨어 PWM0 출력 (330 Ω + LED 디밍 또는 수동 부저) | [8장](08_gpio_pigpio.md) `pigs p/pfs 18` 설명, [9장](09_pigpio_advanced.md) 실습 9-4, [10장](10_measurement.md) 실습 10-2·10-4, [12장](12_communication.md) 실습 12-5(`led` 옵션), [부록 B](appendix_b_gpio_libraries.md) `pwm1`, `softTone` | DIO1 | 오디오와 PWM 주변장치를 공유한다. GPIO12와 같은 채널(PWM0). 실습 10-2는 PWM용 LED·부저를 잠시 빼고 잰다 |
| GPIO19 | 35 | DS1302 SCLK | 12장 실습 12-6 | DIO5 | 하드웨어 PWM1 핀이지만 일반 출력으로만 쓰므로 GPIO13의 서보 PWM과 충돌하지 않는다 |
| GPIO20 | 38 | HC-SR04 TRIG | [9장](09_pigpio_advanced.md) 실습 9-6 | | **레벨 시프터 LV3 ↔ HV3** 경유 |
| GPIO21 | 40 | HC-SR04 ECHO | 9장 실습 9-6 | | **레벨 시프터 LV4 ↔ HV4** 경유. 시프터가 없을 때만 1 kΩ/2 kΩ 분압기 |
| GPIO22 | 15 | LED2 (초록) | [8장](08_gpio_pigpio.md) 실습 8-4, [11장](11_process_concurrency.md) 실습 11-6, [부록 A](appendix_a_matlab_simulink.md) 실습 A-5(초록), [부록 B](appendix_b_gpio_libraries.md) `semaphore_led`, LED 바 예제 | | ⚠ JTAG (예외 ③) |
| GPIO23 | 16 | LED3 | 8장 실습 8-4, 부록 B LED 바 예제 | | ⚠ JTAG (예외 ③). `i2c-gpio` 오버레이의 SoC 기본 SDA이지만 이 책은 그 오버레이를 쓰지 않는다 |
| GPIO24 | 18 | LED4 | 8장 실습 8-4, 부록 B LED 바 예제 | | ⚠ JTAG (예외 ③). `i2c-gpio`의 SoC 기본 SCL |
| GPIO25 | 22 | LED5 | 8장 실습 8-4, 부록 B LED 바 예제 | | ⚠ JTAG (예외 ③) |
| GPIO26 | 37 | **BTN0 (버튼)**: 내부 풀업, 누르면 0 (active-low) | [7장](07_boot_kernel.md) 7.12절 듀얼 부팅 선택 핀(`[gpio26=0]`), [8장](08_gpio_pigpio.md) 실습 8-3, [9장](09_pigpio_advanced.md) 실습 9-1·9-2·9-8, [10장](10_measurement.md) 실습 10-3(관찰)·10-8(AD2가 구동), [11장](11_process_concurrency.md) 실습 11-6·11-7, [12장](12_communication.md) 과제 12-2(`BTN?`), [부록 A](appendix_a_matlab_simulink.md) 실습 A-2·A-4·A-5(보행자 버튼), [부록 B](appendix_b_gpio_libraries.md) `pullupdown`, `isr`, `wiringPiISR`, `semaphore_led` | DIO2 | ⚠ DS3231 SQW (예외 ①), ⚠ JTAG (예외 ③). 실습 10-8에서 AD2가 구동할 때는 버튼 배선을 잠시 뺀다([8장](08_gpio_pigpio.md) 8.2.4절 규칙 2) |
| GPIO27 | 13 | LED1 (노랑) | 8장 실습 8-4, [9장](09_pigpio_advanced.md) 실습 9-7(웨이브폼 마커), [11장](11_process_concurrency.md) 실습 11-6, [부록 A](appendix_a_matlab_simulink.md) 실습 A-4(저장소 모델)·A-5(노랑), [부록 B](appendix_b_gpio_libraries.md) `blink_thread2`, `semaphore_led`, LED 바 예제 | DIO3 | ⚠ JTAG (예외 ③) |

**⚠ 핀 예외는 다음 세 가지뿐이다.** 본문에서는 "⚠ 핀 예외" 상자로 나온다. 실습이 끝나면 빼 둔 배선을 다시 꽂는다.

| 번호 | 예외 | 빼는 배선 | 대신 쓰는 핀 | 나오는 곳 |
|:-:|---|---|---|---|
| ① | DS3231 SQW 인터럽트 (선택) | BTN0 버튼 | SQW → GPIO26 (물리 핀 37) | [12장](12_communication.md) 실습 12-4 |
| ② | 로터리 엔코더 (선택) | LED6, LED7 | 엔코더 A/B → GPIO5/GPIO6 (물리 핀 29/31), 엔코더 `+`는 3.3 V | [9장](09_pigpio_advanced.md) 9.7절 |
| ③ | JTAG 디버깅 (심화, `enable_jtag_gpio=1`) | LED1~LED5, BTN0 (GPIO22~27) | JTAG 신호 | [7장](07_boot_kernel.md) 7.3.5절 |

> **GPIO13 참고 (예외가 아니라 데모 배선).** GPIO13의 표준 장치는 서보이다. [부록 B](appendix_b_gpio_libraries.md)의 `pwm1_pigpio.c`는 하드웨어 PWM1 채널 자체를 보여 주려고 GPIO13에 1 kHz PWM을 내므로, 실행 전에 **서보를 빼고 330 Ω + LED를 꽂는다**(B.4.13). 서보에 1 kHz를 넣으면 떨리거나 과열될 수 있다. 예제가 끝나면 서보를 다시 꽂는다.

**레벨 시프터 채널 규약.** 표준 부품은 4채널 양방향 BSS138 모듈 하나이다. 채널을 아래처럼 고정해 두었으므로 HC-SR04와 5 V LCD를 **동시에** 연결해 두어도 된다.

| 모듈 단자 | Pi 쪽 (LV) | 5 V 장치 쪽 (HV) | 쓰는 곳 |
|---|---|---|---|
| LV / HV (전원) | 3.3 V (물리 핀 1) → LV | 5 V (물리 핀 2) → HV | 항상 둘 다 연결 |
| GND (양쪽) | Pi GND | 장치 GND | 반드시 공통 |
| LV1 ↔ HV1 | GPIO2 SDA (물리 핀 3) | PCF8574 LCD SDA | [12장](12_communication.md) 실습 12-3 |
| LV2 ↔ HV2 | GPIO3 SCL (물리 핀 5) | PCF8574 LCD SCL | 12장 실습 12-3 |
| LV3 ↔ HV3 | GPIO20 (물리 핀 38) | HC-SR04 TRIG | [9장](09_pigpio_advanced.md) 실습 9-6 |
| LV4 ↔ HV4 | GPIO21 (물리 핀 40) | HC-SR04 ECHO | 9장 실습 9-6 |

AD2로 시프터를 거치는 신호를 잴 때는 Pi가 실제로 보는 **LV 쪽**을 잰다([10장](10_measurement.md) 10.5.4절). 3.3 V 장치(DS3231, BMP280, 3.3 V로 켠 MCP3008)는 시프터 없이 직결한다.

**Analog Discovery 2 표준 배선**([10장](10_measurement.md) 10.5.4절): DIO0 ↔ GPIO17 (LED0), DIO1 ↔ GPIO18 (PWM), DIO2 ↔ GPIO26 (BTN0), DIO3 ↔ GPIO27 (LED1, 9장 웨이브폼 마커), DIO4 / 5 / 6 ↔ GPIO12 / 19 / 16 (DS1302 CE / SCLK / I/O), DIO7 ↔ GPIO13 (서보), DIO8 / 9 ↔ UART TXD / RXD (GPIO14 / 15), DIO10~13 ↔ SPI CS / CLK / MOSI / MISO (GPIO8 / 11 / 10 / 9), DIO14 / 15 ↔ I2C SCL / SDA (GPIO3 / 2). **AD2 GND와 Pi GND의 공통 연결은 필수**이다.

### C.4.2 과거 자료와 달라진 점

강의 자료(「Raspberry Pi Codes」, Linux 백서, 슬라이드)와 2025년 수업 기록, 그리고 이 교재의 초안은 예제마다 핀을 따로 정했다. 그래서 같은 핀을 여러 부품이 나눠 쓰거나(예: SPI0 핀에 LED와 DS1302) 5 V 신호를 GPIO에 바로 넣는 배선이 있었다. 이 책은 그것을 위의 표준 핀 계획으로 옮겼다. 옛 자료나 원본 코드를 볼 때는 아래 표로 핀을 바꿔 읽는다. 바꾼 이유는 "자세히" 열의 절에 있다.

| 장치·예제 | 과거 자료의 핀 (출처) | 이 책의 표준 | 자세히 |
|---|---|---|---|
| DS1302 RTC | RST/DAT/CLK = GPIO10/9/11, SPI0과 겹침 (원본 코드). GPIO24/23/22 (교재 초안) | CE/SCLK/I/O = **GPIO12/19/16**, AD2 DIO4/5/6 | [12장](12_communication.md) 실습 12-6 |
| HC-SR04 초음파 센서 | ECHO 직결 (Linux 백서). TRIG/ECHO = GPIO23/24, ECHO만 1 kΩ/2 kΩ 분압 (교재 초안) | TRIG/ECHO = **GPIO20/21**, 레벨 시프터 LV3/LV4 (분압기는 시프터가 없을 때의 대안) | [9장](09_pigpio_advanced.md) 9.6.2절, 실습 9-6 |
| 듀얼 부팅 선택 핀 | GPIO18, `[gpio18=0]` (Linux 백서). GPIO2, `[gpio2=0]` (교재 초안) | **GPIO26 = BTN0**, `gpio=26=ip,pu` + `[gpio26=0]` | [7장](07_boot_kernel.md) 7.12.4절 |
| PCF8574 I2C LCD | 모듈 VCC 5 V, SDA·SCL을 GPIO2/3에 직결 (원본 자료, 2025년 수업) | 레벨 시프터 **LV1/LV2** 경유 (대안: 모듈을 3.3 V로 켜기) | [12장](12_communication.md) 12.4.4절, 실습 12-3 |
| LED 스윕·LED 8개 (`blink_sweep`, `blink8`, `softpwm`) | wPi 0~7 = GPIO17, 18, 27, 22, 23, 24, 25, 4 (원본 코드). GPIO18·4가 PWM·센서 자리와 겹침 | **LED 바** {17, 27, 22, 23, 24, 25, 5, 6} | [8장](08_gpio_pigpio.md) 실습 8-4, [부록 B](appendix_b_gpio_libraries.md) B.4.2 |
| LED 12개 (`blink12`) | wPi 0~7 + wPi 10~13 (GPIO8·7·10·9 = SPI0) (원본 코드) | LED 바 8개 (SPI0은 MCP3008 자리) | 부록 B B.4.3 |
| 세마포어 LED (`semaphore_led`) | LED GPIO17/18/27, 버튼 GPIO22를 3.3 V 쪽에 달고 풀다운(누르면 1) (원본 코드, 교재 초안의 부록 B) | LED0~LED2 = GPIO17/27/22, **BTN0 GPIO26** 풀업(누르면 0). 11장과 부록 B가 같은 배선 | [11장](11_process_concurrency.md) 실습 11-6, 부록 B B.4.6 |
| `blink_thread2`의 두 번째 LED | GPIO18 (원본 코드) | LED1 GPIO27 | 부록 B B.4.4 |
| 입력 예제 (`pullupdown`, `gpio_read`, `isr`) | GPIO17(또는 wPi 0~7 8개)을 풀다운 입력으로 (원본 코드) | **BTN0 GPIO26** 하나, 풀업 | [8장](08_gpio_pigpio.md) 실습 8-3, 부록 B B.4.7·B.4.10 |
| 하드웨어 PWM 예제 (`pwm1`) | GPIO12·18(같은 PWM0 채널)과 GPIO13에 LED (원본 코드) | GPIO18 (PWM0), GPIO13 (PWM1, 서보 대신 LED), 고정 밝기 LED는 LED0 GPIO17 (DMA PWM) | 부록 B B.4.13 |
| 피에조 부저 (`softTone`) | GPIO22 = wPi 3 (원본 코드) | **GPIO18** (하드웨어 PWM) | 부록 B B.4.15 |
| DHT11 데이터 | GPIO21 = wPi 29 (원본 코드) | **GPIO4** (RHT03와 같은 핀) | 부록 B B.4.16 |
| Python 원격 버튼 (`button_counter.py`) | GPIO21, 풀다운, 상승 에지 (Raspberry Pi Codes §7.4.3) | **BTN0 GPIO26**, 풀업, 하강 에지 (`remote_button.py`) | [9장](09_pigpio_advanced.md) 실습 9-8 |
| DMA PWM 셸 데모 (`pwm_demo.sh`) | GPIO18 (강의 슬라이드) | LED0 GPIO17 (`pwm_fade.sh`) | [9장](09_pigpio_advanced.md) 실습 9-3 |
| DS3231 SQW | GPIO27 (교재 초안) | GPIO26, ⚠ 예외 ① (BTN0을 빼고 연결) | 12장 실습 12-4 |
| AD2 DIO 배치 | GPIO17 ↔ DIO7, GPIO18 ↔ DIO6 (2025년 11주차), SCL ↔ DIO0, SDA ↔ DIO1 (13주차). DS1302 ↔ DIO3~5, 웨이브폼 마커 GPIO27 ↔ DIO1 (교재 초안) | 위의 AD2 표준 배선 (DIO0~DIO15 고정) | [10장](10_measurement.md) 10.5.4절 |

WiringPi 번호(wPi)와 BCM 번호의 대응은 [부록 B](appendix_b_gpio_libraries.md) B.2절의 표를 본다. 그 표는 번호 변환용 참고표이며, 변환한 BCM 번호를 그대로 배선하지 말고 위 표에 따라 역할별로 옮긴다.

---

## C.5 자주 나오는 오류 모음

각 장의 "트러블슈팅" 표를 한곳에 모아 분야별로 나누었다. 같은 오류가 여러 장에 나오면 한 줄로 합치고 "자세히"에 관련된 장을 모두 적었다. 오류 메시지는 화면에 나오는 문구 그대로이므로, 메시지의 일부를 Ctrl+F로 찾으면 된다.

> **오류를 만났을 때의 순서.** ① 메시지를 끝까지 읽는다(보통 첫 오류 줄이 원인이다). ② 이 절에서 문구로 찾는다. ③ "자세히"의 장으로 가서 원리를 확인한다. ④ 하드웨어 문제라면 [10장](10_measurement.md)의 순서대로 **전원 → 배선 → 신호 → 코드**를 확인한다.

C.5.1에는 1·2장의 CPU·메모리 확인 실습 오류를, C.5.3에는 7장의 커널 빌드·모듈 오류를 따로 모았다.

### C.5.1 시스템 정보·CPU·어셈블리 확인

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| Mermaid 그림이 표시되지 않는다 | 편집기가 Mermaid를 지원하지 않거나, 괄호·`/`가 들어간 이름을 따옴표 없이 썼다 | GitHub, VS Code 확장 등 Mermaid를 지원하는 편집기에서 본다. 괄호나 `/`가 들어간 이름은 `A["이름 (설명)"]`처럼 큰따옴표로 감싼다 | [1장](01_embedded_system.md) |
| `/proc/device-tree/…: No such file or directory` (`cat …/model`, `od …/soc/ranges`) | x86 PC나 WSL에는 디바이스 트리가 없다(정상) | PC에서는 `lscpu`를 쓰고, 디바이스 트리 관련 명령은 Raspberry Pi에서 실행한다 | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md) |
| `lscpu`의 Model name이 비어 있거나 `-`로 나온다 | 커널·`util-linux` 버전에 따라 ARM 코어 이름을 표시하지 못할 수 있다 | `cat /proc/cpuinfo`의 `CPU part` 값(Cortex-A72는 `0xd08`)으로 확인한다 | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md) |
| Raspberry Pi인데 `uname -a`가 `armv7l`로 나온다 | 32비트 Raspberry Pi OS를 설치했다. 32비트 OS에서는 `long`·포인터 크기가 4로 나오고 어셈블리가 A32/Thumb-2로 나온다 | 이 교재는 64비트(`aarch64`) Raspberry Pi OS를 기준으로 한다. 64비트 OS를 다시 설치한다([3장](03_rpi_hw_os.md)) | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md) |
| Windows에서 `cat`, `uname`이 동작하지 않는다 | PowerShell에는 `uname`이 없다 | WSL을 설치하거나 [1장](01_embedded_system.md) 실습 1-1의 `Get-CimInstance` 명령을 사용한다 | [1장](01_embedded_system.md) |
| `lscpu`에 `Caches` 항목이 없다 / `cache_info.sh`가 "… 가 없습니다. 이 커널은 캐시 정보를 sysfs로 알려 주지 않습니다."를 출력한다 | 커널이 캐시 정보를 디바이스 트리나 하드웨어 레지스터에서 얻지 못했다. 오래된 커널이나 일부 가상 환경에서 생긴다 | `sudo apt update && sudo apt full-upgrade`로 커널을 갱신하거나, [2장](02_computer_arch_arm.md) 2.2.3절의 표(데이터시트 값)를 참고한다 | [2장](02_computer_arch_arm.md) |
| `getconf LEVEL1_DCACHE_LINESIZE`가 `0`이나 빈 값을 출력한다 | C 라이브러리 버전에 따라 AArch64에서 이 값을 구하지 못할 수 있다 | `cat /sys/devices/system/cpu/cpu0/cache/index0/coherency_line_size`로 직접 읽는다(64가 나와야 한다) | [2장](02_computer_arch_arm.md) |
| PC(WSL)에서 `make asm`을 했더니 `movl`, `%eax` 같은 낯선 명령어가 나온다 | 정상이다. PC의 `gcc`는 x86-64 명령어를 만든다(**ISA가 다르다**) | ARM 어셈블리는 Raspberry Pi에서 만들거나 `aarch64-linux-gnu-gcc` 교차 컴파일러로 만든다 | [2장](02_computer_arch_arm.md) |
| Raspberry Pi에서 `gcc -marm`을 하면 `error: unrecognized command-line option '-marm'` | 64비트 OS의 기본 `gcc`는 AArch64 전용이다. `-marm`, `-mthumb`는 32비트 ARM 컴파일러의 옵션이다 | `gcc-arm-linux-gnueabihf`를 설치해 `arm-linux-gnueabihf-gcc`로 실행한다([2장](02_computer_arch_arm.md) 실습 2-3의 선택 단계) | [2장](02_computer_arch_arm.md) |
| `asm_demo.s`에 `.cfi_startproc` 같은 줄이 가득하다 | Makefile을 쓰지 않고 `gcc -S`만 실행했다. `.cfi` 지시어는 예외 처리·디버깅용 정보이다 | `make asm`(또는 `-fno-asynchronous-unwind-tables -fno-unwind-tables` 옵션)으로 다시 만든다 | [2장](02_computer_arch_arm.md) |
| 교재와 어셈블리가 다르다(명령어 순서, 레지스터 번호, 라벨 이름) | 컴파일러 버전과 최적화 옵션이 다르면 결과가 달라진다. `-O0`이면 모든 변수를 스택에 저장하는 긴 코드가, `-O2` 이상이면 반복문이 바뀐 코드가 나온다 | `gcc --version`과 옵션(`-O1`)을 확인한다. 의미가 같으면 정상이다 | [2장](02_computer_arch_arm.md) |
| `add_ten_plus_one`에 `bl add`가 없다 | `add`가 인라인되었다 | `asm_demo.c`의 `__attribute__((noinline))`이 지워지지 않았는지 확인한다 | [2장](02_computer_arch_arm.md) |
| `make dis`의 `bl` 대상이 `0 <add>`로 나온다 | 링크 전의 목적 파일(.o)이라 주소가 비어 있는 것이 정상이다 | 링크된 실행 파일은 `objdump -d asm_demo \| less`로 `<add_ten_plus_one>:`을 찾아 본다 | [2장](02_computer_arch_arm.md) |
| `make enc32`에서 `arm-linux-gnueabihf-as: not found` | 32비트 교차 binutils가 없다 | `sudo apt install binutils-arm-linux-gnueabihf` 후 다시 실행한다 | [2장](02_computer_arch_arm.md) |
| `/proc/iomem`의 주소가 모두 `00000000-00000000` | 일반 사용자로 실행했다 | `sudo cat /proc/iomem`으로 실행한다 | [2장](02_computer_arch_arm.md) |
| `/proc/iomem`에서 `gpio`를 찾을 수 없다 | `sudo`를 빠뜨렸거나, 커널이 다른 이름(예: `gpio@7e200000` 대신 `pinctrl`)으로 등록했다 | `sudo grep -i 7e200000 /proc/iomem`처럼 레거시 주소로 찾는다 | [2장](02_computer_arch_arm.md) |

### C.5.2 부팅·접속

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| Imager에서 쓰기(Writing) 중 오류, 또는 Verifying 실패 | 이전 파티션 문제, 카드 불량, 카드 리더 접촉 불량 | [3장](03_rpi_hw_os.md) 3.6.5절대로 SD 카드 파티션 삭제(또는 Imager의 Erase) 후 재시도. 다른 카드 리더·카드로 시험 | [3장](03_rpi_hw_os.md) |
| SD 카드를 꽂자 Windows가 "포맷해야 합니다"라고 묻는다 | Windows가 ext4(`rootfs`)를 읽지 못해서 묻는 것 | **취소**한다. 포맷하면 OS가 지워진다 | [3장](03_rpi_hw_os.md) |
| 탐색기에 `bootfs`만 보이고 리눅스 파일이 없다 | 정상. Windows는 FAT32 부트 파티션만 읽는다 | 루트 파일 시스템은 Pi 안에서 본다 | [3장](03_rpi_hw_os.md) |
| 전원을 넣어도 LED가 전혀 안 켜진다 | 전원 어댑터·케이블 불량, 전원이 공급되지 않음 | 다른 5 V 3 A 어댑터·케이블로 시험 | [3장](03_rpi_hw_os.md) |
| 빨간 LED만 켜지고 초록 LED가 전혀 깜빡이지 않는다 | SD 카드를 읽지 못함(카드 미삽입·불량·OS 미기록) | 카드를 다시 꽂고, 다른 카드에 다시 기록해 시험 | [3장](03_rpi_hw_os.md) |
| 초록 LED가 일정한 패턴으로 반복해 깜빡이고 부팅되지 않는다 | 부트로더가 알려 주는 **오류 코드**. 예: 긴 깜빡임 0번 + 짧은 깜빡임 4번 = `start*.elf`를 찾지 못함, 0 + 7 = 커널 이미지를 찾지 못함 | 패턴(긴 횟수, 짧은 횟수)을 세어 공식 표와 대조한다. 대부분 SD 카드에 다시 기록하면 해결된다. 📌 [LED warning flash codes](https://www.raspberrypi.com/documentation/computers/configuration.html#led-warning-flash-codes) | [3장](03_rpi_hw_os.md) |
| 모니터에 무지개 화면만 보이고 더 진행되지 않는다 | 펌웨어 단계에서 멈춤(커널을 못 읽음, `config.txt` 오류), 전원 부족 | `config.txt`를 백업본으로 되돌린다. UART 콘솔의 `MESS:` 메시지로 어디서 멈췄는지 본다. 전원 확인 | [3장](03_rpi_hw_os.md) |
| PuTTY를 열었는데 아무것도 안 나온다 | ① Pi 전원이 아직 꺼져 있음(정상) ② 이미 부팅이 끝남 | ① PuTTY를 연 상태에서 전원을 넣는다 ② Enter를 한 번 누른다 | [3장](03_rpi_hw_os.md) |
| 부팅 메시지가 전혀 나오지 않는다 | ① **TX/RX를 엇갈리지 않고 같은 것끼리 연결** ② `enable_uart=1` 누락 또는 다른 파일에 저장 ③ GND 미연결 ④ COM 번호 틀림(프로그래머 보드는 포트가 2개) ⑤ 다른 핀(물리 번호 착각)에 연결 | ① 어댑터 RXD ↔ 핀 8, 어댑터 TXD ↔ 핀 10 ② `bootfs`의 `config.txt` 맨 끝 확인 ③ 핀 6 확인 ④ 장치 관리자에서 확인, TTL 시리얼 쪽 포트 사용 ⑤ 오른쪽 열 3·4·5번째 | [3장](03_rpi_hw_os.md) |
| UART 글자가 깨져서 나온다(`�x�`, 이상한 기호) | ① **보율 불일치**(PuTTY ≠ 115200) 또는 8N1 형식 불일치 ② GND 미연결·접촉 불량 ③ mini UART 사용 중 코어 클록 변화(`disable-bt` 미적용) | ① 양쪽 보율·형식을 같게(콘솔은 `cmdline.txt`의 115200) ② GND 확인 ③ `dtoverlay=disable-bt` 철자 확인, `ls -l /dev/serial0`이 `ttyAMA0`인지 확인 | [3장](03_rpi_hw_os.md), [12장](12_communication.md) |
| 출력은 보이는데 키보드 입력이 안 된다 | 어댑터 TXD → Pi RXD(핀 10) 선이 빠짐, PuTTY Flow control이 XON/XOFF | 핀 10 배선 확인, Flow control을 None으로 | [3장](03_rpi_hw_os.md) |
| 부팅 중간에 같은 메시지가 반복되며 계속 재부팅된다 | 전원 부족(저전압), 첫 부팅의 정상 재부팅(1회) | 1회는 정상. 반복되면 5 V 3 A 어댑터로 교체 | [3장](03_rpi_hw_os.md) |
| 로그인이 안 된다(`Login incorrect`) | Imager에서 사용자를 만들지 않음, 사용자 이름 오타, 키보드 배열 차이로 특수문자 오입력 | Imager로 다시 기록하며 사용자 지정을 확인. 암호는 화면에 안 보이는 것이 정상 | [3장](03_rpi_hw_os.md) |
| `pi` / `raspberry`로 로그인이 안 된다 | 2022년 4월부터 기본 사용자 `pi`가 없다 | Imager에서 만든 사용자로 로그인 | [3장](03_rpi_hw_os.md) |
| 데스크톱에 번개 아이콘, `vcgencmd get_throttled`가 0이 아님, 로그에 `Undervoltage detected!` | 전원 어댑터·케이블 용량 부족, PC USB 포트로 전원 공급 | 5 V 3 A 어댑터와 짧고 굵은 케이블 사용. [3장](03_rpi_hw_os.md) 3.5.3절의 비트 표로 해석 | [3장](03_rpi_hw_os.md) |
| `hostname -I`에 아무것도 안 나온다 | 랜 케이블 미연결, 인터페이스 꺼짐, DHCP 서버 없음 | `ip link`로 `eth0` 상태 확인, `sudo ip link set eth0 up`, 케이블·스위치 확인 | [3장](03_rpi_hw_os.md) |
| `ifconfig: command not found` | 최신 OS에 net-tools 미설치 | `ip addr` 사용 | [3장](03_rpi_hw_os.md) |
| `ssh: connect to host … port 22: Connection refused` | Pi의 SSH 서버가 꺼져 있음 | UART 콘솔에서 `sudo systemctl enable --now ssh` 또는 `raspi-config` → Interface Options → SSH | [3장](03_rpi_hw_os.md) |
| `ssh: connect to host … Connection timed out` | IP가 틀렸거나 바뀜, 다른 네트워크, 방화벽 | UART 콘솔에서 `hostname -I`로 다시 확인, PC에서 `ping` | [3장](03_rpi_hw_os.md) |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` | OS를 새로 기록했거나, 같은 IP를 다른 Pi가 받음 | 내 Pi가 맞는지 확인한 뒤 PC에서 `ssh-keygen -R <IP>` 후 재접속 | [3장](03_rpi_hw_os.md), [6장](06_c_build.md) |
| `pi-07.local`로 접속이 안 된다 | mDNS가 그 네트워크·PC에서 동작하지 않음, 호스트 이름 중복 | IP로 접속. 호스트 이름이 서로 다른지 확인 | [3장](03_rpi_hw_os.md) |
| 고정 IP 설정 후 SSH가 끊기고 다시 안 된다 | SSH 세션에서 `nmcli … down` 실행, 주소·게이트웨이 오타, IP 충돌 | UART 콘솔에서 `nmcli connection show`로 확인 후 수정하거나 DHCP로 되돌림 | [3장](03_rpi_hw_os.md) |
| `/etc/dhcpcd.conf`를 고쳤는데 고정 IP가 적용되지 않는다 | Bookworm은 dhcpcd가 아니라 NetworkManager 사용 | `nmcli`로 설정([3장](03_rpi_hw_os.md) 3.10.4절) | [3장](03_rpi_hw_os.md) |
| 원격 데스크톱(xrdp) 접속 직후 검은 화면 또는 끊김 | 같은 사용자가 로컬 데스크톱에 로그인 중, Wayland 관련 | `sudo systemctl set-default multi-user.target` 후 재부팅. 그래도 안 되면 `raspi-config` → Advanced → Wayland에서 X11 선택 | [3장](03_rpi_hw_os.md) |
| `cmdline.txt`를 고친 뒤 부팅이 안 된다 | 줄바꿈이 들어감, `root=` 손상, 첫 부팅 항목 삭제 | PC에서 `cmdline.txt.bak`으로 되돌린다 | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md) |
| 빨간 LED만 켜지고 초록 LED가 전혀 깜빡이지 않는다 | 부트로더가 SD 카드를 읽지 못함(카드 없음, 잘못 기록, 접촉 불량) 또는 EEPROM 문제 | SD 카드 다시 꽂기, Imager로 다시 쓰기. 그래도 안 되면 Imager의 *Bootloader → SD Card Boot* 복구 이미지([7장](07_boot_kernel.md) 7.4.5절) | [7장](07_boot_kernel.md) |
| 초록 LED가 규칙적으로 짧게 7번 깜빡인다 | **커널 이미지를 찾지 못함.** `kernel=` 이름 오타, 파일을 복사하지 않음 | PC에서 `config.txt`의 `kernel=` 줄과 `bootfs`의 파일 이름 비교. [7장](07_boot_kernel.md) 7.4.6절의 표에서 다른 패턴도 찾는다 | [7장](07_boot_kernel.md) |
| HDMI에 무지개 화면만 나오고 멈춘다 | 펌웨어(③)는 동작했지만 커널로 넘어가지 못함: 커널 파일 손상, 32/64비트 불일치(`arm_64bit`와 커널 종류), 전원 부족 | UART의 펌웨어 로그(`uart_2ndstage=1`)에서 어디서 멈췄는지 확인. 방금 바꾼 `kernel=`·`arm_64bit` 줄을 PC에서 되돌린다. 3 A 전원 확인 | [7장](07_boot_kernel.md) |
| HDMI는 까만데 UART에는 부팅 메시지가 나온다 | 정상일 수 있다. 화면 설정 문제(`console=tty1` 삭제, 디스플레이 오버레이)이거나 커널이 화면 드라이버를 못 올림 | UART로 로그인해 `sudo dmesg \| grep -i -E "vc4\|drm\|hdmi"` 확인. `cmdline.txt`의 `console=tty1`, `config.txt`의 `dtoverlay=vc4-kms-v3d` 확인 | [7장](07_boot_kernel.md) |
| UART에 아무것도 안 나온다 | `enable_uart=1` 누락, `console=serial0,115200` 누락, 배선(TX↔RX), 속도 불일치 | 강의의 원칙: **`config.txt`의 UART와 `cmdline.txt`의 console 둘 다** 확인. [3장](03_rpi_hw_os.md) 트러블슈팅 참고 | [7장](07_boot_kernel.md) |
| `Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)` | **루트 파티션을 못 찾음.** `root=` 값이 틀림(다른 카드의 PARTUUID를 복사), `rootfstype` 틀림, 루트 장치 드라이버가 모듈인데 initramfs가 없음 | PC에서 `cmdline.txt`의 `root=PARTUUID=…`를 원래 값으로(백업에서) 되돌린다. Pi에서 `lsblk -o NAME,PARTUUID`로 올바른 값 확인 | [7장](07_boot_kernel.md) |
| `Waiting for root device PARTUUID=…`에서 멈춤 | `rootwait` 때문에 패닉 대신 **무한히 기다리는 중**. 원인은 위와 같다(없는 PARTUUID) | 위와 같음. USB로 부팅하는데 SD 카드의 PARTUUID를 적은 경우도 많다 | [7장](07_boot_kernel.md) |
| 부팅은 되는데 Wi-Fi·I²C 등 일부 장치가 없다 / 이상하다 | **DTB가 커널과 맞지 않음**(다른 버전의 `.dtb`로 덮어씀), 오버레이 철자 오류 | 기본 DTB를 덮어쓰지 않는다([7장](07_boot_kernel.md) 7.10.4절). `sudo vclog --msg`로 오버레이 적용 기록, `dtc -I fs`로 실제 결과 확인. 버전이 크게 다른 커널은 `os_prefix`로 DTB까지 분리 | [7장](07_boot_kernel.md) |
| `config.txt`에 넣은 설정이 적용되지 않는다 | 철자 오류(오류 없이 무시됨), 앞쪽 필터(`[cm4]` 등) 아래에 넣음, 재부팅 안 함 | `[all]` 아래 파일 끝에 다시 쓴다. `vcgencmd get_config <이름>`으로 적용 값 확인 | [7장](07_boot_kernel.md) |
| `sudo reboot 0 tryboot`이 시험 부팅을 하지 않는다 | 인자를 따옴표로 묶지 않음 | `sudo reboot '0 tryboot'` (인자는 하나여야 한다) | [7장](07_boot_kernel.md) |
| `systemd-analyze`가 `Bootup is not yet finished` | 아직 기본 target에 도달하지 않았다(대기 중인 서비스) | 잠시 후 다시 실행. `systemctl list-jobs`로 무엇을 기다리는지 확인 | [7장](07_boot_kernel.md) |
| `dtc: command not found` | 패키지 미설치 | `sudo apt install device-tree-compiler` | [7장](07_boot_kernel.md) |

### C.5.3 커널 빌드·모듈

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| 커널 교체 후 `modprobe: FATAL: Module … not found in directory /lib/modules/<버전>` | **모듈 불일치.** 새 커널의 모듈 폴더(`/lib/modules/$(uname -r)`)가 없거나 이름이 다름 | `uname -r`과 `ls /lib/modules/` 비교. 설치 스크립트를 다시 실행하거나 모듈 묶음을 `/lib/modules`에 풀고 `sudo depmod -a <릴리스>` | [7장](07_boot_kernel.md) |
| WSL에서 커널 빌드가 매우 느리거나 이상한 오류(파일 없음, 권한) | **`/mnt/c` 아래에서 작업** (느린 접근, 대소문자 구분 없음, 권한 표현 문제) | `cd ~`로 리눅스 홈에서 다시 클론·빌드. `pwd`로 확인 | [7장](07_boot_kernel.md) |
| `/bin/sh: 1: bc: not found`, `flex: not found`, `bison: not found`, `openssl/opensslv.h: No such file` | 빌드 의존 패키지 누락 | `sudo apt install git bc bison flex libssl-dev make libc6-dev libncurses-dev kmod crossbuild-essential-arm64` | [7장](07_boot_kernel.md) |
| `E: Unable to locate package libncurses5-dev` | Ubuntu 24.04에는 그 패키지가 없다 | `libncurses-dev`로 바꿔 설치 ([7장](07_boot_kernel.md) 7.10.2절) | [7장](07_boot_kernel.md) |
| `aarch64-linux-gnu-gcc: not found` | 교차 컴파일러 미설치, 또는 `CROSS_COMPILE` 철자 오류(끝의 `-` 누락) | `sudo apt install crossbuild-essential-arm64`, `CROSS_COMPILE=aarch64-linux-gnu-` 확인 | [7장](07_boot_kernel.md) |
| 빌드 중 `Killed`, `gcc: fatal error: Killed signal terminated program cc1` | WSL 메모리 부족 | `JOBS=4 bash build_kernel.sh`처럼 동시 작업 수를 줄이거나, `Image`, `modules`, `dtbs`를 나누어 빌드 | [7장](07_boot_kernel.md) |
| 모듈 빌드 중 `ERROR: modpost: … undefined!` 또는 `Module.symvers is missing` | `KDIR`의 커널 소스가 아직 빌드되지 않음, 커널 쪽에 없는 함수를 사용 | `KDIR` 커널을 먼저 빌드하거나 Pi에서 `linux-headers-rpi-v8`로 빌드. 쓴 함수가 `EXPORT_SYMBOL`된 함수인지 확인 | [7장](07_boot_kernel.md) |
| `make: *** /lib/modules/<버전>/build: No such file or directory` | 커널 헤더 미설치, 또는 `apt full-upgrade` 뒤 아직 재부팅하지 않아 실행 중인 커널과 헤더 버전이 다름 | `sudo apt install linux-headers-rpi-v8` 후 재부팅. `uname -r`과 `ls /lib/modules/` 비교 | [7장](07_boot_kernel.md) |
| `insmod: ERROR: could not insert module hello.ko: Invalid module format` | **모듈과 커널의 버전(`vermagic`)이 다름.** 다른 커널의 헤더로 빌드 | `modinfo hello.ko \| grep vermagic`과 `uname -r` 비교. 지금 커널의 헤더로 다시 빌드 | [7장](07_boot_kernel.md) |
| `scp: /boot/firmware/…: Permission denied` | 일반 사용자는 부트 파티션에 쓸 수 없다 | 홈(`~/mykernel`)에 먼저 복사하고 Pi에서 `sudo`로 옮긴다([7장](07_boot_kernel.md) 7.10.4절) | [7장](07_boot_kernel.md) |

### C.5.4 셸·파일·스크립트

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `bash: ./script.sh: Permission denied` | 실행 권한(x)이 없다 | `chmod +x script.sh` (또는 `bash script.sh`). **`chmod 777`은 쓰지 않는다** | [4장](04_linux_shell.md) |
| `cat: 파일: Permission denied`, `cd: 디렉터리: Permission denied` | 파일의 `r`이 없거나, 경로상 디렉터리의 `x`가 없다. root 소유 파일이다 | `ls -l`, `ls -ld 디렉터리`로 확인. 시스템 파일이면 `sudo` | [4장](04_linux_shell.md) |
| `sudo echo 1 > /sys/...`가 `Permission denied` | 리다이렉션은 sudo 밖의 셸이 처리한다 | `echo 1 \| sudo tee /sys/...` | [4장](04_linux_shell.md), [8장](08_gpio_pigpio.md) |
| `bash: hello.sh: command not found`, `prog: command not found` (파일은 있다) | 현재 디렉터리는 `PATH`에 없다 | `./hello.sh`. 자주 쓰면 `~/bin`에 넣고 `PATH`에 추가([4장](04_linux_shell.md) 4.16.4절) | [4장](04_linux_shell.md), [6장](06_c_build.md) |
| `bash: 명령: command not found` | ① 오타·대소문자 ② 설치되지 않은 프로그램 ③ `PATH`를 망가뜨렸다 | ① 확인 ② `apt`로 설치([5장](05_sysadmin.md)) ③ `echo $PATH` 확인, 터미널을 새로 열거나 `export PATH=/usr/local/bin:/usr/bin:/bin`로 임시 복구 후 `.bashrc` 수정 | [4장](04_linux_shell.md) |
| `bash: ./x.sh: cannot execute: required file not found`, `/bin/bash^M: bad interpreter`, `$'pwd\r': command not found` | **Windows에서 편집한 파일의 줄 끝이 CRLF**(`\r\n`)여서 셔뱅이 `/bin/bash\r`로 읽힌다(`bash x.sh`로 실행하면 줄마다 `\r`이 붙어 오류). 첫 줄(`#!`)의 인터프리터 경로가 틀려도 같은 메시지가 난다. bash 5.2(Bookworm)는 첫 메시지, 이전 버전은 둘째 메시지를 낸다 | `file x.sh`에 `with CRLF line terminators`가 보이면 `sed -i 's/\r$//' x.sh`로 고친다(`cat -A`로 보면 줄 끝에 `^M$`. `dos2unix`는 기본 설치가 아니다). VS Code 오른쪽 아래의 `CRLF`를 `LF`로 바꾸어 저장. 저장소의 `.gitattributes`(`*.sh eol=lf`)를 지킨다. 셔뱅 경로도 확인 | [4장](04_linux_shell.md), [6장](06_c_build.md) |
| `sh script.sh`에서 `[[: not found`, `Syntax error: "(" unexpected` | `sh`는 dash이다. bash 전용 문법(`[[ ]]`, 배열)을 모른다 | `bash script.sh` 또는 셔뱅 `#!/bin/bash` + `./script.sh` | [4장](04_linux_shell.md) |
| 공백이 든 파일 이름에서 `No such file or directory`가 두 번 | 공백에서 인자가 나뉘었다 | `"my file.txt"` 또는 `my\ file.txt`, 스크립트에서는 `"$변수"`. Tab 자동 완성 사용 | [4장](04_linux_shell.md) |
| `rm -rf $DIR/*`가 엉뚱한 것을 지웠다 | `$DIR`이 비어 있으면 `rm -rf /*`가 된다. `cd 디렉터리; rm -rf *`에서 `cd`가 실패하면 현재 디렉터리가 지워진다 | **`rm -rf`는 휴지통이 없다.** 실행 전 `pwd`, `ls`, `echo rm -rf "$DIR"/*`로 확인. `cd 디렉터리 && rm ...`처럼 `&&`로 잇고, 변수는 `"${DIR:?}"`(비었으면 중단)로 쓴다. `sudo rm -rf`는 두 번 확인 | [4장](04_linux_shell.md) |
| `name = value` 줄에서 `name: command not found` | 대입문의 `=` 양옆에 공백 | `name=value` | [4장](04_linux_shell.md) |
| `[: missing ']'` 또는 `[3: command not found` | `[ ]` 안쪽 공백 누락 | `[ "$a" -gt 3 ]`처럼 공백 | [4장](04_linux_shell.md) |
| `if [ $a > 3 ]` 뒤에 `3`이라는 빈 파일이 생겼다 | `>`가 리다이렉션으로 해석됐다 | 숫자는 `-gt`, `-lt` 사용 | [4장](04_linux_shell.md) |
| `syntax error: unexpected end of file` | `fi`, `done`, 따옴표, 괄호의 짝이 맞지 않는다 | `bash -n`으로 검사하고 짝 확인 | [4장](04_linux_shell.md) |
| 스크립트에서 alias가 동작하지 않는다 | 스크립트는 `.bashrc`를 읽지 않고, 비대화형 셸은 alias를 펼치지 않는다 | 함수로 바꾼다 | [4장](04_linux_shell.md) |
| `.bashrc`에 넣은 설정이 적용되지 않는다 | 아직 다시 읽지 않았다 | `source ~/.bashrc` 또는 터미널 새로 열기 | [4장](04_linux_shell.md) |
| `ls *.xyz`가 `cannot access '*.xyz'` | 맞는 파일이 없어 패턴이 그대로 넘어갔다 | 이름 확인. `find . -name "*.xyz"`로 하위 디렉터리까지 찾기 | [4장](04_linux_shell.md) |
| `grep .c`가 `.c` 파일만 고르지 못한다 | 정규식의 `.`은 아무 글자 하나 | `grep '\.c$'` | [4장](04_linux_shell.md) |
| `uniq -c`가 같은 값을 여러 줄로 센다 | `uniq`는 이웃한 줄만 합친다 | 앞에 `sort` | [4장](04_linux_shell.md) |
| `>`로 저장했더니 이전 내용이 사라졌다 | `>`는 덮어쓴다 | 덧붙이기는 `>>`. 예방은 `set -o noclobber` | [4장](04_linux_shell.md) |
| 오류 메시지가 파일에 저장되지 않는다 | `>`는 표준 출력만 보낸다 | `> 파일 2>&1` 또는 `&> 파일` (순서 주의) | [4장](04_linux_shell.md) |
| vi에서 글자가 입력되지 않거나 빠져나올 수 없다 | 명령 모드이다 | 입력은 `i`. 나가기는 Esc 두세 번 → `:q!` Enter. 초보자는 nano | [4장](04_linux_shell.md) |
| 화면이 멈추고 아무 키도 듣지 않는다 | Ctrl+S(출력 멈춤)를 눌렀다 | Ctrl+Q | [4장](04_linux_shell.md) |
| `man cd`가 `No manual entry for cd` | `cd`는 bash 내장 명령 | `help cd` | [4장](04_linux_shell.md) |
| `locate: command not found` | 기본 설치가 아니다 | `find` 사용, 또는 `sudo apt install plocate` | [4장](04_linux_shell.md) |
| Ctrl+Z 뒤에 프로그램이 "사라졌는데" LED가 켜져 있다 | Ctrl+Z는 종료가 아니라 일시 정지 | `fg`로 되살려 Ctrl+C로 종료([5장](05_sysadmin.md)) | [4장](04_linux_shell.md) |
| WSL에서 `chmod`가 효과가 없고 모든 파일이 `rwxrwxrwx` | Windows 드라이브(`/mnt/c`, `/mnt/d`) 위에서 작업했다 | WSL의 리눅스 홈(`~`)에 복사해서 실습 | [4장](04_linux_shell.md) |

### C.5.5 패키지·사용자·서비스·디스크

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `sudo apt update`가 `Could not resolve …` 오류 | 네트워크 미연결, DNS 설정 오류 | `ping 8.8.8.8`, `ping google.com`으로 구분. 고정 IP라면 `ipv4.dns` 확인 | [3장](03_rpi_hw_os.md) |
| `apt update` 시 `Permission denied`, lock 오류 | `sudo` 누락 | `sudo apt update` | [3장](03_rpi_hw_os.md) |
| 파일 날짜·시각이 이상하다 | 네트워크가 없어 시간 동기화가 안 됨(Pi 4에는 배터리 시계가 없다) | 네트워크 연결 후 `timedatectl`로 확인 | [3장](03_rpi_hw_os.md) |
| `E: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 1234 (apt)` | 다른 `apt`가 돌고 있다. 부팅 직후에는 자동 갱신(`apt-daily` 타이머, 데스크톱의 업데이트 알림)이 돌기도 한다 | 기다린다. `ps -p 1234 -o pid,etime,cmd`로 확인. **잠금 파일을 지우지 않는다.** 그 프로세스가 정말 멈춰 있을 때만 `sudo kill 1234` 후 `sudo dpkg --configure -a` | [5장](05_sysadmin.md) |
| `apt update` 없이 `E: Unable to locate package xxx` | 카탈로그가 없거나 오래됐다, 또는 이름 오타 | `sudo apt update` 후 다시. `apt search xxx`로 정확한 이름 확인 | [5장](05_sysadmin.md) |
| `apt install` 중 `404 Not Found` | 카탈로그가 오래되어 서버에서 지워진 옛 버전을 찾는다 | `sudo apt update` 후 다시 | [5장](05_sysadmin.md) |
| `E: Unmet dependencies. Try 'apt --fix-broken install'` | 의존성이 깨진 채 설치가 멈췄다(`dpkg -i`로 설치했을 때 흔함) | `sudo apt --fix-broken install` | [5장](05_sysadmin.md) |
| `dpkg was interrupted, you must manually run 'sudo dpkg --configure -a'` | 업그레이드 중 전원이 꺼지거나 Ctrl+C | 메시지대로 `sudo dpkg --configure -a`, 이어서 `sudo apt --fix-broken install` | [5장](05_sysadmin.md) |
| `Release file ... is not valid yet` | Pi의 시계가 틀렸다(RTC 없음, NTP 미동기화) | 네트워크 연결 후 `timedatectl`의 `synchronized: yes`를 기다린다([5장](05_sysadmin.md) 5.12절) | [5장](05_sysadmin.md) |
| `error: externally-managed-environment` | Bookworm에서 시스템 Python에 `pip install` | `sudo apt install python3-패키지` 또는 venv([5장](05_sysadmin.md) 5.3.8절). `--break-system-packages`는 쓰지 않는다 | [5장](05_sysadmin.md), [13장](13_ble_iot.md) |
| `sudo: unable to resolve host 이름` | `hostname`을 바꾸고 `/etc/hosts`를 안 고쳤다 | `/etc/hosts`의 `127.0.1.1` 줄을 새 이름으로([5장](05_sysadmin.md) 5.11.1절) | [5장](05_sysadmin.md) |
| `xxx is not in the sudoers file` | 그 사용자가 `sudo` 그룹에 없다 | 관리자 계정으로 `sudo usermod -aG sudo xxx` | [5장](05_sysadmin.md) |
| `usermod -G`를 하고 나서 sudo가 안 된다 | `-a` 없이 `-G`를 써서 다른 그룹에서 모두 빠졌다 | 다른 관리자 계정이 있으면 그것으로 `-aG`로 되돌린다. 없으면 SD 카드를 다른 Linux에 꽂아 `/etc/group`을 고친다 | [5장](05_sysadmin.md) |
| `/dev/gpiomem`, `/dev/i2c-1`, `/dev/ttyAMA0` `Permission denied` | 그 장치의 그룹(`gpio`, `i2c`, `dialout`)에 없다, 또는 그룹에 넣고 **다시 로그인하지 않았다** | `id -nG`로 확인 → `sudo usermod -aG gpio $USER` → 다시 로그인([5장](05_sysadmin.md) 5.2.5절). pigpio 방식 A는 그룹과 무관하게 `sudo` 필요 | [5장](05_sysadmin.md) |
| 새 사용자에게서 `vcgencmd` 오류 | `video` 그룹이 아니다 | `sudo usermod -aG video 사용자` | [5장](05_sysadmin.md) |
| `deluser`가 `user ... is currently used by process` | 그 사용자의 프로세스가 남아 있다 | `sudo pkill -u 사용자` 후 다시 | [5장](05_sysadmin.md) |
| `kill: (1234) - Operation not permitted` | 남의(또는 root의) 프로세스 | 내 프로세스인지 확인. 서비스라면 `sudo systemctl stop` | [5장](05_sysadmin.md) |
| `kill`해도 안 죽는다 | 프로그램이 SIGTERM을 무시하거나, STAT이 `D`(I/O 대기) | 몇 초 기다린 뒤 `kill -9`. `D`라면 장치·SD 카드 문제를 `dmesg`로 확인 | [5장](05_sysadmin.md) |
| `kill`했는데 금방 다시 살아난다 | systemd 서비스의 `Restart=`가 다시 띄운다 | `sudo systemctl stop 이름`. 부팅 자동 실행도 막으려면 `disable` | [5장](05_sysadmin.md) |
| 로그아웃하면 백그라운드 프로그램이 죽는다 | 셸이 SIGHUP을 보냈다 | `nohup`, 또는 서비스로([5장](05_sysadmin.md) 5.5절) | [5장](05_sysadmin.md) |
| 서비스가 `failed`, `Active: failed (Result: exit-code)` | 프로그램이 오류로 끝났다 | `journalctl -u 이름 -n 30 --no-pager`로 프로그램이 남긴 마지막 메시지 확인. 먼저 같은 명령을 셸에서 직접 실행해 본다 | [5장](05_sysadmin.md) |
| `status=203/EXEC` | `ExecStart`의 파일이 없거나, 실행 권한이 없거나, **셔뱅이 없거나 CRLF**이다 | 절대 경로 확인, `sudo chmod 755`, `head -1`과 `file`로 셔뱅·CRLF 확인([4장](04_linux_shell.md) 트러블슈팅) | [5장](05_sysadmin.md) |
| `status=217/USER` | `User=`에 적은 사용자가 없다 | 사용자 이름 확인 또는 `DynamicUser=yes` | [5장](05_sysadmin.md) |
| 유닛 파일을 고쳤는데 그대로다, `Warning: The unit file … changed on disk` | `daemon-reload`를 안 했다 | `sudo systemctl daemon-reload` 후 `restart` | [5장](05_sysadmin.md) |
| `is marked executable. Please remove executable permission bits` | 유닛 파일에 x 권한 | `sudo chmod 644 /etc/systemd/system/이름.service` | [5장](05_sysadmin.md) |
| 재부팅 후 서비스가 안 떠 있다 | `start`만 하고 `enable`을 안 했다 | `sudo systemctl enable 이름` | [5장](05_sysadmin.md) |
| 서비스의 `printf` 출력이 journal에 안 보인다 | 출력이 파이프라 블록 버퍼링된다 | `ExecStart=/usr/bin/stdbuf -oL …`, 또는 코드에서 `fflush(stdout)`·`setvbuf`([5장](05_sysadmin.md) 5.5.8절) | [5장](05_sysadmin.md) |
| `journalctl -b -1`이 `Specifying boot ID … has no effect` 또는 빈 결과 | journal이 메모리에만 저장된다 | `ls /var/log/journal` 확인. raspi-config `A12 Logging`([5장](05_sysadmin.md) 5.6.4절) | [5장](05_sysadmin.md) |
| cron 작업이 안 도는 것 같다 | PATH, `%`, 출력 버려짐 | 절대 경로, `\%`, `>> 로그 2>&1`, `journalctl -u cron` 확인([5장](05_sysadmin.md) 5.7.2절) | [5장](05_sysadmin.md) |
| `No space left on device` | 디스크(또는 inode)가 꽉 찼다 | `df -h`, `df -i`, `du`로 범인 찾기, `apt clean`, `journalctl --vacuum-size`([5장](05_sysadmin.md) 5.8.8절) | [5장](05_sysadmin.md) |
| `umount: target is busy` | 내 셸이 그 안에 있거나 열린 파일이 있다 | `cd ~` 후 다시. `sudo lsof /mnt/usb`, `sudo fuser -vm /mnt/usb` | [5장](05_sysadmin.md) |
| USB가 `lsblk`에 보이는데 파일이 안 보인다 | 마운트하지 않았다(Lite판) | `sudo mount /dev/sda1 /mnt/usb` | [5장](05_sysadmin.md) |
| FAT32 USB에 `File too large` | FAT32는 파일 하나 4 GiB 미만 | exFAT이나 ext4로 포맷한 장치에 저장, 또는 `gzip`·`split` | [5장](05_sysadmin.md) |
| fstab을 고친 뒤 부팅이 멈추거나 응급 모드 | 오타, 없는 UUID, `nofail` 없음 | [5장](05_sysadmin.md) 5.8.7절: `cmdline.txt`에 `init=/bin/sh` → `mount -o remount,rw /` → fstab 복구. 또는 다른 Linux에서 고치기 | [5장](05_sysadmin.md) |
| `dd`가 끝났는데 카드가 부팅되지 않는다 | `of=`가 파티션(`/dev/sdb1`)이었다, 또는 중간에 뺐다 | `of=`는 **장치 전체**(`/dev/sdb`). `conv=fsync` 후 `sync`, 끝까지 기다리기. Imager의 "사용자 정의 이미지"를 쓰면 실수가 적다 | [5장](05_sysadmin.md) |
| 프로그램이 `Killed` 한 마디만 남기고 사라졌다 | OOM killer(메모리 부족) | `sudo dmesg \| grep -i oom`. 스왑 늘리기, `make -j2`([5장](05_sysadmin.md) 5.9.3절) | [5장](05_sysadmin.md) |
| 같은 코드가 갑자기 느려졌다 | 온도·저전압 스로틀링 | `vcgencmd measure_temp`, `get_throttled`([5장](05_sysadmin.md) 5.10.1절, [3장](03_rpi_hw_os.md) 3.5.3절) | [5장](05_sysadmin.md) |
| `ps -a`에 서비스가 안 보인다 | `-a`는 터미널이 있는 프로세스만 | `ps -e`, `ps aux` | [5장](05_sysadmin.md) |
| `dpkg -S /usr/bin/ls`가 `no path found` | Bookworm의 `/bin` → `/usr/bin` 링크(merged /usr) | `dpkg -S /bin/ls` 또는 `dpkg -S '*/bin/ls'`([5장](05_sysadmin.md) 5.3.7절) | [5장](05_sysadmin.md) |

### C.5.6 빌드·링크·디버깅·개발 도구

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `Makefile:N: *** missing separator.  Stop.` | 레시피 줄이 **탭이 아니라 공백**으로 시작한다 | 그 줄의 들여쓰기를 탭으로. `cat -A Makefile`에서 `^I`인지 확인. VS Code는 상태 표시줄에서 `Indent Using Tabs` | [6장](06_c_build.md), [7장](07_boot_kernel.md) |
| `make: Nothing to be done for 'all'.` | 모든 대상이 최신이다(오류 아님) | 정말 다시 빌드하려면 `make clean && make` 또는 `make -B` | [6장](06_c_build.md) |
| 소스를 고쳤는데 결과가 그대로 | ① 저장하지 않았다 ② 다시 빌드하지 않았다 ③ 다른 위치의 옛 실행 파일을 실행했다(`./prog`가 아니라 `prog`로 `/usr/local/bin`의 것을 실행) ④ 헤더 의존성이 Makefile에 없다 | ① Auto Save ② `make` 출력 확인 ③ `which prog`, 항상 `./prog` ④ `-MMD -MP` | [6장](06_c_build.md) |
| `fatal error: xxx.h: No such file or directory` | 헤더 파일이 없거나 검색 경로 밖에 있다 | `-dev` 패키지 설치(`sudo apt install libpigpio-dev`), `-I`, 이름·대소문자 확인 | [6장](06_c_build.md) |
| `warning: implicit declaration of function` | 선언(헤더) 누락. gcc 14부터는 오류 | 맞는 헤더 포함. `man 3 함수명`으로 확인 | [6장](06_c_build.md) |
| `undefined reference to 'xxx'` | 라이브러리·목적 파일을 링크하지 않았다 / 라이브러리가 소스보다 앞에 있다 / `static` 함수를 다른 파일에서 불렀다 / 이름 오타 | `-lm`, `-lpigpio`, `-lpigpiod_if2` 등을 **소스 뒤에** 추가. 빠진 `.c`를 Makefile에 추가 | [6장](06_c_build.md) |
| `cannot find -lxxx: No such file or directory` | 라이브러리 파일(`libxxx.so`/`.a`)이 없다 | `-dev` 패키지 설치, `-L경로`, 이름 확인(`-lpigpiod_if2`, `-lwiringPi` 대소문자) | [6장](06_c_build.md) |
| `multiple definition of 'xxx'` | 같은 전역 변수·함수를 두 파일에서 정의. 헤더에 변수 정의를 넣었다. gcc 10부터 `-fno-common` 기본 | 정의는 한 `.c`에만, 헤더에는 `extern` 선언 | [6장](06_c_build.md) |
| `error while loading shared libraries: libxxx.so…: cannot open shared object file` | 실행 시 동적 로더가 `.so`를 못 찾는다 | 표준 위치에 설치 후 `sudo ldconfig`, 또는 `LD_LIBRARY_PATH=경로`, 또는 `-Wl,-rpath` | [6장](06_c_build.md) |
| `-O2`에서는 빌드되는데 `-O0`에서 `undefined reference to 'sin'` | 상수 접기로 `-O2`에서 함수 호출이 사라졌다 | 수학 함수를 쓰면 항상 `-lm` | [6장](06_c_build.md) |
| `./prog: Permission denied` | ① 실행 권한(x)이 없다 ② 파일이 `noexec`로 마운트된 곳(예: FAT 형식 USB 메모리, 일부 `/tmp`)에 있다 | ① `chmod +x prog`(gcc가 만든 파일은 보통 이미 있다) ② `mount \| grep 경로`로 `noexec` 확인, 홈 디렉터리로 복사해 실행 | [6장](06_c_build.md) |
| `bash: ./prog: cannot execute binary file: Exec format error` | 다른 CPU용 실행 파일(PC에서 만든 x86-64 파일을 Pi에서 실행) | `file prog`로 `ARM aarch64`인지 확인. Pi에서 다시 빌드 | [6장](06_c_build.md) |
| CRLF Makefile에서 이상한 오류 | Windows에서 편집해 줄 끝이 CRLF가 되었다. GNU make 4.3은 대부분 처리하지만 레시피가 부르는 스크립트·다른 도구는 실패할 수 있다 | `file Makefile`로 확인 후 LF로 변환. VS Code 상태 표시줄의 `CRLF`를 눌러 `LF`로 | [6장](06_c_build.md) |
| gdb에서 `No symbol "i" in current context.` | 그 변수가 지금 위치의 범위(scope) 밖이다(예: `for` 안에서 선언한 `i`를 루프 밖에서) | 변수가 보이는 줄까지 진행한 뒤 확인 | [6장](06_c_build.md) |
| gdb에서 소스 줄이 안 보이고 `<optimized out>` | `-g` 없이 빌드했거나 최적화(`-O2`)를 켰다 | `-g -O0`으로 다시 빌드 | [6장](06_c_build.md) |
| gdb로 실행한 pigpio 프로그램이 `initCheckPermitted` 권한 오류 | `-lpigpio` 프로그램을 일반 사용자 gdb로 실행 | [6장](06_c_build.md) 6.11.6절: ① `pigpiod_if2`로 디버깅 ② `sudo-gdb.sh` ③ `sudo gdb ./prog` | [6장](06_c_build.md) |
| 디버깅 중 Stop 후 다음 실행에서 `Can't lock /var/run/pigpio.pid` | `gpioTerminate()` 없이 강제 종료되었다 | `ps aux \| grep led_blink`로 남은 프로세스 확인 후 `sudo kill`, 필요하면 `sudo rm -f /var/run/pigpio.pid` | [6장](06_c_build.md) |
| VS Code `Could not establish connection to …` | ① Pi IP가 바뀌었다 ② SSH가 꺼져 있다 ③ 네트워크가 다르다 | PowerShell에서 `ssh 사용자@IP`로 먼저 확인, Pi에서 `sudo systemctl status ssh`, `ip addr` | [6장](06_c_build.md) |
| VS Code가 매번 비밀번호를 묻는다 / 키 인증이 안 된다 | 공개 키 미등록, `~/.ssh` 권한이 너무 넓다 | [6장](06_c_build.md) 6.11.2절대로 키 등록, Pi에서 `chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys` | [6장](06_c_build.md) |
| 원격 서버 설치가 멈추거나 반복 재연결 | Pi 저장 공간 부족, 불안정한 네트워크, 깨진 `~/.vscode-server` | `df -h`, 유선 연결, Pi에서 `rm -rf ~/.vscode-server` 후 재접속 | [6장](06_c_build.md) |
| IntelliSense에 빨간 밑줄(`#include errors detected`)이 있는데 빌드는 된다 | C/C++ 확장이 PC 쪽에만 설치되었거나 헤더 경로를 모른다 | 확장을 **SSH 쪽**에 설치. `C/C++: Edit Configurations`에서 컴파일러 경로 `/usr/bin/gcc` | [6장](06_c_build.md) |
| `preLaunchTask 'xxx' 을(를) 찾을 수 없습니다` | `launch.json`의 `preLaunchTask`와 `tasks.json`의 `label`이 다르다 | 글자 하나까지 같게 | [6장](06_c_build.md) |
| `.vscode` 설정이 적용되지 않는다 | `code/ch06`이 아니라 상위 폴더를 열었다 | `code/ch06`을 작업 폴더로 연다 | [6장](06_c_build.md) |
| `git push` 거부(`Permission denied`, 인증 실패) | 쓰기 권한이 없는 저장소이거나 GitHub 비밀번호 인증을 시도했다 | 자기 저장소·fork에 push, 개인 액세스 토큰 또는 SSH 키 사용 | [6장](06_c_build.md) |
| `undefined reference to 'sin'` 또는 `'pow'` | 수학 라이브러리(`libm`)를 링크하지 않았다 | 링크 명령 끝에 `-lm`(Makefile의 `LDLIBS = -lm`)을 붙인다. `-O0`에서만 이 오류가 나고 `-O2`에서는 빌드되는 것도 같은 원인이다([6장](06_c_build.md) 6.4절) | [9장](09_pigpio_advanced.md), [부록 A](appendix_a_matlab_simulink.md) |

### C.5.7 GPIO·pigpio

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| Ctrl+Z 뒤 LED가 켜진 채, 다시 실행하면 `Can't lock /var/run/pigpio.pid` | 프로그램이 멈춘 채 살아 있다 | `jobs` → `fg` → Ctrl+C. 이미 셸을 닫았으면 `pgrep -a 이름` → `kill` | [5장](05_sysadmin.md) |
| `initInitialise: Can't lock /var/run/pigpio.pid` (또는 `gpioInitialise` 실패) | pigpiod 데몬이나 다른 pigpio 프로그램(이전에 실행한 프로그램 포함)이 이미 하드웨어를 잡고 있다. `enable`해 둔 pigpiod, `blink.service`의 `Requires=`로 켜진 pigpiod도 원인이 된다 | `sudo systemctl stop pigpiod`(부팅 자동 실행이면 `sudo systemctl disable --now pigpiod`). 서비스가 아니면 `ps aux \| grep pigpio`로 찾아 `sudo kill <PID>` 또는 `sudo killall pigpiod`. [9장](09_pigpio_advanced.md)의 `pwm_fade.sh`·Python 실습 뒤에 데몬을 끄는 것을 잊기 쉽다 | [5장](05_sysadmin.md), [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md), [10장](10_measurement.md), [11장](11_process_concurrency.md), [12장](12_communication.md), [부록 B](appendix_b_gpio_libraries.md) |
| `Sorry, you don't have permission to run this program. Try running as root` | `-lpigpio` 프로그램을 sudo 없이 실행 | `sudo ./프로그램` | [8장](08_gpio_pigpio.md) |
| `pigs …` 또는 Python이 `socket connect failed` / `pi.connected` 거짓 | pigpiod가 꺼져 있다. 원격 접속이면 상대 데몬이 로컬 접속만 받는 기본 설정(`-l`)으로 실행 중 | `sudo systemctl start pigpiod`. 원격은 [8장](08_gpio_pigpio.md) 8.6절대로 데몬이 원격 접속을 허용하게 한다 | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md) |
| `pigpio_start` 실패: `failed to connect to pigpiod` | 데몬이 꺼져 있음. 원격이면 상대 데몬이 `-l`(기본 서비스)로 실행 중이거나 주소가 틀림 | 데몬 실행, [8장](08_gpio_pigpio.md) 8.6절대로 원격 허용, IP 확인 | [8장](08_gpio_pigpio.md) |
| `undefined reference to 'gpioInitialise'` | `-lpigpio` 누락 | 링크 옵션 추가 (라이브러리는 소스 파일 **뒤에**) | [8장](08_gpio_pigpio.md) |
| `undefined reference to 'pigpio_start'` | `-lpigpiod_if2` 누락 또는 `-lpigpio`와 혼동 | 클라이언트 프로그램은 `-lpigpiod_if2` | [8장](08_gpio_pigpio.md) |
| `fatal error: pigpio.h: No such file or directory` | 개발 패키지 미설치 | `sudo apt install pigpio` (또는 `libpigpio-dev`) | [8장](08_gpio_pigpio.md) |
| `implicit declaration of function 'gpioSetPullUpDn'` | 함수 이름 오타(원본 자료의 오류) | `gpioSetPullUpDown` | [8장](08_gpio_pigpio.md) |
| LED가 전혀 안 켜진다 | ① LED 방향 반대 ② 다른 핀에 꽂음(물리 번호와 BCM 혼동) ③ GND 미연결 ④ 저항값이 너무 큼, 파랑·흰색 LED | ① 긴 다리를 저항 쪽으로 ② `pinout`, `pinctrl -p`로 대조, `pigs w 17 1` 후 `pinctrl get 17` ③ GND 확인 ④ 330 Ω, 빨간 LED로 시험 | [8장](08_gpio_pigpio.md) |
| 코드는 GPIO17인데 다른 LED가 움직인다 | 물리 핀 17(3.3 V)이나 GPIO11(물리 23)과 혼동 | 이 교재 표기 `GPIO17 (물리 핀 11)` 확인 | [8장](08_gpio_pigpio.md) |
| 버튼 값이 제멋대로 바뀐다 | 플로팅 입력 | 풀업/풀다운 설정(`gpioSetPullUpDown`, `pigs pud 26 u`) | [8장](08_gpio_pigpio.md) |
| 버튼을 눌러도 계속 1(또는 0) | 버튼 다리 선택 오류(항상 연결된 쌍), 풀 방향과 배선 불일치, GND 미연결 | 대각선 다리 사용, 풀업이면 버튼 반대편은 GND | [8장](08_gpio_pigpio.md) |
| 눌림이 반대로 동작 | active-low를 고려하지 않음 | 풀업이면 눌림 = 0. LED는 `!level`로 | [8장](08_gpio_pigpio.md) |
| 버튼을 한 번 눌렀는데 여러 번 인식(콜백이 여러 번 온다) | 채터링(스위치 접점이 짧은 시간 여러 번 붙었다 떨어짐) | 폴링이면 간격을 조정한다. 콜백이면 `gpioGlitchFilter(g, 5000)` 또는 tick 비교 디바운스(실습 9-2) | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md), [부록 B](appendix_b_gpio_libraries.md) |
| Ctrl+C 후 LED가 켜진 채 남는다 | 시그널 처리 없이 종료 | `gpioSetSignalFunc(SIGINT, …)`로 플래그 처리 후 정리 | [8장](08_gpio_pigpio.md) |
| 버튼 예제 실행 중 CPU 사용률 100% | 지연 없는 바쁜 루프(busy loop) | `gpioDelay()`로 폴링 간격 확보 | [8장](08_gpio_pigpio.md) |
| `echo 17 > /sys/class/gpio/export`가 `Invalid argument` | 최신 커널의 sysfs 번호 오프셋 | `cat /sys/class/gpio/gpiochip*/base` 확인. sysfs 대신 libgpiod·pinctrl 사용 | [8장](08_gpio_pigpio.md) |
| `gpioset … Device or resource busy` (MATLAB GPIO 블록 포함) | 다른 프로세스(libgpiod 프로그램, 이전 모델 실행 파일)나 커널 드라이버가 그 줄을 요청 중이다 | `gpioinfo`로 소유자(consumer)를 확인하고 그 프로그램을 종료한다 | [8장](08_gpio_pigpio.md), [부록 A](appendix_a_matlab_simulink.md), [부록 B](appendix_b_gpio_libraries.md) |
| Pi 5에서 `this system does not appear to be a raspberry pi` | pigpio는 Pi 5 미지원 | [부록 B](appendix_b_gpio_libraries.md)의 libgpiod 사용 | [8장](08_gpio_pigpio.md) |
| 5 V 센서를 연결한 뒤 핀이 동작하지 않는다 | 3.3 V 핀에 5 V 입력(손상 가능) | 레벨 시프터·분압기 사용. 해당 핀은 다른 핀과 비교 시험 | [8장](08_gpio_pigpio.md) |
| 콜백이 전혀 불리지 않는다 | ① 등록 전에 `gpioInitialise()` 실패 ② 다른 핀 번호(물리 번호와 혼동) ③ 풀업이 없어 레벨이 변하지 않음 ④ main이 바로 끝나 프로그램이 종료됨 ⑤ glitch 필터 값이 너무 큼 | ① 반환값 확인 ② `pinctrl get 26`과 버튼을 함께 보며 레벨이 바뀌는지 확인 ③ `gpioSetPullUpDown(26, PI_PUD_UP)` ④ main에 대기 루프 ⑤ 필터 0으로 시험 | [9장](09_pigpio_advanced.md) |
| `gpioSetISRFunc`가 −123(`PI_BAD_ISR_INIT`)을 돌려준다 | pigpio v79가 sysfs에 BCM 번호를 그대로 써서 최신 커널(번호 오프셋)에서 export 실패 | `gpioSetAlertFunc` 계열을 쓴다. 커널 경로가 필요하면 libgpiod(`gpiomon`) | [9장](09_pigpio_advanced.md), [10장](10_measurement.md), [부록 B](appendix_b_gpio_libraries.md) |
| 디바운스 후 빠르게 누른 입력이 사라진다 | 필터·잠금 시간이 너무 길다 | 실습 9-2에서 잰 채터링 시간의 몇 배(5~20 ms)로 줄인다 | [9장](09_pigpio_advanced.md) |
| 콜백에서 카운트는 맞는데 main 출력이 가끔 이상하다 | 공유 변수가 일반 변수, 또는 "깃발 먼저, 값 나중" 순서 | `atomic_*` 사용, 값을 다 쓴 뒤 깃발. [11장](11_process_concurrency.md) | [9장](09_pigpio_advanced.md) |
| 다른 핀의 콜백까지 느려진다 | 콜백 안에서 `printf` 반복, `sleep`, 긴 계산 | 콜백은 기록만 하고 처리는 main으로 | [9장](09_pigpio_advanced.md) |
| `pigs pfs 17 1200` 후 주파수가 1000 | DMA PWM은 18개 허용 주파수 중 가장 가까운 값만 쓴다 | `gpioGetPWMfrequency()`/`pigs pfg`로 실제 값 확인. 정확한 주파수는 하드웨어 PWM | [9장](09_pigpio_advanced.md) |
| PWM 밝기 단계가 거칠다(높은 주파수에서) | 실제 범위 = 주기 / 5 μs. 8000 Hz면 25단계 | 주파수를 낮추거나(200 Hz → 1000단계) 하드웨어 PWM | [9장](09_pigpio_advanced.md) |
| `pigs p 18 20000`이 `ERROR: dutycycle not 0-range (default 255)` | `p`는 듀티(기본 0~255). 원본 자료의 오류 | 주파수는 `pfs`. 듀티 범위는 `prs`로 바꾼다 | [9장](09_pigpio_advanced.md) |
| `gpioHardwarePWM`이 −95(`PI_NOT_HPWM_GPIO`) | GPIO12/13/18/19가 아닌 핀 | 핀을 바꾸거나 `gpioPWM` 사용 | [9장](09_pigpio_advanced.md), [부록 B](appendix_b_gpio_libraries.md) |
| GPIO12와 GPIO18이 같이 변한다 | GPIO12와 GPIO18(또는 13과 19)이 같은 PWM 채널을 공유한다 | 서로 다른 채널(예: 18과 13)을 쓰거나, 한쪽은 `gpioPWM`(DMA PWM)으로 만든다 | [9장](09_pigpio_advanced.md), [부록 B](appendix_b_gpio_libraries.md) |
| 하드웨어 PWM이 갑자기 꺼진다 / 소리가 깨진다 | 웨이브폼 송신이 하드웨어 PWM을 끔 / PWM 주변장치를 오디오와 공유 | 웨이브폼과 동시에 쓰지 않는다. 실습 중 아날로그 오디오 재생 금지 | [9장](09_pigpio_advanced.md) |
| `gpioHardwarePWM`이 −100(`PI_HPWM_ILLEGAL`) | pigpio 박자 주변장치를 PWM으로 바꿈(`gpioCfgClock`, `pigpiod -t 0`) | 기본값(PCM)으로 둔다 | [9장](09_pigpio_advanced.md) |
| 서보가 떨린다(지터) | 전원 부족·전압 출렁임, GND 미연결, 긴 신호선 | 별도 5 V 전원, GND 공통, 전원 커패시터, `gpioServo`(DMA) 사용 | [9장](09_pigpio_advanced.md) |
| 서보가 움직일 때 Pi가 재부팅·화면에 번개 아이콘 | Pi 5 V에서 서보 전류를 끌어 씀(브라운아웃) | 별도 전원. `vcgencmd get_throttled` 확인 | [9장](09_pigpio_advanced.md) |
| 서보가 끝에서 "지-" 소리를 내며 뜨거워진다 | 기계적 한계를 넘는 펄스 폭 | MIN/MAX를 줄인다. 1500 μs는 항상 안전 | [9장](09_pigpio_advanced.md) |
| HC-SR04가 항상 "시간 초과" | ① 레벨 시프터의 LV(3.3 V)나 HV(5 V) 전원이 빠짐 ② ECHO/TRIG 핀 또는 채널(LV3/LV4)을 바꿔 꽂음 ③ VCC가 3.3 V(5 V 모듈) ④ GND 미연결 ⑤ (분압기 대안) 저항 위치가 바뀌어 High가 2 V 미만 | ① LV = 3.3 V, HV = 5 V 확인 ② GPIO20 = TRIG(LV3→HV3), GPIO21 = ECHO(HV4→LV4) ③ 5 V 연결 ④ GND 공통 ⑤ 1 kΩ이 ECHO 쪽, 2 kΩ이 GND 쪽 | [9장](09_pigpio_advanced.md) |
| 시프터를 단 뒤 Pi 쪽 핀에서 5 V 가까이 측정된다 | LV와 HV 전원을 바꿔 꽂음 | 즉시 전원을 끄고 모듈 글자(LV/HV)를 확인해 다시 꽂는다. 해당 GPIO는 다른 핀과 비교 시험 | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md) |
| HC-SR04 값이 가끔 크게 튄다 | 비스듬한 면, 흡수성 표면, 측정 간격이 짧아 이전 잔향 수신 | 측정 간격 ≥ 60 ms, 여러 번 재서 중앙값 사용 | [9장](09_pigpio_advanced.md) |
| `gpioWaveCreate`가 음수 | 펄스나 DMA 제어 블록이 너무 많음, 이전 웨이브폼을 지우지 않음 | `gpioWaveClear()` 후 다시 만들기, 펄스 수 줄이기 | [9장](09_pigpio_advanced.md) |
| `fatal error: wiringPi.h: No such file or directory` | WiringPi 미설치(기본 설치되어 있지 않다. Raspberry Pi 저장소에는 옛 2.x armhf 패키지만 있다) | 원본을 꼭 돌려야 하면 WiringPi 3.x `.deb` 설치. 아니면 `*_pigpio.c` 사용 | [부록 B](appendix_b_gpio_libraries.md) |
| 옮긴 프로그램에서 엉뚱한 LED가 켜진다 | wPi 번호를 BCM으로 바꾸지 않음(`gpioWrite(0, 1)` 등) | [부록 B](appendix_b_gpio_libraries.md) B.2 표로 변환. wPi 0 = GPIO17 | [부록 B](appendix_b_gpio_libraries.md) |
| `pigs pud 17 u`로 isr 시험을 하려는데 `socket connect failed` | pigs는 pigpiod가 필요하다 | 시험 중에는 `pinctrl set 17 pu`/`pd` 사용 | [부록 B](appendix_b_gpio_libraries.md) |
| `softTone_dma`의 음계가 이상하다 | DMA PWM 주파수는 18단계로 반올림 | 하드웨어 PWM 판 사용 | [부록 B](appendix_b_gpio_libraries.md) |
| DHT/RHT03에서 계속 `Data not good` | 풀업 없음, 5 V/3.3 V 혼동, 너무 자주 읽음, 긴 배선 | 4.7~10 kΩ 풀업, 3.3 V 구동, 1~2초 간격, `pulses=` 출력으로 펄스 수 확인 | [부록 B](appendix_b_gpio_libraries.md) |
| semaphore 예제에서 Ctrl+C 후 바로 끝나지 않는다 | 점등 중인 스레드가 LED를 끄고 반납할 때까지 기다림(최대 약 0.1초 × 대기열) | 정상 동작. 5초 뒤에는 강제로 정리한다 | [부록 B](appendix_b_gpio_libraries.md) |

### C.5.8 프로세스·스레드

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `undefined reference to 'pthread_create'` (또는 `sem_init`, `sem_wait`) | 스레드 라이브러리를 링크하지 않았다. glibc 2.34 이전 시스템(예: Raspberry Pi OS Bullseye)에서 생긴다. Bookworm(glibc 2.36)은 이 함수들이 `libc.so.6`에 들어 있어 빠뜨려도 링크되지만 이식성을 위해 붙인다 | 컴파일과 링크 모두에 **`-pthread`** 를 붙인다(`-lpthread`보다 권장). 교재 Makefile은 이미 붙였다 | [11장](11_process_concurrency.md) |
| 스레드가 엉뚱한 번호·핀을 받는다, 가끔만 틀린다 | 반복문 변수나 지역 변수의 **주소**를 스레드 인자로 넘겼다 | 스레드별 구조체, `malloc`, 또는 `(void *)(intptr_t)값`으로 넘긴다([11장](11_process_concurrency.md) 11.7.3절, 실습 11-3) | [11장](11_process_concurrency.md) |
| 스레드에서 `Segmentation fault` | ① 이미 반환한 함수의 지역 변수를 가리키는 포인터 사용 ② 스레드 스택에 큰 지역 배열 ③ `gpioTerminate()` 뒤에 GPIO 함수 호출 | ① 인자 수명 확인 ② 큰 버퍼는 전역/힙으로, 또는 `pthread_attr_setstacksize()` ③ [11장](11_process_concurrency.md) 11.11.5절의 정리 순서 | [11장](11_process_concurrency.md) |
| 프로그램이 멈췄다(CPU 0%, Ctrl+C도 안 먹을 때가 있음) | **교착 상태**: 두 mutex를 반대 순서로 잡았거나, 잠금을 쥔 채 `return`/`break`로 빠져나와 unlock을 안 했다 | `ps -L -o tid,stat,wchan:20 -p PID`로 스레드들이 `futex`에서 잠들었는지 확인. gdb로 붙어 `thread apply all bt`를 하면 각 스레드가 어느 `pthread_mutex_lock` 줄에서 기다리는지 보인다([11장](11_process_concurrency.md) 트러블슈팅의 gdb 예). 잠금 순서를 통일하고, 함수의 모든 출구에서 unlock | [11장](11_process_concurrency.md) |
| 카운터가 맞지 않는다, `volatile`을 붙였는데도 | `volatile`은 동기화가 아니다([11장](11_process_concurrency.md) 11.8.5절) | `atomic_int` + `atomic_fetch_add()`, 또는 mutex. `-fsanitize=thread`로 확인 | [11장](11_process_concurrency.md) |
| `ps`에 `<defunct>`(Z)가 계속 늘어난다 | 부모가 끝난 자식을 `wait`하지 않는다 | `waitpid()`로 거둔다. 자식을 계속 만드는 데몬은 `SIGCHLD` 처리기에서 `waitpid(-1, &st, WNOHANG)`를 반복. 좀비는 `kill -9`로 안 지워진다 | [11장](11_process_concurrency.md) |
| 같은 줄이 두 번 출력되거나 자식 출력이 사라진다 | `fork()` 때 stdio 버퍼가 복제되었거나, 자식이 `_exit()`로 버퍼를 비우지 않고 끝났다 | `fork()` 앞과 `_exit()` 앞에서 `fflush(stdout)` | [11장](11_process_concurrency.md) |
| 세마포어 대기 스레드가 영원히 깨어나지 않는다 | `sem_wait()`한 경로 중 하나에서 `sem_post()`를 빠뜨렸다(예: 오류로 일찍 `return`), 또는 초기값을 0으로 줬다 | 획득과 반납을 같은 함수 안에서 짝으로. 오류 경로에도 `sem_post()`. 초기값 확인. 종료할 때 기다리는 스레드를 깨울 방법(`sem_post`, `running` 플래그)을 마련 | [11장](11_process_concurrency.md) |
| Ctrl+C 뒤 `Segmentation fault` 또는 LED가 켜진 채 남음 | 내 스레드나 콜백이 아직 GPIO를 쓰는 중에 `gpioTerminate()`가 실행되었다 | 플래그 내림 → 콜백 해제 → 스레드 join/종료 확인 → LED 끄기 → `gpioTerminate()` 순서([11장](11_process_concurrency.md) 11.11.5절) | [11장](11_process_concurrency.md) |
| Ctrl+C를 눌러도 종료되지 않는다 | 종료 플래그를 보는 스레드가 `sem_wait()`, `pthread_cond_wait()`, `read()`에서 영원히 잠들어 있다 | 시간 제한 대기(`pthread_cond_timedwait`, `sem_timedwait`)로 주기적으로 플래그 확인, 또는 종료 시 `sem_post`/`cond_broadcast`로 깨운다. 시그널 처리기 안에서 mutex·cond 함수를 부르지 않는다 | [11장](11_process_concurrency.md) |
| 콜백 안에서 `printf`했더니 버튼 반응이 늦고 이벤트가 몰려서 온다 | 콜백(알림 스레드)이 오래 걸려 다른 이벤트 전달이 밀렸다 | 콜백은 큐에 넣기만, 출력은 main에서(실습 11-7) | [11장](11_process_concurrency.md) |
| 타이머 콜백 주기가 조금씩 밀린다 | `gpioSetTimerFunc`는 "잠자기 → 콜백"의 상대 시간 반복이다 | 절대 시간 `clock_nanosleep(TIMER_ABSTIME)` 스레드([11장](11_process_concurrency.md) 11.12절) | [11장](11_process_concurrency.md) |
| `chrt: failed to set pid … policy: Operation not permitted` | 실시간 정책은 root 권한이 필요하다 | `sudo chrt …` | [11장](11_process_concurrency.md) |

### C.5.9 통신(UART·I2C·SPI)

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `serOpen` 실패 `PI_SER_OPEN_FAILED`(−72) | UART가 꺼져 있다(`/dev/serial0` 없음), 시리얼 콘솔이 사용 중, 권한 | `ls -l /dev/serial0`, `enable_uart=1` 확인, login shell 끄기([12장](12_communication.md) 12.5.5절). pigpio 프로그램은 `sudo` | [12장](12_communication.md), [부록 B](appendix_b_gpio_libraries.md) |
| `serOpen` 실패 `PI_BAD_SER_SPEED`(−80) | 9600, 115200 같은 표준 보율이 아니다 | [12장](12_communication.md) 12.5.3절 표의 값만 쓴다 | [12장](12_communication.md) |
| `serOpen`은 되는데 글자가 사라지거나 `login:`·부팅 메시지가 섞인다, 또는 `serOpen` 실패 | 시리얼 콘솔(getty)이 같은 UART를 사용 중이다. pigpio는 장치를 독점하지 않는다. `cmdline.txt`에 `console=serial0,115200`이 남아 있으면 커널 로그도 섞인다 | raspi-config에서 serial login shell = No(하드웨어 UART는 켠 채로), 재부팅. `systemctl status serial-getty@ttyAMA0`, `cat /proc/cmdline`으로 확인. 작업은 SSH로 | [10장](10_measurement.md), [12장](12_communication.md) |
| 루프백에서 받음 0 B | 점퍼 빠짐, TX/RX 핀 착오, USB-TTL 어댑터가 RX를 구동 중 | 물리 핀 8 ↔ 10 확인, 어댑터 분리 | [12장](12_communication.md) |
| PC 화면에 글자가 두 번씩 | Pi와 터미널이 둘 다 에코 | PuTTY Local echo = Force off | [12장](12_communication.md) |
| PC에서 Enter를 쳐도 명령이 실행되지 않는다 | 줄 끝 문자 처리 불일치 | CR, LF 모두 받도록(`uart_cmd.c`) | [12장](12_communication.md) |
| `/dev/ttyUSB0`, `/dev/serial0` `Permission denied` (termios 프로그램) | `dialout` 그룹에 없다 | `sudo usermod -aG dialout $USER` 후 다시 로그인([5장](05_sysadmin.md)) | [12장](12_communication.md) |
| Pi의 RXD 핀이 동작하지 않는다(이전에 5 V 장치 연결) | 5 V 또는 RS-232 전압이 들어가 손상되었을 수 있다 | 다른 핀/다른 Pi와 비교. [12장](12_communication.md) 12.4절의 레벨 변환 사용 | [12장](12_communication.md) |
| `i2cdetect: command not found` | i2c-tools 미설치 | `sudo apt install i2c-tools` | [12장](12_communication.md) |
| `/dev/i2c-1`이 없다, `Error: Could not open file /dev/i2c-1`, `i2cOpen` → `PI_BAD_I2C_BUS`(−74) | ① I2C가 꺼져 있다 ② `dtparam=i2c_arm=on`은 있는데 `i2c-dev` 모듈이 올라오지 않았다 | ① raspi-config → Interface Options → I2C → Yes, 재부팅 ② `sudo modprobe i2c-dev`, 영구 적용은 `/etc/modules`에 `i2c-dev` 추가. 확인은 `ls /dev/i2c-*` | [7장](07_boot_kernel.md), [12장](12_communication.md) |
| `i2cdetect`에 아무 주소도 안 보인다 | I2C 비활성, SDA/SCL 뒤바뀜, 다른 핀(물리 3/5가 아님), 모듈 전원·GND 미연결, 레벨 시프터의 LV/HV 전원 누락, 모듈 불량 | raspi-config로 I2C를 켜고 재부팅. 물리 핀 3 = SDA, 5 = SCL 확인. 모듈 VCC 전압 측정. 레벨 시프터는 LV에 3.3 V, HV에 5 V가 모두 있어야 한다 | [10장](10_measurement.md), [12장](12_communication.md) |
| 모든 주소에 숫자가 보이거나 스캔이 매우 느리다 | SDA나 SCL이 Low에 붙어 있다(단락, 풀업 없음) | 전원을 끄고 배선 점검. 쉬는 상태 SDA·SCL 전압이 High인지 측정 | [12장](12_communication.md) |
| `UU`가 보인다 | **커널 드라이버**가 그 주소를 쓰고 있다(예: `dtoverlay=i2c-rtc,ds3231`) | pigpio로 직접 다루려면 그 오버레이를 지우고 재부팅. 커널 드라이버를 쓸 거면 `hwclock`, `/dev/rtc0` 사용([12장](12_communication.md) 12.6.10절) | [12장](12_communication.md) |
| `i2cOpen` → `PI_I2C_OPEN_FAILED`(−71) | 위와 같은 이유(주소 사용 중) | 위와 같음 | [12장](12_communication.md) |
| `Remote I/O error`(`-EREMOTEIO`), `i2c*` → `PI_I2C_WRITE_FAILED`(−82)/`READ_FAILED`(−83) | 타깃이 **NACK**: 주소 틀림, 전원 없음, 배선 불량, 칩이 바쁨 | `i2cdetect`로 주소 재확인(0x27 ↔ 0x3F, 0x76 ↔ 0x77), 데이터시트의 7비트/8비트 주소 표기 확인 | [12장](12_communication.md) |
| LCD 백라이트는 켜지는데 글자가 없다 | **명암 가변저항**, 주소 불일치(0x27 vs 0x3F), 초기화 실패, 3.3 V 전원 | 백팩 뒤 가변저항 조절. `i2cdetect`의 주소로 실행. 5 V + 레벨 시프터 | [12장](12_communication.md) |
| LCD 첫 줄에 네모만 보인다 | 전원은 들어왔지만 초기화되지 않았다 | 주소·배선 확인, 프로그램 재실행(초기화 절차가 4비트 상태도 처리한다) | [12장](12_communication.md) |
| LCD에 깨진 글자, 가끔 엉뚱한 위치 | 배선 접촉 불량, 모듈 핀 배치가 다른 백팩(P0~P7 대응이 다름) | 점퍼선 교체. 모듈 회로도로 `LCD_RS`~`LCD_BL` 비트 확인 | [12장](12_communication.md) |
| 5 V 모듈을 연결했더니 Pi I2C가 이상하다, I2C 선의 쉬는 전압이 3.3 V보다 높다 | 5 V로 전원을 넣은 모듈의 풀업이 SDA·SCL을 3.3 V보다 높게 끌어올린다 | 즉시 SDA·SCL을 Pi에서 분리한다. 모듈 VCC를 3.3 V로 바꾸거나 [12장](12_communication.md) 12.4.4절의 레벨 시프터를 쓴다. 다음부터는 실습 10-6의 순서대로 SDA·SCL을 연결하기 **전에** 측정한다 | [10장](10_measurement.md), [12장](12_communication.md) |
| DS3231 시각이 2000-01-01 근처, OSF=1 | 처음 쓰는 칩이거나 배터리 없음/방전 | `sudo ./ds3231_rtc set`, 코인 배터리 확인 | [12장](12_communication.md) |
| DS3231 온도가 200 °C 이상 | 온도 MSB를 부호 없는 값으로 읽음 | `int16_t`로 2의 보수 해석(실습 12-4) | [12장](12_communication.md) |
| BMP280 `chip_id`가 0x58이 아니다 | 주소 틀림, BME280(0x60), 다른 칩 | `i2cdetect`로 주소 확인, 0x60이면 BME280 | [12장](12_communication.md) |
| BMP280 원시값이 0x80000 | 측정 모드를 켜지 않음(sleep) | `ctrl_meas`(0xF4)에 forced/normal 모드 쓰기 | [12장](12_communication.md) |
| 클록 스트레칭을 쓰는 센서가 가끔 실패 | 하드웨어 I2C의 스트레칭 처리 한계 가능성(📌 확인 필요) | 클록 낮추기, `dtoverlay=i2c-gpio`(핀은 `i2c_gpio_sda/scl`로 지정) 또는 `bbI2COpen` | [12장](12_communication.md) |
| MCP3008 값이 늘 0 | MISO(DOUT) 미연결, CS가 다른 핀, VREF가 0 V, 칩 전원 없음 | DOUT → GPIO9(물리 21), CS → GPIO8(물리 24), VREF·VDD 3.3 V 확인 | [12장](12_communication.md) |
| MCP3008 값이 늘 1023 | MISO가 떠서 High, 입력이 VREF 이상, AGND 미연결 | 배선 확인, 가변저항 양 끝이 3.3 V/GND인지 | [12장](12_communication.md) |
| 값이 뒤죽박죽 | 모드 불일치, 클록이 너무 빠름, 명령 바이트 오류 | 모드 0 또는 3, 1 MHz 이하, `0x01, 0x80 \| ch<<4, 0x00` | [12장](12_communication.md) |
| `spiOpen` 실패 `PI_BAD_SPI_SPEED`(−78) | baud가 32 kHz 미만 또는 범위 밖 | 32000 이상 | [12장](12_communication.md) |
| `/dev/spidev0.0`이 없다 | `dtparam=spi=on` 미설정 | raspi-config → SPI. (pigpio `spiOpen`은 필요 없다) | [12장](12_communication.md) |
| spidev 프로그램이 pigpio 프로그램 실행 뒤 이상하다 | 두 방식이 SPI0 레지스터·CS 핀을 서로 덮어씀 | 동시에 실행하지 않는다. pigpio 프로그램은 `spiClose()`로 정상 종료 | [12장](12_communication.md) |
| 시각이 모두 0이거나 165년 같은 터무니없는 값 | DAT 배선, CE 미연결, 전원 없음 | GPIO12/19/16(CE/SCLK/I/O), 물리 핀 32/35/36 확인. `PIN_*`와 배선 일치 | [12장](12_communication.md) |
| 시각이 흐르지 않는다(초가 그대로) | CH = 1(발진 정지) | `sudo ./ds1302_rtc set` | [12장](12_communication.md) |
| `set` 해도 시각이 바뀌지 않는다 | WP = 1 상태에서 씀, CE 타이밍 부족 | WP 해제 후 쓰기(코드에 포함), 지연 확인 | [12장](12_communication.md) |
| 시가 이상하게 나온다(예: 81시) | 12시간제 비트(비트7)를 마스크하지 않음 | `hour_from_reg()`처럼 처리 | [12장](12_communication.md) |
| 원본 코드와 SPI 실습을 함께 쓰면 둘 다 이상하다 | 원본 핀(GPIO9/10/11)이 SPI0과 겹침 | 교재 표준 핀(GPIO12/19/16) 사용(C.4.2) | [12장](12_communication.md) |
| 시리얼 루프백에서 아무것도 돌아오지 않는다 | TX–RX 점퍼 누락, 다른 장치(Bluetooth)가 UART 사용 | GPIO14 (물리 핀 8)–GPIO15 (물리 핀 10) 연결 확인 | [부록 B](appendix_b_gpio_libraries.md) |
| 시리얼 읽기 값이 −2 같은 음수로 찍힌다 | `serReadByte`는 데이터가 없으면 바로 음수를 돌려준다 | `serDataAvailable()`로 먼저 확인 | [부록 B](appendix_b_gpio_libraries.md) |

### C.5.10 측정(AD2·WaveForms)

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| WaveForms에 장치가 없다, DEMO만 보인다 | USB 케이블(충전 전용 케이블), 드라이버 미설치, 다른 WaveForms 창이나 프로그램이 장치를 잡고 있음 | 데이터 케이블로 바꾸고 다른 USB 포트에 꽂는다. WaveForms 재설치(Adept Runtime 포함). 다른 창 종료 후 Settings → Device Manager에서 선택 | [10장](10_measurement.md) |
| 실행 중 "장치 연결이 끊겼다", 전원 경고 | USB 허브·포트의 전력 부족, Supplies 과부하 | PC 본체 포트에 직접 연결. Supplies 부하 제거. 필요하면 외부 5 V 어댑터 | [10장](10_measurement.md) |
| 신호가 전혀 안 보인다(평평한 선) | ① **GND 미연결** ② WaveForms의 DIO 번호와 실제 배선 불일치 ③ Pi 핀 번호 혼동(BCM과 물리 번호) ④ Run을 누르지 않음 ⑤ 프로그램이 실행 중이 아님 | ① AD2 검은 선을 Pi GND에 ② 채널 설정의 DIO 번호를 소켓 이름표와 대조 ③ `pinctrl get 17`로 핀 상태 확인, [10장](10_measurement.md) 10.5.4 표 대조 ④ Logic·Scope는 Run을 눌러야 갱신된다(Static I/O와 다름) ⑤ 프로그램 출력 확인 | [10장](10_measurement.md) |
| 파형이 화면에서 흘러간다, 멈추지 않는다 | 트리거 소스·조건·레벨이 맞지 않음, 모드가 None | 소스를 측정 채널로, 레벨을 신호 중간(약 1.6 V)으로, 모드 Auto 또는 Normal | [10장](10_measurement.md) |
| Single을 눌렀는데 아무것도 안 잡힌다 | 트리거 조건이 오지 않음(에지 방향 반대, 레벨이 신호 범위 밖), 신호가 그 전에 이미 지나감 | Fall/Rise 바꿔 보기. Single을 먼저 누르고 **그다음** 버튼을 누르거나 프로그램 실행 | [10장](10_measurement.md) |
| 주파수 측정값이 이상하게 낮다, 엉뚱한 파형 | **앨리어싱**: 샘플링 속도가 신호 주파수의 2배보다 낮음 | Rate를 올린다(신호의 10배 이상). Base를 줄이면 Rate가 올라간다 | [10장](10_measurement.md) |
| 3.3 V 신호가 0.33 V로 보인다 | ×10 프로브인데 WaveForms 배율이 1× | 채널 설정의 Attenuation을 10X로 | [10장](10_measurement.md) |
| 사각파가 위아래로 대칭(±1.65 V)으로 보인다 | BNC 어댑터가 AC 커플링 | 커플링 점퍼를 DC로 | [10장](10_measurement.md) |
| 상승 시간이 설정과 무관하게 늘 비슷하다 | 계측기 대역폭 한계(플라이와이어 약 39 ns) | BNC + ×10 프로브 사용, [10장](10_measurement.md) 10.2.4의 식으로 해석 | [10장](10_measurement.md) |
| 같은 신호가 Logic과 Scope에서 다르게 보인다 | Logic은 문턱값 기준 0/1만, Scope는 실제 전압. 애매한 레벨이나 느린 에지에서 차이 | 레벨이 의심되면 Scope로 전압 확인 | [10장](10_measurement.md) |
| UART 해석 결과가 쓰레기 문자 | 보레이트 불일치(Auto 추정 실패), Polarity가 Inverted, 데이터 비트·패리티 설정 불일치, 시작 비트 앞의 쉬는 High 구간이 잘림 | Baud를 직접 입력(9600/115200), Polarity Standard, 8N1. Position을 옮겨 프레임 앞부분이 보이게 | [10장](10_measurement.md) |
| I2C 해석이 안 된다(Start만 보이거나 아무것도 없음) | SCL과 SDA DIO를 바꿔 지정, 샘플링 속도 부족, GND 미연결 | Clock = DIO 14, Data = DIO 15 확인. Rate ≥ 1 MHz(100 kHz 기준) | [10장](10_measurement.md) |
| SPI 해석 값이 비트가 밀리거나 틀린다 | WaveForms의 샘플 에지(Polarity)가 SPI 모드와 다름, MSB/LSB 설정 | 실습 10-7의 모드 표대로 설정 | [10장](10_measurement.md) |
| 토글 프로그램 실행 중 주기가 가끔 크게 늘어난다 | 리눅스 스케줄링(다른 프로세스, 인터럽트) | 정상 현상. Pulse Timeout 트리거로 잡아 기록. 이것이 비실시간 OS의 특성 | [10장](10_measurement.md) |
| AD2를 연결하는 순간 Pi가 재부팅되거나 멈춘다 | AD2 V+를 Pi 전원 핀에 연결(역공급), 신호선이 5 V·3.3 V 핀에 닿아 단락, 접지 전위차가 큰 상태에서 연결(그라운드 루프) | V+·V−·W1·W2는 Pi에 연결하지 않는다. 전원을 끄고 GND부터 연결. Pi와 AD2를 같은 PC(같은 접지 경로)에서 쓰기 | [10장](10_measurement.md) |
| Patterns를 켜자 Pi 핀 값이 이상하다, 핀이 뜨거워진다 | AD2 출력과 Pi 출력이 같은 선에서 충돌 | 즉시 Patterns 정지. Pi 쪽 핀이 입력인지 `pinctrl get`으로 확인 후 다시 실행 | [10장](10_measurement.md) |
| Static I/O에서 Button을 눌러도 Pi가 반응하지 않는다 | DIO가 LED(표시) 모드로 남아 있음, GND 미연결, Pi 핀 풀업·풀다운이 반대 | Button/Switch로 바꾸고 출력 값 설정, GND 확인 | [10장](10_measurement.md) |
| WaveForms 화면이 느리고 측정값이 들쭉날쭉 | Pi에서 WaveForms를 실행해 측정 대상에 부하 | WaveForms는 PC에서 실행 | [10장](10_measurement.md) |

### C.5.11 BLE·Python

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `bluetoothctl show` → `No default controller available`, `hci0`이 없다, Bluetooth가 동작하지 않는다 | ① `config.txt`의 `dtoverlay=disable-bt`가 아직 살아 있다(주석 처리 안 함, 저장 안 함, 재부팅 안 함) ② (`krnbt=off`로 쓰는 경우) `hciuart`가 disable 상태 ③ rfkill 차단 | ① 실습 13-0을 다시: `grep disable-bt /boot/firmware/config.txt` ② `krnbt=off`이면 `sudo systemctl enable --now hciuart`, `systemctl status hciuart`(기본 `krnbt=on`에서는 해당 없음, [13장](13_ble_iot.md) 실습 13-0의 📌) ③ `rfkill list` → `sudo rfkill unblock bluetooth`. 그래도 안 되면 [3장](03_rpi_hw_os.md) 3.12.4절의 재설치 | [3장](03_rpi_hw_os.md), [13장](13_ble_iot.md) |
| 컨트롤러는 있는데 `Powered: no` | 전원이 꺼진 상태로 시작 | `bluetoothctl power on`. `/etc/bluetooth/main.conf`의 `AutoEnable=true` 확인 | [13장](13_ble_iot.md) |
| Bluetooth를 켠 뒤 UART 콘솔 글자가 깨진다 | 콘솔이 mini UART(`ttyS0`)로 옮겨 갔는데 `enable_uart=1`이 빠져 코어 클록이 고정되지 않음 | `config.txt`에 `enable_uart=1`이 살아 있는지 확인(있으면 펌웨어가 코어 클록을 250 MHz로 고정한다). 그래도 깨지면 `core_freq=250` 추가 후 재부팅. 또는 SSH 사용([13장](13_ble_iot.md)의 권장) | [13장](13_ble_iot.md) |
| UART에 펌웨어 진단 메시지가 안 나온다 | `uart_2ndstage` 출력이 PL011로 간다면 PL011이 Bluetooth로 갔기 때문(📌 확인 필요, [13장](13_ble_iot.md)) | 정상. [13장](13_ble_iot.md)을 마치고 `disable-bt`로 되돌리면 다시 나온다 | [13장](13_ble_iot.md) |
| 스캔에 체온계가 안 보인다 | ① 체온계가 광고 중이 아니다(절전, 이미 다른 기기(휴대전화 FEMON 앱)와 연결됨) ② 너무 멀거나 금속·몸에 가려짐 ③ 배터리 부족 | ① 블루투스 버튼을 짧게 눌러 광고 재시작, 휴대전화의 Bluetooth를 끈다(Peripheral은 보통 한 번에 한 Central만 받는다) ② 30 cm 안에서 시험 ③ 배터리 교체. `bluetoothctl scan on`에도 안 보이면 Python 문제가 아니다 | [13장](13_ble_iot.md) |
| 스캔은 되는데 이름이 `None`/주소뿐 | 이름이 Scan Response에 들어 있는데 아직 못 받음 | 스캔 시간을 늘린다(`--time 10`). 이름 대신 `--hts`(서비스 UUID)나 주소로 거른다 | [13장](13_ble_iot.md) |
| 연결이 `TimeoutError`/`BleakError: … not found`로 실패 | ① 연결 직전에 장치가 광고를 멈춤 ② 다른 Central과 이미 연결 ③ BlueZ의 캐시가 꼬임 | ① 다시 광고시키고 재시도(코드가 자동으로 함) ② 휴대전화 앱·다른 Pi의 연결 해제 ③ `bluetoothctl remove <주소>` 후 다시 스캔 | [13장](13_ble_iot.md) |
| 연결 중 `Authentication Failed`, `Insufficient Authentication`, 또는 연결 직후 끊김(진짜 TS100) | 페어링하지 않았거나, 체온계가 키를 잊었다(전원을 완전히 끔) | 실습 13-1 단계 4의 `pair`/`trust`. 키가 어긋났으면 `bluetoothctl remove <주소>` 후 다시 `pair` | [13장](13_ble_iot.md) |
| 연결은 되는데 알림(온도)이 안 온다 | ① 구독을 안 함(`start_notify` 누락, 또는 `read_gatt_char`만 함) ② 특성이 indicate인데 확인 응답을 안 보내는 도구를 씀 ③ UUID 오타(`…f9634fb` 같은) ④ 시뮬레이터는 **연결된 동안에만** 보낸다 | ① `start_notify` 확인. `btmon`에서 0x2902 쓰기(`0100`/`0200`)가 나가는지 본다 ② bleak·bluetoothctl은 자동 처리하므로 [13장](13_ble_iot.md)의 코드는 해당 없음 ③ `hts.py`의 상수를 쓴다 ④ 연결 상태 확인 | [13장](13_ble_iot.md) |
| 같은 알림이 두 번씩 온다 | 같은 특성에 `start_notify`를 두 번 했거나, 프로그램을 두 개 띄움 | `ps aux \| grep read_temp`, 서비스(`gateway`)와 손으로 띄운 프로그램이 동시에 돌고 있지 않은지 확인 | [13장](13_ble_iot.md) |
| 온도가 1677720.1 같은 터무니없는 값 / 날짜에서 `ValueError: month must be in 1..12` | 원본 해석 코드(부호 무시, Flags 무시)를 씀 | `hts.py`의 `parse_temperature_measurement()` 사용([13장](13_ble_iot.md) 13.9.4절) | [13장](13_ble_iot.md) |
| `ModuleNotFoundError: No module named 'bleak'` | 가상 환경 밖에서 실행, 또는 서비스가 시스템 Python을 씀 | `source ~/ch13/.venv/bin/activate` 후 실행. 서비스는 `ExecStart=`에 `.venv/bin/python` 절대 경로 | [13장](13_ble_iot.md) |
| `AttributeError: 'BLEDevice' object has no attribute 'rssi'`, `… has no attribute 'get_services'`, 콜백에서 `handle`이 정수가 아님 | bleak 3.x에서 옛 예제(TS100 저장소, 인터넷 글)를 실행 | [13장](13_ble_iot.md) 13.11.2절의 표대로 고친다: `discover(return_adv=True)`의 `adv.rssi`, `client.services`, 콜백 첫 인자는 특성 객체 | [13장](13_ble_iot.md) |
| `ValueError` … `0x2902` | bleak 3.0부터 CCCD 직접 쓰기 금지 | `start_notify()`/`stop_notify()` 사용 | [13장](13_ble_iot.md) |
| `org.freedesktop.DBus.Error.AccessDenied`, `Permission denied`(sudo 없이 실행할 때) | 사용자가 `bluetooth` 그룹에 없다 | `sudo usermod -aG bluetooth $USER` 후 **다시 로그인**. 서비스는 `User=`가 그 사용자인지 확인 | [13장](13_ble_iot.md) |
| `org.bluez.Error.InProgress`, `Operation already in progress` | 스캔·연결을 동시에 여러 개 시작했다(다른 프로그램이 스캔 중 포함) | 다른 BLE 프로그램 종료. `logger.py`처럼 한 프로그램 안에서 관리하고, 실패 시 대기 후 재시도 | [13장](13_ble_iot.md) |
| 가끔 `Not connected`, 광고가 띄엄띄엄 들어온다 | Pi 4는 Wi-Fi와 Bluetooth가 한 칩·한 안테나를 나누어 쓴다(공존 간섭) | 유선 LAN을 쓰고 `sudo nmcli radio wifi off`로 시험해 본다(bleak 공식 문제 해결 문서의 권고). 지속되면 USB Bluetooth 어댑터 | [13장](13_ble_iot.md) |
| 서비스 로그(`journalctl -u gateway`)에 아무것도 안 나온다 | Python 출력 버퍼링 | 유닛의 `Environment=PYTHONUNBUFFERED=1` 확인 | [13장](13_ble_iot.md) |
| 그래프 창이 안 뜬다 / `cannot connect to X server` | SSH·서비스에는 화면이 없다 | `report.py plot`처럼 `matplotlib.use("Agg")`로 PNG 저장. 실시간 창이 필요하면 원격 데스크톱([3장](03_rpi_hw_os.md) 3.11절)에서 실행 | [13장](13_ble_iot.md) |
| `uploader.py`가 `HTTP 403`/`401` | 토큰이 틀리거나 API가 다른 방식(GET/POST)을 기대 | `gateway.env`의 토큰과 `GATEWAY_UPLOAD_METHOD` 확인. GitBook 5.10절 API는 GET | [13장](13_ble_iot.md) |
| 측정 시각이 1970년이나 엉뚱한 날짜 | Pi 시계가 NTP로 맞춰지기 전에 기록 | `timedatectl`에서 동기화 확인([5장](05_sysadmin.md) 5.12절). 장치 시각보다 `received_at`을 기준으로 쓴다 | [13장](13_ble_iot.md) |

### C.5.12 MATLAB/Simulink

| 증상(실제 메시지) | 원인 | 해결 | 자세히 |
|---|---|---|---|
| `raspi(...)` 또는 Test Connection에서 연결 실패 | IP가 바뀌었거나 다른 네트워크, SSH 꺼짐, 사용자·암호 오류 | 먼저 PC에서 `ssh student@192.168.0.xx`가 되는지 확인. Pi에서 `hostname -I`로 IP 재확인, `sudo systemctl status ssh` | [부록 A](appendix_a_matlab_simulink.md) |
| Test Connection의 sudo 항목 실패 | 사용자에게 sudo 권한이 없음 | Imager로 만든 첫 사용자는 sudo 그룹이다. 다른 사용자라면 `sudo usermod -aG sudo 사용자` | [부록 A](appendix_a_matlab_simulink.md) |
| 인터넷 항목 실패, 라이브러리 설치 실패 | Pi가 인터넷에 못 나감, `apt` 저장소 문제 | `ping deb.debian.org`, `sudo apt update`로 오류 메시지 확인. 실습실 프록시·DNS 확인 | [부록 A](appendix_a_matlab_simulink.md) |
| 지원 패키지가 OS를 지원하지 않는다는 메시지, 설치는 됐는데 빌드·실행 오류 | MATLAB 릴리스와 Pi OS 버전 조합이 호환표 밖(예: R2024b + Bookworm 64비트의 MATLAB 패키지) | [부록 A](appendix_a_matlab_simulink.md) A.2.2절 호환표 확인. MATLAB을 올리거나 지원되는 OS 이미지 사용 | [부록 A](appendix_a_matlab_simulink.md) |
| `configurePin`에서 `Incorrect number or types of inputs…` | `raspberrypi` 객체에 GPIO 함수 사용 | `rpi = raspi(...)`로 만든 객체를 쓴다 | [부록 A](appendix_a_matlab_simulink.md) |
| `sin(2*pi*t)` 결과가 이상하다 | 변수 이름 `pi`가 원주율을 가림 | `clear pi`, 변수 이름을 `rpi`로 | [부록 A](appendix_a_matlab_simulink.md) |
| 두 번째 `i2cdev(...)`가 실패 | 변수 이름 `i2cdev`가 함수를 가림 | `clear i2cdev`, 변수 이름을 `sensor` 등으로 | [부록 A](appendix_a_matlab_simulink.md) |
| 버튼 값이 제멋대로 바뀐다 | 풀업이 없음(`configurePin`에는 풀업 옵션이 없다) | `system(rpi,'pinctrl set 26 ip pu')` 또는 외부 풀업 | [부록 A](appendix_a_matlab_simulink.md) |
| Simulink에 Hardware 탭이 없음 | 지원 패키지 미설치, Hardware board 미설정 | 설치 확인 후 Model Settings → Hardware board → Raspberry Pi (64bit) | [부록 A](appendix_a_matlab_simulink.md) |
| Build 중 `make` 오류, 헤더·라이브러리 없음 | Hardware Setup의 라이브러리 설치를 건너뜀, OS를 새로 설치함 | Hardware Setup을 다시 실행해 라이브러리 설치 단계까지 진행. 진단 창의 첫 오류 줄을 [6장](06_c_build.md) 6.4절 표와 대조 | [부록 A](appendix_a_matlab_simulink.md) |
| Monitor & Tune이 연결 단계에서 시간 초과 | 방화벽·백신이 MATLAB의 접속을 막음, VPN, Wi-Fi 불안정, 빌드가 오래 걸림 | Windows 방화벽에서 MATLAB 허용, VPN 끄기, 유선 LAN 사용. Pi에서 `ps aux \| grep elf`로 프로그램이 떴는지 확인. 저장소 모델의 External Mode 포트 설정은 17725이다 | [부록 A](appendix_a_matlab_simulink.md) |
| 한 번 Monitor & Tune 후 다시 하면 연결 실패 | 이전 실행 파일이 아직 돌며 포트를 잡고 있음 | `stopModel`, 또는 Pi에서 `sudo pkill -f 모델이름.elf` 후 재시도 | [부록 A](appendix_a_matlab_simulink.md) |
| Pi에서 직접 `./모델.elf` 실행 시 `You must have root privileges…SCHED_FIFO` | 생성 코드가 실시간 스케줄링 사용 | `sudo ./모델.elf`. `gpio` 그룹에 넣는 것으로는 해결되지 않는다 | [부록 A](appendix_a_matlab_simulink.md) |
| `error while loading shared libraries: libmwraspiperipheral.so` | Hardware Setup을 하지 않은 Pi에 `.elf`만 복사 | 그 Pi에서 Hardware Setup 실행. ELF를 다른 Pi로 옮기면 의존 라이브러리도 필요하다(`readelf -d`로 확인) | [부록 A](appendix_a_matlab_simulink.md) |
| `.elf`를 못 찾겠다 | 위치가 릴리스·경로에 따라 다름 | `find ~/MATLAB_ws -name "*.elf"`. 주로 `~/MATLAB_ws/R20xx/` 아래에 PC 쪽 폴더 경로를 본뜬 하위 폴더가 생긴다 | [부록 A](appendix_a_matlab_simulink.md) |
| PC에 `slprj/`, `*_ert_rtw/`가 엉뚱한 곳에 생김 | MATLAB의 **현재 폴더**에 생성된다 | 모델이 있는 폴더로 `cd` 한 뒤 빌드 | [부록 A](appendix_a_matlab_simulink.md) |
| LED가 몇 초 깜빡이다 멈춘다 | Stop time이 유한함(저장소 모델은 5, 10) | Stop time을 `inf`로 | [부록 A](appendix_a_matlab_simulink.md) |
| 모델은 도는데 LED가 반응 없음 | 블록의 핀 번호가 배선과 다름(저장소 모델은 GPIO27 등) | 블록 더블클릭으로 핀 확인, `pinctrl get 17`로 레벨 변화 확인 | [부록 A](appendix_a_matlab_simulink.md) |
| `codegen`에서 `filter` 상태 관련 크기 오류 | `persistent` 상태 `zi`의 크기·방향(행/열)이 호출마다 바뀜 | `zi`를 열 벡터 `zeros(windowSize-1,1)`로 초기화(벡터 입력의 필터 상태는 열 벡터로 돌아온다) | [부록 A](appendix_a_matlab_simulink.md) |
| `make ma`에서 `codegen/lib/moving_average 폴더가 없다` | 생성 폴더를 복사하지 않음 | PC에서 `build_ma` 후 `scp -r codegen …` | [부록 A](appendix_a_matlab_simulink.md) |
| MATLAB Coder·Embedded Coder 메뉴가 없음, 라이선스 오류 | 캠퍼스 라이선스에 해당 제품 없음 | `license('test','MATLAB_Coder')`로 확인, 학교 라이선스 관리자에게 문의 | [부록 A](appendix_a_matlab_simulink.md) |

---

## C.6 용어집

이 책에 나오는 핵심 용어 138개를 모았다. 우리말 용어는 가나다순, 약어와 영어 이름은 알파벳순이다. "장"은 그 용어를 자세히 설명한 장이다. 처음 보는 용어는 정의를 외우기보다 **왜 그런 이름이 붙었는지**를 생각하며 해당 장을 읽는다.

### C.6.1 우리말 용어

| 용어 | 영어 | 뜻 | 장 |
|---|---|---|---|
| 가상 메모리 | virtual memory | 프로세스마다 독립된 주소 공간을 주고, MMU가 가상 주소를 물리 주소로 바꾸는 방식 | [11장](11_process_concurrency.md) |
| 가상 환경 | virtual environment, venv | 프로젝트마다 따로 둔 Python 패키지 설치 공간. Bookworm에서 `pip install`은 이 안에서 한다 | [5장](05_sysadmin.md), [13장](13_ble_iot.md) |
| 게이트웨이 | gateway | 센서 장치의 데이터를 받아 저장·가공하고 인터넷(클라우드)으로 넘기는 중간 장치 | [13장](13_ble_iot.md) |
| 경쟁 조건 | race condition | 둘 이상의 실행 흐름이 공유 데이터에 접근하는 순서에 따라 결과가 달라지는 현상 | [11장](11_process_concurrency.md) |
| 고아 프로세스 | orphan process | 부모가 먼저 끝나 다른 프로세스(보통 systemd)가 거두어 가는 프로세스 | [11장](11_process_concurrency.md) |
| 공유 라이브러리 | shared library (`.so`) | 실행할 때 동적 로더가 메모리에 올려 여러 프로그램이 함께 쓰는 라이브러리 | [6장](06_c_build.md) |
| 광고 | advertising | BLE Peripheral이 자기 존재와 정보를 주기적으로 알리는 짧은 패킷 | [13장](13_ble_iot.md) |
| 교차 개발 | cross development | 프로그램을 만드는 컴퓨터(호스트)와 실행하는 컴퓨터(타깃)가 다른 개발 방식 | [6장](06_c_build.md), [7장](07_boot_kernel.md) |
| 교차 컴파일러 | cross compiler | 다른 CPU용 실행 파일을 만드는 컴파일러(예: `aarch64-linux-gnu-gcc`) | [6장](06_c_build.md), [7장](07_boot_kernel.md) |
| 교착 상태 | deadlock | 둘 이상의 스레드가 서로 상대가 쥔 잠금을 기다리며 영원히 멈춘 상태 | [11장](11_process_concurrency.md) |
| 구동 세기 | drive strength | 출력 핀이 낼 수 있는 전류의 설정값(BCM2711의 pad 설정) | [8장](08_gpio_pigpio.md), [10장](10_measurement.md) |
| 그라운드 | ground, GND | 전압의 기준점. 장치끼리 연결할 때는 반드시 공통으로 묶는다 | [8장](08_gpio_pigpio.md), [10장](10_measurement.md) |
| 내장 명령 | shell builtin | 셸 프로그램 안에 들어 있는 명령(`cd`, `export` 등). `type`으로 확인한다 | [4장](04_linux_shell.md) |
| 데몬 | daemon | 백그라운드에서 계속 돌며 서비스를 제공하는 프로세스(`pigpiod`, `bluetoothd` 등) | [5장](05_sysadmin.md), [8장](08_gpio_pigpio.md) |
| 동적 로더 | dynamic loader | 실행할 때 공유 라이브러리를 찾아 연결하는 프로그램(`ld-linux-aarch64.so.1`) | [6장](06_c_build.md) |
| 디바운스 | debounce | 채터링으로 생긴 여러 번의 변화를 한 번으로 거르는 처리 | [9장](09_pigpio_advanced.md) |
| 디바이스 트리 | device tree (DT, DTB) | 보드의 하드웨어 구성을 커널 코드에서 떼어 내 적은 데이터 파일. 펌웨어가 커널에 넘긴다 | [7장](07_boot_kernel.md) |
| 라이브러리 | library | 미리 컴파일한 함수(정의)의 묶음. 헤더는 선언만 담는다 | [6장](06_c_build.md) |
| 레벨 시프터 | level shifter | 서로 다른 전압(3.3 V ↔ 5 V)의 논리 신호를 이어 주는 회로. 이 책은 5 V 장치(HC-SR04, 5 V LCD)를 모두 4채널 양방향 BSS138 모듈(LV = 3.3 V, HV = 5 V)로 연결한다(채널 규약은 C.4.1) | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md), [12장](12_communication.md) |
| 루트 파일 시스템 | root file system | `/`에 마운트되는 파일 시스템. Pi에서는 SD 카드의 두 번째 파티션(`rootfs`) | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md) |
| 리셋 벡터 | reset vector | 리셋 직후 CPU가 처음 실행하는 주소 | [2장](02_computer_arch_arm.md), [7장](07_boot_kernel.md) |
| 링커 | linker | 목적 파일과 라이브러리를 묶어 주소를 정하고 실행 파일을 만드는 프로그램(`ld`) | [6장](06_c_build.md) |
| 링커 스크립트 | linker script | 섹션을 메모리의 어디에 둘지(VMA/LMA) 정하는 파일 | [6장](06_c_build.md) |
| 마운트 | mount | 파일 시스템을 디렉터리 나무의 한 지점에 붙이는 일 | [5장](05_sysadmin.md) |
| 메모리 계층 | memory hierarchy | 레지스터 → 캐시 → 주 메모리 → 저장장치로 이어지는 속도·용량의 층 | [2장](02_computer_arch_arm.md) |
| 메모리 맵 I/O | memory-mapped I/O | 주변장치 레지스터를 메모리 주소로 읽고 쓰는 방식 | [2장](02_computer_arch_arm.md) |
| 모델 기반 설계 | Model-Based Design, MBD | 모델로 설계·검증하고 코드를 자동 생성하는 개발 방식 | [부록 A](appendix_a_matlab_simulink.md) |
| 문맥 교환 | context switch | CPU가 실행할 태스크를 바꾸며 레지스터 상태를 저장·복원하는 일 | [11장](11_process_concurrency.md) |
| 뮤텍스 | mutex (mutual exclusion) | 임계 구역에 한 번에 한 스레드만 들어가게 하는 잠금 | [11장](11_process_concurrency.md) |
| 반이중 | half duplex | 한 번에 한쪽만 보낼 수 있는 통신(I2C) | [12장](12_communication.md) |
| 베어메탈 | bare-metal | OS 없이 프로그램이 하드웨어를 직접 다루는 방식(1인 분식집) | [1장](01_embedded_system.md) |
| 보율 | baud rate | 1초에 보내는 심볼 수. UART에서는 비트 수와 같고, 양쪽이 같아야 한다 | [3장](03_rpi_hw_os.md), [12장](12_communication.md) |
| 부트로더 | bootloader | 전원·리셋 뒤 커널을 메모리에 올리고 실행을 넘기는 프로그램 | [7장](07_boot_kernel.md) |
| 분압기 | voltage divider | 저항 두 개로 전압을 나누는 회로. 레벨 시프터가 없을 때 5 V 출력을 받기만 하는 선(HC-SR04 ECHO 등)을 3.3 V 이하로 낮추는 **대안**(1 kΩ/2 kΩ). 양방향인 I2C에는 쓸 수 없다 | [9장](09_pigpio_advanced.md), [12장](12_communication.md) |
| 비동기 통신 | asynchronous communication | 클록선 없이 미리 정한 속도로 주고받는 통신(UART) | [12장](12_communication.md) |
| 비트뱅 | bit-banging | 전용 하드웨어 없이 GPIO를 소프트웨어로 움직여 통신 규약을 구현하는 것 | [12장](12_communication.md) |
| 상승 시간 | rise time | 신호가 최종값의 10 %에서 90 %까지 올라가는 데 걸리는 시간 | [10장](10_measurement.md) |
| 샘플링 속도 | sample rate | 계측기가 1초에 값을 읽는 횟수. 신호 주파수의 2배보다 커야 한다(실제로는 10배 이상) | [10장](10_measurement.md) |
| 서비스 (GATT) | service | 관련 특성을 묶은 GATT 단위(예: Health Thermometer, 0x1809) | [13장](13_ble_iot.md) |
| 선점형 스케줄링 | preemptive scheduling | 실행 중인 태스크가 내놓지 않아도 커널이 CPU를 빼앗을 수 있는 방식. 현재 리눅스는 선점형이다 | [7장](07_boot_kernel.md), [11장](11_process_concurrency.md) |
| 세마포어 | semaphore | 정해진 개수만큼만 동시에 들어가게 하는 계수 잠금(주차장 빈자리 표시판) | [11장](11_process_concurrency.md) |
| 섹션 | section | ELF 파일 안의 구역(`.text`, `.rodata`, `.data`, `.bss` 등) | [6장](06_c_build.md) |
| 셸 | shell | 사용자의 명령을 해석해 커널에 전달하는 프로그램(bash, dash) | [4장](04_linux_shell.md) |
| 스레드 | thread | 한 프로세스 안의 실행 흐름. 코드·데이터·힙을 공유하고 스택은 따로 갖는다 | [11장](11_process_concurrency.md) |
| 스왑 | swap | 메모리가 부족할 때 저장장치(또는 zram)를 메모리처럼 쓰는 공간 | [5장](05_sysadmin.md) |
| 스케줄러 | scheduler | 어느 태스크가 언제 CPU를 쓸지 정하는 커널 부분 | [5장](05_sysadmin.md), [11장](11_process_concurrency.md) |
| 시그널 | signal | 프로세스에 보내는 비동기 알림(SIGINT, SIGTERM, SIGKILL 등) | [5장](05_sysadmin.md), [11장](11_process_concurrency.md) |
| 시스템 콜 | system call | 사용자 프로그램이 커널 기능을 요청하는 공식 창구 | [4장](04_linux_shell.md) |
| 실시간 시스템 | real-time system | 결과의 정확성뿐 아니라 정해진 마감 안에 내는 것이 중요한 시스템. 하드·소프트 실시간으로 나뉜다 | [1장](01_embedded_system.md), [11장](11_process_concurrency.md) |
| 심볼릭 링크 | symbolic link | 다른 파일의 경로를 담은 특수 파일. 원본이 지워지면 깨진다 | [4장](04_linux_shell.md) |
| 알림 콜백 | alert callback | pigpio가 GPIO를 DMA로 샘플링하다 레벨 변화를 발견하면 별도 스레드에서 부르는 함수(`gpioSetAlertFunc`) | [9장](09_pigpio_advanced.md), [11장](11_process_concurrency.md) |
| 앨리어싱 | aliasing | 샘플링 속도가 부족해 실제와 다른(낮은) 주파수로 보이는 현상 | [10장](10_measurement.md) |
| 엔디언 | endianness | 여러 바이트 값을 메모리에 놓는 순서(리틀 엔디언, 빅 엔디언) | [2장](02_computer_arch_arm.md), [12장](12_communication.md) |
| 예외 | exception | 인터럽트·시스템 콜·오류처럼 정상 흐름을 끊고 처리 루틴으로 가는 사건 | [2장](02_computer_arch_arm.md) |
| 예외 레벨 | exception level, EL0~EL3 | AArch64의 권한 단계. 응용 EL0, 커널 EL1, 하이퍼바이저 EL2, 보안 모니터 EL3 | [2장](02_computer_arch_arm.md), [7장](07_boot_kernel.md) |
| 오픈 드레인 | open-drain | Low만 직접 만들고 High는 풀업 저항에 맡기는 출력 구조(I2C) | [8장](08_gpio_pigpio.md), [12장](12_communication.md) |
| 원자적 연산 | atomic operation | 중간에 다른 흐름이 끼어들 수 없이 한 번에 끝나는 연산 | [11장](11_process_concurrency.md) |
| 웨이브폼 | waveform | pigpio가 DMA로 μs 단위의 펄스열을 미리 만들어 내보내는 기능 | [9장](09_pigpio_advanced.md) |
| 유닛 | unit | systemd가 관리하는 대상(서비스, 타이머, 마운트 등)을 적은 설정 단위 | [5장](05_sysadmin.md) |
| 이벤트 루프 | event loop | asyncio에서 코루틴들을 번갈아 실행하는 관리자 | [13장](13_ble_iot.md) |
| 인터럽트 | interrupt | 외부 사건이 CPU의 현재 작업을 잠시 멈추고 처리 루틴을 실행하게 하는 신호 | [2장](02_computer_arch_arm.md), [9장](09_pigpio_advanced.md) |
| 임계 구역 | critical section | 공유 자원을 다루어 한 번에 한 흐름만 실행해야 하는 코드 구간 | [11장](11_process_concurrency.md) |
| 임베디드 시스템 | embedded system | 특정 기능을 위해 기기 안에 넣은 컴퓨터 시스템 | [1장](01_embedded_system.md) |
| 전이중 | full duplex | 양쪽이 동시에 보내고 받을 수 있는 통신(UART, SPI) | [12장](12_communication.md) |
| 정적 라이브러리 | static library (`.a`) | 링크할 때 필요한 목적 코드를 실행 파일 안에 복사해 넣는 라이브러리 | [6장](06_c_build.md) |
| 좀비 프로세스 | zombie process | 끝났지만 부모가 `wait`로 거두지 않아 프로세스 표에 남은 항목(`<defunct>`) | [11장](11_process_concurrency.md) |
| 주소 디코딩 | address decoding | 주소의 일부 비트로 어느 메모리·장치를 선택할지 정하는 회로 | [2장](02_computer_arch_arm.md) |
| 지터 | jitter | 주기나 타이밍의 흔들림 | [10장](10_measurement.md), [11장](11_process_concurrency.md) |
| 채터링 | chattering, bounce | 스위치 접점이 붙고 떨어질 때 짧은 시간 동안 여러 번 열리고 닫히는 현상 | [9장](09_pigpio_advanced.md), [10장](10_measurement.md) |
| 캐시 | cache | CPU와 주 메모리 사이의 작고 빠른 메모리(SRAM) | [2장](02_computer_arch_arm.md) |
| 커널 | kernel | CPU·메모리·장치를 관리하는 운영체제의 핵심 | [4장](04_linux_shell.md), [7장](07_boot_kernel.md) |
| 커널 모듈 | kernel module (`.ko`) | 실행 중인 커널에 넣고 뺄 수 있는 코드 조각(드라이버 등) | [7장](07_boot_kernel.md) |
| 코루틴 | coroutine | `async def`로 만든, 기다리는 동안 다른 일에 CPU를 양보하는 함수 | [13장](13_ble_iot.md) |
| 클록 스트레칭 | clock stretching | I2C 타깃이 SCL을 Low로 붙잡아 컨트롤러를 기다리게 하는 기능 | [12장](12_communication.md) |
| 타깃 | target | 프로그램이 실제로 실행될 보드. 개발용 컴퓨터는 호스트(host) | [6장](06_c_build.md) |
| 툴체인 | toolchain | 컴파일러·어셈블러·링커·C 라이브러리 등 빌드 도구의 묶음 | [6장](06_c_build.md) |
| 트리거 | trigger | 계측기가 화면을 맞추는 기준 조건(에지, 레벨, 펄스 폭) | [10장](10_measurement.md) |
| 특성 | characteristic | GATT에서 값 하나와 그 속성(read, write, notify, indicate)을 담는 단위 | [13장](13_ble_iot.md) |
| 파이프 | pipe | 한 명령(프로세스)의 출력을 다음 명령의 입력으로 잇는 통로(셸의 세로 막대 기호) | [4장](04_linux_shell.md), [11장](11_process_concurrency.md) |
| 파이프라인 | pipeline | 명령어 처리 단계를 겹쳐 실행해 처리량을 높이는 CPU 구조 | [2장](02_computer_arch_arm.md) |
| 파티션 | partition | 저장장치를 나눈 구역. Pi의 SD 카드는 `bootfs`(FAT32)와 `rootfs`(ext4) | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md) |
| 팹리스·파운드리 | fabless / foundry | 칩 설계만 하는 회사 / 제조만 하는 회사 | [2장](02_computer_arch_arm.md) |
| 펌웨어 | firmware | 하드웨어에 밀접하게 붙어 동작하는 소프트웨어(Pi의 부트 EEPROM, `start4.elf` 등) | [1장](01_embedded_system.md), [7장](07_boot_kernel.md) |
| 페어링·본딩 | pairing / bonding | BLE에서 암호 키를 교환하는 절차 / 그 키를 저장해 다음 연결에 다시 쓰는 것 | [13장](13_ble_iot.md) |
| 폴링 | polling | 상태를 주기적으로 읽어 변화를 확인하는 방식 | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md) |
| 풀업·풀다운 저항 | pull-up / pull-down resistor | 입력이 떠 있지 않도록 High/Low 쪽으로 약하게 끌어 두는 저항 | [8장](08_gpio_pigpio.md) |
| 프로세스 | process | 실행 중인 프로그램. 자기 주소 공간과 PID를 갖는다 | [5장](05_sysadmin.md), [11장](11_process_concurrency.md) |
| 플로팅 | floating | 입력 핀이 어디에도 연결되지 않아 값이 정해지지 않은 상태 | [8장](08_gpio_pigpio.md) |
| 하드웨어 PWM | hardware PWM | PWM 주변장치가 만드는 PWM. GPIO12/13/18/19에서만 쓸 수 있고 주파수가 정확하다 | [9장](09_pigpio_advanced.md) |
| 헤더 파일 | header file (`.h`) | 함수·변수·상수의 선언을 모은 파일 | [6장](06_c_build.md) |
| 힙 | heap | 실행 중에 `malloc`으로 할당하는 메모리 영역 | [11장](11_process_concurrency.md) |

### C.6.2 약어와 영어 이름

| 용어 | 영어 | 뜻 | 장 |
|---|---|---|---|
| AAPCS | Procedure Call Standard for the Arm Architecture | ARM의 함수 호출 규약(인자·반환값 레지스터, 보존해야 할 레지스터) | [2장](02_computer_arch_arm.md) |
| AD2 | Analog Discovery 2 | Digilent의 USB 계측기(오실로스코프, 로직 분석기, 함수 발생기, 전원 등) | [10장](10_measurement.md) |
| AMBA | Advanced Microcontroller Bus Architecture | ARM의 칩 내부 버스 규격(AXI, AHB, APB) | [2장](02_computer_arch_arm.md) |
| ASLR | Address Space Layout Randomization | 실행할 때마다 스택·힙 등의 주소를 무작위로 바꾸는 보안 기능 | [11장](11_process_concurrency.md) |
| BCM 번호 | Broadcom GPIO number | SoC의 GPIO 번호. 이 책, pigpio, libgpiod, 커널이 쓰는 번호 | [8장](08_gpio_pigpio.md), [부록 B](appendix_b_gpio_libraries.md) |
| BLE | Bluetooth Low Energy | 짧은 데이터를 가끔 보내는 장치를 위한 저전력 Bluetooth | [13장](13_ble_iot.md) |
| BlueZ | — | Linux의 공식 Bluetooth 스택. `bluetoothd`가 D-Bus로 기능을 제공한다 | [13장](13_ble_iot.md) |
| `.bss` | block started by symbol | 초기값이 없거나 0으로 초기화한 전역·`static` 변수의 섹션. 파일에는 크기만 기록한다(`NOBITS`) | [6장](06_c_build.md), [11장](11_process_concurrency.md) |
| CCCD | Client Characteristic Configuration Descriptor (0x2902) | 특성의 알림(notify/indicate)을 켜고 끄는 디스크립터 | [13장](13_ble_iot.md) |
| CPOL / CPHA | clock polarity / clock phase | SPI 클록의 쉬는 레벨 / 데이터를 읽는 에지. 조합이 모드 0~3 | [12장](12_communication.md) |
| CPSR | Current Program Status Register | AArch32의 상태 레지스터(조건 플래그 NZCV, 동작 모드) | [2장](02_computer_arch_arm.md) |
| D-Bus | — | Linux의 프로세스 간 통신 버스. BlueZ가 기능을 제공하는 창구 | [13장](13_ble_iot.md) |
| `.data` | — | 0이 아닌 초기값을 가진 전역·`static` 변수의 섹션. 파일에 초기값이 들어 있다 | [6장](06_c_build.md), [11장](11_process_concurrency.md) |
| DMA | Direct Memory Access | CPU 대신 메모리 복사를 해 주는 하드웨어. pigpio의 샘플링·PWM에 쓰인다 | [9장](09_pigpio_advanced.md) |
| DRAM / SRAM | dynamic / static RAM | 커패시터에 저장해 리프레시가 필요한 주 메모리(LPDDR4) / 플립플롭으로 만든 빠른 메모리(캐시) | [2장](02_computer_arch_arm.md) |
| ELF | Executable and Linkable Format | Linux의 목적 파일·실행 파일·공유 라이브러리 형식 | [6장](06_c_build.md) |
| GATT | Generic Attribute Profile | BLE에서 데이터를 서비스·특성으로 구조화해 주고받는 규칙 | [13장](13_ble_iot.md) |
| GPIO | General Purpose Input/Output | 소프트웨어로 입력·출력을 정할 수 있는 범용 핀 | [8장](08_gpio_pigpio.md) |
| I2C | Inter-Integrated Circuit | SDA·SCL 두 선과 7비트 주소로 여러 장치를 잇는 동기 직렬 버스 | [12장](12_communication.md) |
| inode | index node | 파일의 메타데이터(권한, 크기, 데이터 위치)를 담은 구조. 파일 이름은 디렉터리 항목에 있다 | [4장](04_linux_shell.md) |
| IoT | Internet of Things | 사물이 네트워크로 데이터를 주고받는 시스템(장치 → 게이트웨이 → 클라우드) | [1장](01_embedded_system.md), [13장](13_ble_iot.md) |
| IPC | Inter-Process Communication | 프로세스 사이의 통신(파이프, 시그널, 공유 메모리, 소켓 등) | [11장](11_process_concurrency.md) |
| ISA | Instruction Set Architecture | CPU가 이해하는 명령어 집합 규격(ARMv8-A 등). 같은 ISA의 구현이 코어(Cortex-A72)이다 | [2장](02_computer_arch_arm.md) |
| libgpiod | — | GPIO 문자 장치(`/dev/gpiochipN`)를 쓰는 현재 리눅스 표준 GPIO 라이브러리·도구 | [8장](08_gpio_pigpio.md), [부록 B](appendix_b_gpio_libraries.md) |
| MCU | Microcontroller Unit | CPU·메모리·주변장치를 한 칩에 넣은 마이크로컨트롤러 | [1장](01_embedded_system.md) |
| MMU | Memory Management Unit | 가상 주소를 물리 주소로 바꾸고 접근 권한을 검사하는 하드웨어 | [11장](11_process_concurrency.md) |
| NTP | Network Time Protocol | 네트워크로 시계를 맞추는 규약. RTC가 없는 Pi 4는 이것으로 시각을 맞춘다 | [5장](05_sysadmin.md) |
| PID / PPID | Process ID / Parent PID | 프로세스 번호 / 부모 프로세스의 번호 | [5장](05_sysadmin.md), [11장](11_process_concurrency.md) |
| pigpiod | — | pigpio의 데몬. `pigs`, `pigpiod_if2`, Python 클라이언트가 소켓으로 접속한다 | [8장](08_gpio_pigpio.md) |
| PL011 / mini UART | — | Pi의 완전한 UART(`ttyAMA0`) / 코어 클록에 묶인 간이 UART(`ttyS0`) | [3장](03_rpi_hw_os.md), [13장](13_ble_iot.md) |
| PWM | Pulse Width Modulation | 주기는 그대로 두고 High 구간의 폭(듀티)을 바꾸는 신호 | [9장](09_pigpio_advanced.md) |
| RAM | Random Access Memory | 어느 주소든 접근 시간이 같은 메모리. 이름은 휘발성과 관계가 없다 | [2장](02_computer_arch_arm.md) |
| RISC / CISC | Reduced / Complex Instruction Set Computer | 단순한 고정 길이 명령어 / 복잡한 가변 길이 명령어 위주의 설계 철학 | [2장](02_computer_arch_arm.md) |
| `.rodata` / `.text` | read-only data / text | 읽기 전용 데이터(문자열 리터럴, `const` 상수) / 함수의 기계어 코드 | [6장](06_c_build.md), [11장](11_process_concurrency.md) |
| RTC | Real-Time Clock | 전원이 꺼져도 배터리로 시각을 유지하는 시계 칩. Pi 4에는 없다(DS3231, DS1302로 보탠다) | [5장](05_sysadmin.md), [12장](12_communication.md) |
| RTOS | Real-Time Operating System | 마감 시간을 지키는 것을 우선하는 운영체제(FreeRTOS 등) | [1장](01_embedded_system.md), [11장](11_process_concurrency.md) |
| SBC | Single Board Computer | 기판 한 장에 컴퓨터를 구성한 보드(Raspberry Pi) | [3장](03_rpi_hw_os.md) |
| SoC | System on a Chip | CPU·GPU·메모리 컨트롤러·주변장치를 한 칩에 넣은 것(BCM2711) | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md) |
| SPI | Serial Peripheral Interface | SCLK·MOSI·MISO·CS 네 선을 쓰는 전이중 동기 직렬 통신 | [12장](12_communication.md) |
| SSH | Secure Shell | 네트워크로 다른 컴퓨터의 셸에 암호화해 접속하는 규약 | [3장](03_rpi_hw_os.md) |
| sysfs GPIO | — | 옛 `/sys/class/gpio` 인터페이스. 최신 커널에서는 번호가 달라 쓰지 않는다 | [8장](08_gpio_pigpio.md), [부록 B](appendix_b_gpio_libraries.md) |
| systemd | — | Linux의 첫 사용자 프로세스(PID 1)이자 서비스 관리자 | [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| UART | Universal Asynchronous Receiver/Transmitter | 시작·데이터·정지 비트로 프레임을 보내는 비동기 직렬 통신 장치 | [3장](03_rpi_hw_os.md), [12장](12_communication.md) |
| UUID | Universally Unique Identifier | BLE 서비스·특성을 구별하는 16비트(표준) 또는 128비트 번호 | [13장](13_ble_iot.md) |
| VFS | Virtual File System | 여러 파일 시스템을 같은 시스템 콜로 다루게 하는 커널 계층 | [4장](04_linux_shell.md) |
| VMA / LMA | Virtual / Load Memory Address | 섹션이 실행될 때의 주소 / 저장(적재)된 주소 | [6장](06_c_build.md) |
| volatile | — | "읽기·쓰기를 생략하거나 합치지 말라"는 컴파일러 지시. 하드웨어 레지스터에 필요하지만 스레드 동기화는 아니다 | [6장](06_c_build.md), [11장](11_process_concurrency.md) |

---

## C.7 참고 자료

각 장에서 인용한 **공식 문서**(제조사·표준 단체·커널·man 페이지·프로젝트 공식 사이트와 저장소)를 주제별로 모았다. 문서의 어느 부분을 근거로 했는지는 각 장의 `📌` 표시 옆 링크를 본다. 웹 문서는 바뀔 수 있으므로, 버전이 중요한 내용(커널 브랜치, OS 이름, 라이브러리 버전)은 읽는 시점의 공식 문서로 다시 확인한다.

### C.7.1 Raspberry Pi

| 자료 | 주로 쓴 장 |
|---|---|
| [Raspberry Pi Documentation – Getting started](https://www.raspberrypi.com/documentation/computers/getting-started.html), [Raspberry Pi Imager](https://www.raspberrypi.com/software/) | [3장](03_rpi_hw_os.md) |
| [Configuration](https://www.raspberrypi.com/documentation/computers/configuration.html) (raspi-config, 네트워크, UART 설정, `cmdline.txt`, LED 깜빡임 코드, 사용자, 로그) | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md), [7장](07_boot_kernel.md), [12장](12_communication.md), [13장](13_ble_iot.md) |
| [config.txt](https://www.raspberrypi.com/documentation/computers/config_txt.html) | [3장](03_rpi_hw_os.md), [7장](07_boot_kernel.md), [12장](12_communication.md), [13장](13_ble_iot.md) |
| [Raspberry Pi hardware](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html) (GPIO와 pad, 부트 EEPROM, 부팅 순서, tryboot, SPI, 온도·클록 관리, RTC, 리비전 코드) | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md), [7장](07_boot_kernel.md), [8장](08_gpio_pigpio.md), [10장](10_measurement.md), [12장](12_communication.md) |
| [Raspberry Pi OS](https://www.raspberrypi.com/documentation/computers/os.html) (소프트웨어 업데이트, Python, `vcgencmd`, `rpi-update`) | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| [The Linux kernel](https://www.raspberrypi.com/documentation/computers/linux_kernel.html) (커널 빌드·교차 빌드·설치·헤더) | [7장](07_boot_kernel.md) |
| [Processors](https://www.raspberrypi.com/documentation/computers/processors.html) (BCM2711) | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md), [3장](03_rpi_hw_os.md) |
| [Remote access](https://www.raspberrypi.com/documentation/computers/remote-access.html), [Raspberry Pi Connect](https://www.raspberrypi.com/documentation/services/connect.html) | [3장](03_rpi_hw_os.md) |
| [BCM2711 ARM Peripherals](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf) | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md), [3장](03_rpi_hw_os.md), [9장](09_pigpio_advanced.md) |
| [Raspberry Pi 4 Model B product brief](https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-product-brief.pdf), [사양](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/specifications/) | [3장](03_rpi_hw_os.md), [13장](13_ble_iot.md) |
| [firmware: overlays README](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README) | [10장](10_measurement.md), [12장](12_communication.md) |
| [raspberrypi/linux](https://github.com/raspberrypi/linux) (커널 소스, `bcm2711.dtsi`, `bcm2711_defconfig`) | [2장](02_computer_arch_arm.md), [7장](07_boot_kernel.md) |
| [rpi-eeprom](https://github.com/raspberrypi/rpi-eeprom), [utils/pinctrl](https://github.com/raspberrypi/utils/tree/master/pinctrl), [raspi-gpio](https://github.com/RPi-Distro/raspi-gpio), [rpi-swap](https://github.com/raspberrypi/rpi-swap), [armstubs](https://github.com/raspberrypi/tools/tree/master/armstubs) | [5장](05_sysadmin.md), [7장](07_boot_kernel.md), [8장](08_gpio_pigpio.md) |
| [Raspberry Pi 뉴스](https://www.raspberrypi.com/news/) (Bookworm 발표, 새 Imager, cloud-init, 2022년 4월 기본 사용자 변경) | [3장](03_rpi_hw_os.md) |
| [Microcontrollers (Pico)](https://www.raspberrypi.com/documentation/microcontrollers/) | [1장](01_embedded_system.md), [3장](03_rpi_hw_os.md) |

### C.7.2 Arm 아키텍처

| 자료 | 주로 쓴 장 |
|---|---|
| [Arm Cortex-A72 MPCore Processor Technical Reference Manual](https://developer.arm.com/documentation/100095/latest) | [1장](01_embedded_system.md), [2장](02_computer_arch_arm.md) |
| [Arm Architecture Reference Manual for A-profile (DDI 0487)](https://developer.arm.com/documentation/ddi0487/latest), [ARMv7-A/R (DDI 0406)](https://developer.arm.com/documentation/ddi0406/latest) | [2장](02_computer_arch_arm.md) |
| Arm 학습 문서 [102412](https://developer.arm.com/documentation/102412/latest)·[102374](https://developer.arm.com/documentation/102374/latest), [AMBA AXI 규격 (IHI 0022)](https://developer.arm.com/documentation/ihi0022/latest), [AMBA](https://www.arm.com/architecture/system-architectures/amba) | [2장](02_computer_arch_arm.md) |
| [Cortex-M3 Devices Generic User Guide (DUI 0552)](https://developer.arm.com/documentation/dui0552/latest) | [2장](02_computer_arch_arm.md) |
| [AAPCS32](https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst), [AAPCS64](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst) | [2장](02_computer_arch_arm.md) |

### C.7.3 Linux 커널과 표준

| 자료 | 주로 쓴 장 |
|---|---|
| [The kernel's command-line parameters](https://docs.kernel.org/admin-guide/kernel-parameters.html) | [3장](03_rpi_hw_os.md), [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| [Booting AArch64 Linux](https://docs.kernel.org/arch/arm64/booting.html), [ramfs·rootfs·initramfs](https://docs.kernel.org/filesystems/ramfs-rootfs-initramfs.html), [Kconfig](https://docs.kernel.org/kbuild/kconfig.html), [외부 모듈 빌드](https://docs.kernel.org/kbuild/modules.html), [Device Tree usage model](https://docs.kernel.org/devicetree/usage-model.html), [Devicetree Specification](https://www.devicetree.org/specifications/) | [2장](02_computer_arch_arm.md), [7장](07_boot_kernel.md) |
| [GPIO character device](https://docs.kernel.org/userspace-api/gpio/chardev.html), [GPIO sysfs (deprecated)](https://docs.kernel.org/userspace-api/gpio/sysfs.html) | [8장](08_gpio_pigpio.md), [9장](09_pigpio_advanced.md), [부록 B](appendix_b_gpio_libraries.md) |
| [I2C dev-interface](https://docs.kernel.org/i2c/dev-interface.html), [SPI summary](https://docs.kernel.org/spi/spi-summary.html), [spidev](https://docs.kernel.org/spi/spidev.html), [i2c-tools (i2cdetect 소스)](https://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git/tree/tools/i2cdetect.c) | [10장](10_measurement.md), [12장](12_communication.md) |
| [CFS 스케줄러](https://docs.kernel.org/scheduler/sched-design-CFS.html), [EEVDF](https://docs.kernel.org/scheduler/sched-eevdf.html), [메모리 관리 개념](https://docs.kernel.org/admin-guide/mm/concepts.html), [실시간(PREEMPT_RT)](https://docs.kernel.org/core-api/real-time/index.html) | [7장](07_boot_kernel.md), [11장](11_process_concurrency.md) |
| [/proc 파일 시스템](https://docs.kernel.org/filesystems/proc.html), [serial console](https://docs.kernel.org/admin-guide/serial-console.html), [커널 릴리스](https://www.kernel.org/category/releases.html) | [2장](02_computer_arch_arm.md), [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| [man7.org Linux man-pages](https://man7.org/linux/man-pages/) (`chmod`, `ln`, `syscall`, `inode`, `fork`, `pthread_create`, `pthreads`, `sem_overview`, `sched`, `chrt`, `proc_pid_maps`, `elf`, `ld.so`, `ldd`, `ldconfig`) | [4장](04_linux_shell.md), [6장](06_c_build.md), [11장](11_process_concurrency.md) |
| Debian bookworm man pages: [`apt`](https://manpages.debian.org/bookworm/apt/apt.8.en.html), [`sources.list`](https://manpages.debian.org/bookworm/apt/sources.list.5.en.html), [`sudoers`](https://manpages.debian.org/bookworm/sudo/sudoers.5.en.html), [`crontab`](https://manpages.debian.org/bookworm/cron/crontab.5.en.html), [`bash`](https://manpages.debian.org/bookworm/bash/bash.1.en.html), [`adduser.conf`](https://manpages.debian.org/bookworm/adduser/adduser.conf.5.en.html) | [5장](05_sysadmin.md) |
| [FHS 3.0](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html), [ELF gABI](https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html), [POSIX `pthread_cond_wait`](https://pubs.opengroup.org/onlinepubs/9799919799/functions/pthread_cond_wait.html), [C11 초안 N1570](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf) | [4장](04_linux_shell.md), [6장](06_c_build.md), [11장](11_process_concurrency.md) |
| [systemd man pages](https://www.freedesktop.org/software/systemd/man/latest/) (`systemctl`, `systemd.unit`, `systemd.service`, `systemd.exec`, `systemd.timer`, `journald.conf`, `timedatectl`, `systemd-analyze`, `bootup`) | [5장](05_sysadmin.md), [7장](07_boot_kernel.md) |
| [Debian 12 릴리스 노트](https://www.debian.org/releases/bookworm/arm64/release-notes/ch-information.en.html), [UsrMerge](https://wiki.debian.org/UsrMerge), [PEP 668 (externally-managed-environment)](https://peps.python.org/pep-0668/) | [4장](04_linux_shell.md), [5장](05_sysadmin.md) |
| [NetworkManager `nmcli`](https://networkmanager.dev/docs/api/latest/nmcli.html) | [3장](03_rpi_hw_os.md) |

### C.7.4 개발 도구

| 자료 | 주로 쓴 장 |
|---|---|
| [GCC 매뉴얼](https://gcc.gnu.org/onlinedocs/gcc/) (옵션, 경고, 최적화, `volatile`, 원자적 내장 함수, 계측), [GCC 14 porting guide](https://gcc.gnu.org/gcc-14/porting_to.html), [GCC 10 changes](https://gcc.gnu.org/gcc-10/changes.html) | [2장](02_computer_arch_arm.md), [6장](06_c_build.md), [11장](11_process_concurrency.md) |
| [GNU binutils](https://sourceware.org/binutils/docs/binutils/), [GNU ld (링커 스크립트, MEMORY, LMA)](https://sourceware.org/binutils/docs/ld/Options.html), [GDB 매뉴얼](https://sourceware.org/gdb/current/onlinedocs/gdb.html/) | [6장](06_c_build.md) |
| [GNU make 매뉴얼](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html) (자동 변수, 패턴 규칙, 레시피 문법) | [6장](06_c_build.md) |
| [Git 공식 문서](https://git-scm.com/docs/git-config), [Pro Git (한국어)](https://git-scm.com/book/ko/v2), [gitattributes `eol`](https://git-scm.com/docs/gitattributes#_eol) | [6장](06_c_build.md) |
| [VS Code Remote - SSH](https://code.visualstudio.com/docs/remote/ssh), [tasks](https://code.visualstudio.com/docs/editor/tasks), [launch.json](https://code.visualstudio.com/docs/cpp/launch-json-reference), [VS Code on Raspberry Pi](https://code.visualstudio.com/docs/setup/raspberry-pi) | [6장](06_c_build.md) |
| [WSL 설치](https://learn.microsoft.com/en-us/windows/wsl/install), [WSL 파일 시스템](https://learn.microsoft.com/en-us/windows/wsl/filesystems) | [7장](07_boot_kernel.md) |
| [Valgrind quick start](https://valgrind.org/docs/manual/quick-start.html), [ShellCheck](https://www.shellcheck.net/) | [4장](04_linux_shell.md), [11장](11_process_concurrency.md) |

### C.7.5 GPIO 라이브러리

| 자료 | 주로 쓴 장 |
|---|---|
| [pigpio library](https://abyz.me.uk/rpi/pigpio/) — [C 함수(cif)](https://abyz.me.uk/rpi/pigpio/cif.html), [pigs](https://abyz.me.uk/rpi/pigpio/pigs.html), [pigpiod](https://abyz.me.uk/rpi/pigpio/pigpiod.html), [FAQ](https://abyz.me.uk/rpi/pigpio/faq.html), [저장소](https://github.com/joan2937/pigpio) | [8장](08_gpio_pigpio.md)~[12장](12_communication.md), [부록 B](appendix_b_gpio_libraries.md) |
| [libgpiod](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/) | [8장](08_gpio_pigpio.md), [부록 B](appendix_b_gpio_libraries.md) |
| [gpiozero pins](https://gpiozero.readthedocs.io/en/stable/api_pins.html), [RPi.GPIO](https://pypi.org/project/RPi.GPIO/), [rpi-lgpio](https://rpi-lgpio.readthedocs.io/), [lg](https://github.com/joan2937/lg) | [부록 B](appendix_b_gpio_libraries.md) |
| [WiringPi (커뮤니티 저장소)](https://github.com/WiringPi/WiringPi), [원작자의 지원 종료 공지(보관본)](https://web.archive.org/web/2020/http://wiringpi.com/wiringpi-deprecated/) | [부록 B](appendix_b_gpio_libraries.md) |

### C.7.6 계측

| 자료 | 주로 쓴 장 |
|---|---|
| [Analog Discovery 2 Reference Manual](https://digilent.com/reference/test-and-measurement/analog-discovery-2/reference-manual), [사양](https://digilent.com/reference/test-and-measurement/analog-discovery-2/specifications), [시작 가이드](https://digilent.com/reference/test-and-measurement/analog-discovery-2/getting-started-guide) | [10장](10_measurement.md) |
| [WaveForms Reference Manual](https://digilent.com/reference/software/waveforms/waveforms-3/start), WaveForms 계측기별 가이드([Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope), [Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer), [Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer), [Static I/O](https://digilent.com/reference/test-and-measurement/guides/waveforms-static-io)), [Raspberry Pi와 함께 쓰기](https://digilent.com/reference/test-and-measurement/guides/getting-started-with-raspberry-pi) | [10장](10_measurement.md) |

### C.7.7 통신 규격과 데이터시트

| 자료 | 주로 쓴 장 |
|---|---|
| [NXP UM10204 I2C-bus specification](https://www.nxp.com/docs/en/user-guide/UM10204.pdf), [AN10441 레벨 시프팅](https://www.nxp.com/docs/en/application-note/AN10441.pdf), [PCA9306](https://www.nxp.com/docs/en/data-sheet/PCA9306.pdf), [PCF8574](https://www.nxp.com/docs/en/data-sheet/PCF8574_PCF8574A.pdf) | [10장](10_measurement.md), [12장](12_communication.md) |
| [DS3231](https://www.analog.com/media/en/technical-documentation/data-sheets/DS3231.pdf), [DS1302](https://www.analog.com/media/en/technical-documentation/data-sheets/DS1302.pdf), [ADXL345](https://www.analog.com/media/en/technical-documentation/data-sheets/adxl345.pdf) (Analog Devices) | [12장](12_communication.md) |
| [MCP3008](https://ww1.microchip.com/downloads/en/DeviceDoc/21295d.pdf) (Microchip), [BMP280](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmp280-ds001.pdf) (Bosch Sensortec) | [12장](12_communication.md) |
| [Arduino Wire 라이브러리](https://docs.arduino.cc/language-reference/en/functions/communication/wire/) | [12장](12_communication.md) |

### C.7.8 Bluetooth와 IoT

| 자료 | 주로 쓴 장 |
|---|---|
| [Bluetooth Core Specification](https://www.bluetooth.com/specifications/specs/core-specification/), [Health Thermometer Service 1.0](https://www.bluetooth.com/specifications/specs/health-thermometer-service-1-0/), [Assigned Numbers](https://www.bluetooth.com/specifications/assigned-numbers/), [GATT Specification Supplement](https://btprodspecificationrefs.blob.core.windows.net/gatt-specification-supplement/GATT_Specification_Supplement.pdf), [Bluetooth 기술 개요](https://www.bluetooth.com/learn-about-bluetooth/tech-overview/), [보안](https://www.bluetooth.com/learn-about-bluetooth/key-attributes/bluetooth-security/) | [13장](13_ble_iot.md) |
| [BlueZ](https://github.com/bluez/bluez), [BlueZ D-Bus API 문서](https://github.com/bluez/bluez/tree/master/doc) | [13장](13_ble_iot.md) |
| [bleak 문서](https://bleak.readthedocs.io/en/latest/usage.html) ([문제 해결](https://bleak.readthedocs.io/en/latest/troubleshooting.html), [BlueZ 백엔드](https://bleak.readthedocs.io/en/latest/backends/linux.html), [변경 이력](https://bleak.readthedocs.io/en/latest/history.html)), [bleak PyPI](https://pypi.org/project/bleak/) | [13장](13_ble_iot.md) |
| Python 표준 라이브러리: [asyncio](https://docs.python.org/3/library/asyncio.html), [sqlite3](https://docs.python.org/3/library/sqlite3.html), [csv](https://docs.python.org/3/library/csv.html), [urllib.request](https://docs.python.org/3/library/urllib.request.html); [SQLite – When to use](https://www.sqlite.org/whentouse.html) | [13장](13_ble_iot.md) |
| [Renesas DA14583](https://www.renesas.com/en/products/da14583), [Nordic nRF Connect for Mobile](https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-mobile) | [13장](13_ble_iot.md) |
| [Connectivity Standards Alliance (Zigbee)](https://csa-iot.org/), [LoRa Alliance](https://lora-alliance.org/about-lorawan/), [Wi-Fi Alliance](https://www.wi-fi.org/) | [13장](13_ble_iot.md) |
| AWS 문서: [API Gateway 접근 제어](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-control-access-to-api.html), [Lambda 환경 변수](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html), [RDS 보안 그룹](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html) | [13장](13_ble_iot.md) |

### C.7.9 부팅·임베디드 Linux 일반

| 자료 | 주로 쓴 장 |
|---|---|
| [UEFI 규격](https://uefi.org/specifications), [GNU GRUB 매뉴얼](https://www.gnu.org/software/grub/manual/grub/), [U-Boot](https://docs.u-boot.org/en/latest/) ([Raspberry Pi](https://docs.u-boot.org/en/latest/board/broadcom/raspberrypi.html)), [coreboot](https://doc.coreboot.org/), [SeaBIOS](https://www.seabios.org/), [EDK II](https://github.com/tianocore/edk2), [OpenSBI](https://github.com/riscv-software-src/opensbi), [RFC 1350 (TFTP)](https://www.rfc-editor.org/rfc/rfc1350) | [7장](07_boot_kernel.md) |
| [Buildroot 매뉴얼](https://buildroot.org/downloads/manual/manual.html), [Yocto Project](https://www.yoctoproject.org/) | [7장](07_boot_kernel.md) |
| [Linux Foundation Real-Time Linux](https://wiki.linuxfoundation.org/realtime/start) | [1장](01_embedded_system.md) |

### C.7.10 MATLAB/Simulink

| 자료 | 주로 쓴 장 |
|---|---|
| [Simulink Support Package for Raspberry Pi Hardware](https://www.mathworks.com/help/raspberrypi/index.html) (Hardware Setup, 제품 구성, 릴리스별 호환표, Simulink 작업 흐름, MATLAB 함수 배포), [Raspberry Pi 하드웨어 지원](https://www.mathworks.com/hardware-support/raspberry-pi.html) | [부록 A](appendix_a_matlab_simulink.md) |
| [MATLAB Support Package for Raspberry Pi (`configurePin`, I2C, SPI, 카메라)](https://www.mathworks.com/help/releases/R2025b/matlab/supportpkg/raspberrypiio.configurepin.html) | [부록 A](appendix_a_matlab_simulink.md) |
| [Model-Based Design](https://www.mathworks.com/solutions/model-based-design.html), [SIL/PIL](https://www.mathworks.com/help/ecoder/ug/about-sil-and-pil-simulations.html), [HIL](https://www.mathworks.com/discovery/hardware-in-the-loop-hil.html), [Stateflow 시간 논리](https://www.mathworks.com/help/stateflow/ug/using-temporal-logic-in-state-actions-and-transitions.html), [`fir1`](https://www.mathworks.com/help/signal/ref/fir1.html), [`butter`](https://www.mathworks.com/help/signal/ref/butter.html) | [부록 A](appendix_a_matlab_simulink.md) |

### C.7.11 강의 자료 (공식 문서가 아닌 수업 자료)

| 자료 | 장 |
|---|---|
| 「BLE 바나나 체온계를 활용한 IoT 따라잡기」 GitBook: <https://lstgrp.gitbook.io/banana-thermometer> (저장소의 [`../TS100/Gitbook`](../TS100/Gitbook)) | [13장](13_ble_iot.md) |
| 강의 예제 저장소: <https://github.com/sckim/Lectures>, <https://github.com/sckim/Embedded_System> | [6장](06_c_build.md), [머리말](00_preface.md) |
| 이 책의 예제 코드: [`code/`](code/) | 전체 |

---

## 정리

- **C.1**은 명령을, **C.2**는 pigpio 함수와 `pigs` 명령을, **C.3**은 `config.txt`·`cmdline.txt`·systemd 유닛·Makefile의 설정 이름을 한 줄씩 요약했다. 처음 쓰는 명령·함수·설정이라면 "다루는 장"으로 가서 원리를 먼저 읽는다.
- **C.4**는 책 전체의 **표준 핀 계획**을 BCM 번호 순으로 정리했다. 한 핀은 한 역할만 맡고(LED0 = GPIO17 (물리 핀 11), BTN0 = GPIO26 (물리 핀 37), PWM = GPIO18, 서보 = GPIO13, HC-SR04 = GPIO20/21, DS1302 = GPIO12/19/16 등), 5 V 장치는 레벨 시프터(LV1/LV2 = I2C, LV3/LV4 = HC-SR04)를 거친다. 배선을 바꾸는 것은 ⚠ 핀 예외 세 가지뿐이고, 옛 자료의 핀은 C.4.2의 표로 바꿔 읽는다.
- **C.5**의 오류 모음은 메시지 문구로 찾는다. 가장 자주 만나는 오류는 `Can't lock /var/run/pigpio.pid`(pigpiod와 방식 A 프로그램의 충돌), CRLF 줄 끝, 링크 순서·`-l` 누락, 3.3 V/5 V 전압 문제이다.
- **C.6** 용어집과 **C.7** 참고 자료는 시험 공부와 보고서 작성 때 출처를 확인하는 출발점이다. 보고서에 인용할 때는 블로그나 백과사전보다 이 목록의 공식 문서를 쓴다.
