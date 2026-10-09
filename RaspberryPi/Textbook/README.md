# 라즈베리파이로 배우는 임베디드 시스템

한경국립대학교 전자공학전공 「임베디드시스템」 강의(2023–2025, Raspberry Pi 4B 기반) 내용을 정리한 교재입니다.

## 목차

| 장 | 제목 |
|---|---|
| [머리말](00_preface.md) | 과목 소개와 학습 방법 |
| [1장](01_embedded_system.md) | 임베디드 시스템이란 |
| [2장](02_computer_arch_arm.md) | 컴퓨터 구조와 ARM 프로세서 |
| [3장](03_rpi_hw_os.md) | Raspberry Pi 하드웨어와 OS 설치 |
| [4장](04_linux_shell.md) | Linux와 셸 |
| [5장](05_sysadmin.md) | 시스템 관리 |
| [6장](06_c_build.md) | C 개발 환경과 빌드 |
| [7장](07_boot_kernel.md) | 부팅 과정과 커널 |
| [8장](08_gpio_pigpio.md) | GPIO 기초와 pigpio |
| [9장](09_pigpio_advanced.md) | pigpio 심화: 인터럽트·PWM·서보 |
| [10장](10_measurement.md) | 측정 장비로 신호 확인하기 |
| [11장](11_process_concurrency.md) | 프로세스와 동시성 |
| [12장](12_communication.md) | 디바이스 간 통신: UART·I2C·SPI |
| [13장](13_ble_iot.md) | BLE와 IoT |
| [부록 A](appendix_a_matlab_simulink.md) | MATLAB/Simulink 모델 기반 설계 |
| [부록 B](appendix_b_gpio_libraries.md) | GPIO 라이브러리의 변천 (WiringPi → pigpio → libgpiod) |
| [부록 C](appendix_c_reference.md) | 명령어 요약과 오류 모음 |

## 이 교재의 약속

- 실습 보드는 **Raspberry Pi 4 Model B**, OS는 **Raspberry Pi OS (64-bit, Bookworm)** 기준입니다.
- GPIO 제어는 **pigpio** 라이브러리를 사용합니다. WiringPi는 원작자가 2019년에 지원을 종료했고(현재는 커뮤니티 포크가 유지), 수업에서는 pigpio로 전환했으므로 부록 B에서만 다룹니다.
  - pigpio는 Raspberry Pi 5(RP1 칩)를 지원하지 않습니다. Pi 5 사용자는 부록 B의 libgpiod 절을 참고하세요.
- 핀은 `GPIO17 (물리 핀 11)`처럼 BCM 번호와 물리 핀 번호를 함께 적습니다.
- 모든 실습은 [8장 8.2.4](08_gpio_pigpio.md)의 표준 배선을 따릅니다(5V 장치는 레벨 시프터를 거쳐 연결합니다).
- 강의에서 직접 다루지 않고 공식 문서로 보강한 내용에는 **📌 보강** 표시가 있습니다.
- 출력 블록 바로 위의 `> 출력 출처: …` 줄은 그 출력을 어디서 얻었는지(WSL Debian 12 실행 결과 / aarch64 교차 빌드 결과 / Pi 4 실기기 캡처 / 예시(Pi 4 실기기에서 확인 필요))를 밝힙니다. 자세한 규칙은 [머리말 「이 책의 표기 규칙」](00_preface.md)을 보세요. 원고에서 아직 실기기 확인이 필요한 곳은 `PI-CHECK`로 검색할 수 있습니다.
- 예제 코드는 [`code/`](code/)에 장별로 있습니다.
- 과제는 **PDF로만** 제출합니다.

## 관련 자료

- 예제 원본: [`../Codes`](../Codes), [`../Pigpio`](../Pigpio)
- BLE 체온계 교재: [`../TS100-Gitbook`](../TS100-Gitbook)
- 집필 출처와 정정 목록: [sources.md](sources.md)
