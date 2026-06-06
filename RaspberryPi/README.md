# 🍓 Raspberry Pi 실습 예제

이 폴더는 라즈베리 파이를 활용한 리눅스 기반 프로그래밍, GPIO 제어, IPC(Inter-Process Communication) 및 임베디드 시스템 실습 프로젝트들을 포함하고 있습니다.

This folder contains Raspberry Pi projects for Linux-based programming, GPIO control, IPC (Inter-Process Communication), and embedded system exercises.

---

## 📂 프로젝트 목록 (Project List)

| 폴더/파일명 (Folder/File) | 주요 내용 (Description) |
| :--- | :--- |
| **Codes** | `calculate_pi`, `hello`, `semaphore_led`, `sharedCounter` 등 기본적인 C 프로그래밍 및 멀티프로세스 예제 |
| **WiringPi** | `WiringPi` 라이브러리를 사용한 기본적인 LED 제어(`led_onoff.c`) 예제 |
| **Pigpio** | `Pigpio` 라이브러리를 사용한 RTC(`DS1302`), LCD 제어 및 실시간 GPIO 입출력 예제 |
| **TS100** | Python 기반의 BLE(Bluetooth Low Energy) 통신 예제 (`nRF52_BLE_test.py` 등) |
| **Simulink** | MATLAB/Simulink에서 Raspberry Pi로 자동 코드 생성된 프로젝트 |
| **Docs** | 라즈베리 파이 기초 학습을 위한 초보자 가이드(PDF) |

---

## 🔍 학습 목표 (Learning Objectives)

1.  **리눅스 프로그래밍 기초**: 파일 입출력, 프로세스 관리, 시그널 처리 등 리눅스 시스템 프로그래밍의 기초를 학습합니다.
2.  **임베디드 GPIO 제어**: 다양한 라이브러리(`WiringPi`, `Pigpio`)를 사용하여 센서와 액추에이터를 직접 제어합니다.
3.  **IPC 실습**: 공유 메모리(Shared Memory), 세마포어(Semaphore) 등을 통해 프로세스 간 동기화 기법을 이해합니다.
4.  **통신 프로토콜**: BLE, I2C, SPI 등 임베디드 시스템에서 사용되는 주요 통신 프로토콜을 실습합니다.

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **장치**: Raspberry Pi (모든 버전 지원)
2.  **프로파일링/빌드**:
    *   C 코드 빌드: `gcc -o output_file source_file.c -lwiringPi` (또는 `-lpigpio`)
    *   Python 코드 실행: `python3 script_name.py`
3.  **라이브러리 설치**:
    *   `WiringPi` 및 `Pigpio`가 설치되어 있어야 합니다.

---

## 📚 관련 자료
*   [임베디드시스템 강의 자료](https://docs.google.com/document/d/1DVsG6Le9iVnEqlcv0TA36XSPXYZ1sAhT7xt2vGAz96Q/edit)
*   [메인 README.md로 돌아가기](../README.md)
