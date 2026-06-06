# 🦋 Adafruit Feather nRF52840 Express 실습 예제

이 폴더는 Adafruit의 nRF52840 기반 페더(Feather) 보드를 활용한 BLE(Bluetooth Low Energy) 통신 및 시리얼 통신 예제 프로젝트들을 포함하고 있습니다.

This folder contains projects for BLE and serial communication using the Adafruit Feather nRF52840 Express board.

---

## 📂 파일 목록 (File List)

| 파일 (File) | 주요 내용 (Description) |
| :--- | :--- |
| **BLE_Serial.cpp** | 스마트폰 또는 PC와 BLE를 통해 시리얼 데이터를 주고받는 예제 |
| **Serial_terminal.cpp** | USB 시리얼 포트를 통해 터미널 입출력을 처리하는 기초 예제 |

---

## 🔍 학습 목표 (Learning Objectives)

1.  **BLE 통신 이해**: Bluetooth Low Energy를 활용하여 무선으로 데이터를 전송하는 방법을 학습합니다.
2.  **페더 보드 활용**: nRF52840 칩셋의 특징을 이해하고 Arduino IDE 환경에서 프로그래밍하는 방법을 익힙니다.

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **개발 도구**: Arduino IDE 또는 Visual Studio Code + PlatformIO
2.  **보드 패키지**: `Adafruit nRF52 by Adafruit` 보드 패키지가 설치되어 있어야 합니다.
3.  **실행 방법**:
    *   Arduino IDE에서 해당 `.cpp` 코드를 열고 nRF52840 보드를 선택한 후 업로드합니다.
    *   BLE 앱(예: Bluefruit Connect)을 사용하여 데이터를 확인합니다.

---

## 📚 관련 자료
*   [Adafruit Feather nRF52840 공식 가이드](https://learn.adafruit.com/adafruit-feather-nrf52840-express)
*   [메인 README.md로 돌아가기](../README.md)
