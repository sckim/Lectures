# 보완 목록 (TODO)

## 자료
- [ ] 강의계획서(2025) 12주차에 링크된 「메모리 구조」 슬라이드(17F8yPVn…) 원본 미확인 — 찾으면 11장에 반영 (2026-10-02 사용자 결정: 일단 스킵)
- [ ] 2024 전사 0바이트 파일 2개: `0911_1학기 복습 II`, `0911_Atmega328P Datasheet 읽기` (AVR 범위라 교재 영향 없음)
- [ ] 2025 8주차(중간고사) 녹취 없음

## 실기기(Pi 4) 캡처 1차 (2026-10-06, 하드웨어 미연결)
Pi 4 Model B Rev 1.5(2 GB), Bookworm, 커널 `6.12.58-v8+`(rpi-update), 한국어 로캘. 라벨 `> 출력 출처: Pi 4 실기기 실행 결과(2026-10)`(서문 표에 추가). 원고 PI-CHECK 표지 125곳 → 44곳(서문 범례 1곳 제외 43곳; 10-06 재부팅 후 7장 부팅 출력 재캡처·vermagic·valgrind 완료).
- [x] 1–8, 10, 11장 및 12장 12.3.2, 13장 실습 13-0·D-Bus 정책: 캡처 또는 본문 정정 완료(정정 예: 최대 클록 1800 MHz, 2 GB iomem, `유선 연결 1`, pigpiod `[::1]:8888`, vcgencmd 100 MHz 단계, `pigs padg 0`=16, `futex_wait_queue`, Bookworm은 `bluetooth` 그룹 불필요·`/dev/serial1` 없음, Pi 4 btmon은 legacy LE 스캔)
- [x] `code/ch13/bt_check.sh`·`gateway.service` 안내 문구를 Bookworm 기준으로 수정(+ rfkill PATH)
- [ ] 하드웨어 필요: 5장 blink.service(LED), USB `dmesg`·`lsblk -f`(USB 메모리), 9장 debounce_test, 11장 semaphore_led LED 동작·지터 표 AD2 열, 12장 uart_loopback(점퍼)·uart_cmd(PC 터미널)·i2c_scan(0x27)·DS3231·MCP3008·DS1302·BMP280, 13장 TS100 관련 9곳·btmon TS100 부분
- [ ] 설정 변경/재부팅/시리얼 콘솔 필요: 3장 UART 부팅 화면, 3장 serial0→ttyAMA0(disable-bt), 7장 I2C 전후 표, 7장 GPIO26 듀얼부팅·Buildroot DTB, 13장 `uart_2ndstage` 진단 출력(→ 13장 요약 "펌웨어 진단 출력은 사라진다" 문장도 함께 확인)
- [x] 7장 vermagic: 6.12.47+rpt-rpi-v8 헤더로 빌드만 해서 modinfo 캡처(insmod dmesg 예시는 표지 유지)
- [x] 11장 valgrind 3.19.0 설치·실행 결과 반영
- [ ] 6장 실습 6-7 Remote-SSH 화면·sudo-gdb.sh, 부록 A MATLAB 10곳
- [ ] Pi 자체 정리(사용자 판단): cmdline.txt 디버그 옵션(`initcall_debug`, 오타 `prinkt.time=1`), 디스크 97%, 시간대 Asia/Tokyo, NetworkManager-wait-online 60 s 타임아웃

## 실기기(Pi 4, Bookworm) 검증 필요
- [ ] 8장: sysfs base 512 오프셋, `gpiodetect`/`gpioinfo`/`pinctrl get` 출력 형식, `systemctl status pigpiod` 기본 상태, `gpioset --version`(1.6.x), `make` 링크 및 실습 8-1~8-6 실행, if2 명령 지연 측정
- [ ] 4장: 본문 출력은 WSL Debian 12(x86-64, bash 5.2.15)에서 확인함. Pi에서 "Pi 4에서 예상되는 형태"로 표시한 출력 교체 필요 — `ls /`, `ls -l /dev/mmcblk0* /dev/serial0 /dev/gpiochip0 /dev/i2c-1`, `cat /proc/version`, `id`(그룹 목록), `echo $PATH`, `file /bin/ls`(aarch64), `vi` → `vim.tiny` 여부, `compgen -b | wc -l`(61), CRLF 셔뱅 오류 메시지(bash 5.2: `cannot execute: required file not found`), `ls -l /usr/bin/bash /usr/bin/dash` 크기, 한국어 로캘 `type` 메시지. 스크립트 9개(`code/ch04/*.sh`) Pi에서 재실행
- [ ] 부록 B: `gpioSetISRFunc`가 6.x 커널에서 동작하는지(PI_BAD_ISR_INIT 예상), DHT11/RHT03 실센서, GPIO12 gpioPWM + GPIO18 HW PWM 동시 동작, softTone DMA 주파수, `/dev/serial0` 루프백, semaphore 종료 처리, `readall_pigpio` vs `pinctrl -p`, speed 측정값(현재 빈칸)
- [ ] 2장: 실습 2-1 `lscpu`/`/proc/cpuinfo`/`cache_info.sh`/`getconf` 출력, 실습 2-3 Pi 기본 gcc의 `make asm`·`make dis` 결과가 교차 컴파일 결과(gcc 12.2.0-14)와 같은지, 실습 2-4 `sudo cat /proc/iomem`(gpio@7e200000 → fe200000 범위)과 `od /proc/device-tree/soc/ranges`, `dmesg | grep -i EL2`

- [ ] 5장: `/dev/gpiomem·gpiochip0·i2c-1·spidev0.0·ttyAMA0·vchiq` 그룹/major·udev 규칙명, vcgencmd 사용 장치(vcio/vchiq), sources.list·raspi.list 내용, `pstree -p`/`top`/`lsblk -f`/`fdisk -l`/`/etc/fstab`/`ss -tulpn`(pigpiod 127.0.0.1:8888?)/`timedatectl`/USB `dmesg`, `measure_clock arm` 번호, `dmesg_restrict`, /var/log/journal·rsyslog, raspi-config A12 Logging, dphys-swapfile CONF_SWAPSIZE, psmisc·htop 기본 설치, sudoers.d NOPASSWD, fake-hwclock, fstab 오류 시 응급모드, `init=/bin/sh` UART, blink.service 동작, 실습 5-1·5-3 실행 (본문 `<!-- 예시 출력 -->` 13곳)

- [ ] 7장: 커스텀 커널 부팅·`--tryboot`·`--rollback`, `vclog --msg`, `/proc/device-tree/chosen/bootargs`, serial0→ttyAMA0/ttyS0, dmesg(`started at EL2`, `Run /init`, `VFS: Mounted root`), 실습 7-2 I2C 전후, `boot_report.sh`, Pi 네이티브 hello 모듈 빌드, UART 펌웨어 로그, systemd-analyze 수치, GPIO2 듀얼부팅·Buildroot DTB — 본문 "(예시, 하드웨어 확인 필요)" 캡처 교체; 그림 2곳(메모리 리매핑, 다운로드/JTAG)

- [ ] 6장: `gcc -dumpmachine`, hello 크기(70432B)·`size`/`readelf`, 실습 6-4 크기 증가량, `ldd` 경로, opt_demo·calculate_pi Pi 실행 시간, `sudo ldconfig`, `sudo -n true`, `sudo-gdb.sh` VS Code 동작, gdb Pi 출력, led_blink 강제 종료 후 pid 파일, 실습 6-7 전체(Remote-SSH 캡처), gnu.org make 매뉴얼 링크 5개 재확인

- [ ] 10장: AD2 flywire 색 표(공식 텍스트 없음), BNC 어댑터 커플링 점퍼 번호, WaveForms 메뉴명(PosDuty/RiseTime, Attenuation, 보정 위치), `toggle_shell.sh` sysfs 모드, pad 16mA 설정, `spiOpen`+`dtparam=spi=on` 공존, `/dev/serial0` 9600 baud, i2cdetect 프로브 범위 kernel.org 원본 재확인, 스크린샷 약 15곳
- [x] 8장 "기본 4mA" vs 실제 pad 값(8mA 가능성) — `pad_strength`로 확인 후 8장·sources.md 정정 (2026-10-05: 공식 문서 기준으로 정리. PADS 리셋 DRIVE=3, Pi 4는 표의 절반 → 기본 4 mA·최대 8 mA. pigpio `padg`는 BCM2835 눈금(값×2+2)이라 8로 표시. Pi 4 Datasheet R1.1 표 3은 8/16 mA로 달라 8장 상자·10장 실습 10-2에 함께 적음. sources.md 문구는 유지 가능 — 실측 `pigs padg 0`은 PI-CHECK로 남김)

- [ ] 9장: `gpioSetISRFunc`가 6.x 커널에서 -123 반환하는지, 9-1 `top` CPU%, 키트 서보 펄스 범위, HC-SR04 모델(3.3V 동작 여부), 하드웨어 PWM과 헤드폰 오디오 간섭, `pinctrl get 18`(HW PWM 중), Mermaid 렌더 확인, 9-2 debounce 출력 실측으로 교체; 출처 보완: 감마 2.2, HC-SR04 타이밍, 서보 스톨 전류·커패시터, MOSFET·플라이백 다이오드 데이터시트

- [ ] 11장: `memory_layout`/`size` 출력, PAGESIZE, 39비트 VA 여부, zombie orphan PPID, `uname -r`(EEVDF), deadlock wchan, shared_counter 표, Pi gcc 12.2 `make asm`, cpuinfo `atomics` 유무, TSan·valgrind 동작, 실습 11-6·11-7 출력, 11-8 표·AD2 캡처, gdb `thread apply all bt` 캡처 (본문 `<!-- TODO(Pi 확인) -->` 13곳)

- [ ] 13장: 예시 출력 실캡처 교체(bt_check.sh, bluetoothctl, btmon, scan/read_temp/logger, BlueZ·btmgmt 버전), Bookworm `hciuart.service`·bluetooth 그룹·D-Bus 정책, 실제 TS100의 0x2A1C notify/indicate·Flags·서비스·페어링(PIN), `gateway.service` User= 로 BlueZ 접근·2대 동시 연결, uart.adoc의 core_freq/uart_2ndstage 재확인, Core Spec FLOAT 절 직접 확인, 시뮬레이터 펌웨어 수정(tempData[0]=0x02, lroundf), raspberrypi.com·csa-iot.org 링크

- [ ] 12장: 실습 12-1~12-7 예시 출력, `i2c_scan`, 12.3.2 `pinctrl`/`ls`, LCD 'H' 바이트 AD2 캡처, DS1302 burst read(0xBF)와 새 핀 GPIO12/19/16, `ds1302_rtc raw`, `i2cReadI2CBlockData` repeated START 여부, BCM2711 I2C clock stretching, 데이터시트 수치 재확인(PCF8574 V_IH, DS1302 타이밍, DS3231, MCP3008, UM10204), Pi 4 GPIO2/3 풀업 1.8kΩ(RP-008345-DS), 배선 사진·AD2 캡처 추가

- [ ] 부록 A: 모든 .m 파일과 A-4·A-5 단계를 실제 MATLAB+Pi에서 실행(이 PC의 R2026a는 -batch 실행이 라이선스 단계에서 멈춤), 그림 필요 자리 캡처, fir1/butter 계수 vs C 출력, 유한 Stop time 시 배포 앱 종료 여부, GPIO Read 블록 풀업 옵션, ProdHWDeviceType 설정, persistent zi codegen, `_data.c` 생성 여부, filter_demo Pi 실행, A-2 호출 지연, raspberryPiResourceMonitor/raspisetup, Bookworm 호환 표 재확인, SPI·카메라 문서 링크
- 2026-10-05 정리 작업 추가 발견:
  - 12장 Pi 4 GPIO2/3 풀업 1.8 kΩ: Raspberry Pi 공식 문서는 "fixed pull-up"만 적고 값은 없음. Pi 4 reduced schematic(공개판)에도 이 저항이 그려져 있지 않음(1K8은 오디오·전원 회로뿐). 값의 근거는 pigpio 문서("1k8")뿐 — 공식 출처 미확보
  - 9장 출처 보완: HC-SR04는 Elecfreaks 사양서(SparkFun 사본)로 보강함(10 μs 트리거, 40 kHz 8주기, 2–400 cm, μs/58, 60 ms 주기). 남은 태그: 감마 2.2, 서보 내부 구조·스톨 전류·커패시터, 무반사 시 긴 ECHO·음속 근사식, 3.3 V 트리거 수용. MOSFET·플라이백은 Nexperia AN50020 6.1절로 출처 추가. 서보는 Parallax Standard Servo 문서(900-00005 v2.2/v3.0)가 후보 출처(미확인)
  - 7장 7.12.4: BCM2711 리셋 풀(GPIO0–8 풀업, 9–27 풀다운)은 BCM2711 ARM Peripherals 5.3절 표 94로 확인. `gpio=`가 `[gpioN=0]` 필터 평가 전에 실제 핀에 적용되는지는 공식 문서에 없음(문서는 "적힌 순서대로 적용", "전원 후 몇 초 뒤 적용"만 언급) → 📌 출처 보완 + PI-CHECK 유지
  - 13장·3장: Bookworm 기본 `krnbt=on`이면 커널이 Bluetooth 드라이버를 직접 붙이고 `/dev/serial1`이 없을 수 있음(공식 문서·overlays README). `hciuart.service`는 `WantedBy=dev-serial1.device`라 실행 안 될 수 있음 → 본문 수정. bt_check.sh 예시 출력(serial1 → ttyAMA0, hciuart active)과 `bt_enable.sh`의 `enable hciuart`는 실기기 확인 후 교체/정리 필요(PI-CHECK)
  - 13장: `enable_uart=1`이 있으면 펌웨어가 코어 클록을 250 MHz로 고정(공식 문서 표) → "core_freq=250 추가" 안내를 13장·3장·부록 C에서 고침. `uart_2ndstage` 출력이 어느 UART로 나가는지는 문서에 없음 → 📌 확인 필요 + PI-CHECK
  - 10장 AD3 사양(125 MS/s, 30+ MHz BNC/9 MHz 플라이와이어, ±25 V/±2.5 V, 32k 버퍼, Wavegen 12 MHz, DIO 16채널 4–16 mA, 전원 800 mA/2.4 W AUX, USB-C)과 AD2 사양은 Digilent 사양 페이지와 일치 확인. 플라이와이어 색은 공식 페이지에 텍스트 없음(Pinout은 그림, Flywire Labels Sticker Sheet만 있음) → 미해결
  - Mermaid: 교재 전체 100개 블록을 @mermaid-js/mermaid-cli 12.0.0(mermaid 12.1.0)으로 렌더링 — 100개 모두 성공(9장 항목의 "Mermaid 렌더 확인" 포함). 출력 출처 라벨 수: 실기기 확인 필요 지점은 `grep -c PI-CHECK`로 집계
  - 6장 gnu.org make 매뉴얼 링크 7개 + thegnuproject: 2026-10-05에 gnu.org 접속 거부(ECONNREFUSED, 브라우저·WebFetch 모두). Wayback CDX에 2026-07~09 HTTP 200 캡처가 있어 페이지는 존재함. 직접 접속 재확인은 미완

## 결정 필요
- [x] (전용 사본으로 결정) 11장 semaphore 예제: `code/appendix_b/semaphore_led_pigpio.c`를 링크할지, 11장 전용 사본을 둘지
- [ ] 8장 과제 8-3의 답이 `appendix_b/pullupdown_pigpio.c`와 거의 같음 → 유지/교수용 분리
- [ ] 3장: `uart_2ndstage` MESS: 로그·커널 부팅 로그, `ls -l /dev/serial*`(disable-bt 후), `/proc/cmdline`, 로그인 프롬프트 IP 표시, `ip addr/route`, `nmcli`, `lsblk`, SSH 프롬프트, `sysinfo.sh` 출력(Rev1.5 최대 1800MHz), Imager에서 Bookworm 항목 이름(Trixie 기본 이후), Imager 2.0의 firstrun/cloud-init, `hciuart.service` 존재, raspi-config Wayland 메뉴, xrdp+Wayland 동작 — 본문 `<!-- 예시 출력: 실기기 캡처로 교체 필요 -->` 위치를 실캡처로 교체
- [ ] 4장 4.2.4 연표 출처 확인 — Ritchie 논문(bell-labs.com/usr/dmr 410, nokia.com 403), GNU 발표문(429), Raspberry Pi 2020-05 블로그(접속 실패)를 집필 시 확인하지 못함. Debian 6부터 `/bin/sh`=dash, bash 5.2의 CRLF 오류 메시지 변경 시점도 미확인
- [ ] 3장 보강 출처 링크(raspberrypi.com) 접속 확인 — 집필 시 사이트 접속 실패로 검색 요약으로만 확인함

## 결정 필요 (추가)
- [x] 블루투스: 3장 유지, 13장에서 되돌리기 안내 (사용자 결정)
- [ ] 5장: blink.service(5.5.8 심화) 위치 — 5장 유지 vs 8/9장 이동
- [ ] 5장 과제 5-3-4(부하 10분 온도 실험) — 방열판 없는 Pi 부담, 유지 여부
- [ ] 4장 과제 4-1-2(nobody /tmp)와 5장 과제 5-1(guest 홈) 유사 — 4-1-2 삭제 고려
- [x] (Bookworm 유지: 2025 수업 기록이 Bookworm 6.12.x) 교재 기준 OS: Bookworm 유지 vs Trixie(공식 문서는 이미 Trixie 기준)
- [ ] 7장 커널 브랜치: rpi-6.12.y 고정 vs `uname -r` 계열 원칙(기본 브랜치는 rpi-6.18.y)
- [ ] 7장 과제 7-2(학번 LOCALVERSION 커널) 필수/선택
- [ ] 6장 `code/ch06/.gitignore`의 `!.vscode/` — 루트 .gitignore(.vscode 제외, b581e06) 정책 예외 승인 여부
- [ ] 6장 `sudo-gdb.sh` 실행 비트(`git update-index --chmod=+x`) 기록 여부
- [ ] 8장 Makefile에 `LDFLAGS` 변수 추가(교차 컴파일 예시용)
- [ ] 10장 AD2 DIO 배선: 워크스페이스 파일 기준(DIO0↔GPIO17, DIO1↔GPIO18, DIO2↔GPIO26, I2C SCL DIO14/SDA DIO15) vs 2025 강의 배선(GPIO17↔DIO7, GPIO18↔DIO6, I2C DIO0/1) vs 2024 강의(DIO14=SDA) — 실습 키트 표준 결정
- [ ] 13장: TS100 시뮬레이터 펌웨어를 code/ch13에 복사할지(현재 ../TS100/firmware 링크)
- [ ] 13장: TS100-Gitbook 원문 정정(BLE/Classic 비교표, DA14583 사양, Date Time UUID 오타, 디코더 부호확장)을 GitBook에도 반영할지
- [ ] 보안: `TS100/python/main_cloud.py`(및 `TS100/firmware/main_cloud.py`)에 실제 AWS API Gateway invoke URL 하드코딩 — 저장소에서 제거/교체할지
- [ ] 장별 `.gitignore`(code/ch06, code/ch13) 유지 vs 루트 통합
- [x] (레벨 시프터 사용으로 결정) 실습 키트: BSS138 양방향 I2C 레벨 시프터 추가 여부(12-3 LCD 실습에 필요), DS3231 모듈 종류(EEPROM 0x57), BMP280/BME280, MCP3008+가변저항 보유 여부
- [ ] DS1302 핀: 강의 GPIO9/10/11 → 교재 GPIO12/19/16으로 변경. Codes 문서·슬라이드도 맞출지
- [ ] 보안: `RaspberryPi/Simulink/raspberrypi_doc.mlx`(실습 Pi 비밀번호·IP·사용자명 평문), `*.slx` 3개(IP·사용자명, untitled.slx는 비밀번호) — 학생 배포 전 정리 및 비밀번호 변경
- [ ] Simulink 모델 핀을 교재 배선(LED GPIO17, 버튼 GPIO26)으로 다시 저장할지 (untitled.slx는 현재 GPIO27)
- [x] (2026-10-03 결정: 표준 핀 계획으로 통일, sources.md 참조 — 반영 진행) 핀 계획 통일: GPIO22(부록B 버튼·11장 LED·12장 DS1302·8장 스윕·부록A LED·7장 JTAG), GPIO27(9장 마커·11장 LED·12장 SQW·부록A·untitled.slx), GPIO23/24(9장 HC-SR04·12장 DS1302·8장 스윕), 부록B blink12가 SPI0 핀(GPIO7–10)을 LED로 사용, AD2 DIO1(10장 GPIO18 vs 9장 9-7 GPIO27), 11장과 부록B semaphore 배선 상이 — 부록 C C.4.2 충돌표 참고
- [x] 출력 출처 표기 통일: "Pi 4에서 예상되는 형태"/"WSL 결과"/"WSL 실제 출력"/"aarch64 결과"/"<!-- 예시 출력 -->"/"(예시, 하드웨어 확인 필요)"/"TODO(Pi 확인)" 혼재 (2026-10-05: 출력 블록 위 `> 출력 출처: …` 한 줄로 통일, 머리말 표기 규칙·README에 설명. 실기기 확인 필요 지점은 `PI-CHECK`로 grep)
- [x] 커널 버전 예시 혼재(3장 6.12.25/6.12.34, 4·7장 6.12.47, 2장 rpi-6.6.y 링크) — 기준 OS 결정 후 일괄 정리 (2026-10-05: 예시 출력은 Linux 백서 실캡처의 `6.12.47+rpt-rpi-v8`로 통일(1장 uname, 3장 sysinfo, 4장 /proc/version). 실캡처 6.12.25(3장 UART 부팅, 슬라이드)·6.12.34(Matlab 백서)는 유지. 2장 bcm2711.dtsi 링크 → rpi-6.12.y)
- [ ] 머리말: 감사의 글 작성, 현재 과목이 STM32로 바뀐 사실을 머리말에 언급할지, AI 활용 안내 문구 확인, 15주 계획(부록 A를 11장 주간에 배치) 확인
- [ ] (2026-10-05 추가) 9장 서보·감마 출처, 12장 1.8 kΩ 공식 출처가 없을 때 pigpio 문서 인용으로 확정할지, 13장 `bt_enable.sh`/`bt_check.sh`에서 `hciuart` 줄을 krnbt 기준으로 고칠지(코드 변경 → 재삽입 필요)
