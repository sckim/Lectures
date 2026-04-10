# 🎓 임베디드 및 디지털 시스템 설계 강의 자료 (Embedded & Digital System Design)

디지털 회로의 기초 원리부터 마이크로컨트롤러를 활용한 임베디드 프로그래밍까지, 제가 담당하는 교과목의 참고자료와 실습 예제를 체계적으로 정리한 저장소입니다.

This repository systematically organizes reference materials and practical examples for courses covering everything from fundamental digital circuit principles to embedded programming using microcontrollers.

---

## 📂 저장소 구조 (Repository Structure)

```text
.
├── 📗 Digital_Logics/      # 디지털 논리회로 및 시스템 설계 (Multisim, Proteus, Quartus)
├── 📘 MicrochipStudio/      # 마이크로컨트롤러 실습 (AVR, ATmega328P, C/Assembly)
├── 📙 RaspberryPi/         # 임베디드 시스템 (C, 다중 스레드, 성능 측정)
├── 🛰️ Adafruit feather.../ # nRF52840 기반 BLE 및 시리얼 통신 예제
├── 💻 VS2019/              # C 언어 기초 및 데이터 처리 실습
├── 🌐 Wokwi/               # 온라인 시뮬레이터 연동 예제 (IoT)
└── 📄 References.md        # 상세 학습 참고자료 및 교재 목록
```

---

## 🎓 담당 교과목 (Courses)

### 1️⃣ [디지털논리회로 (1학기)](https://docs.google.com/document/d/1-Nbt2U4_RxmWI0knJ9PB-1zacaE4BrXKlVAKuqOXOog/edit#heading=h.l577gc53wk1r)
*   **목표**: 논리 게이트, 조합 회로 및 순차 회로의 기초 이해
*   **실습 도구별 예제**:
    *   [Multisim 예제](/Digital_Logics/Multisim/) : 아날로그/디지털 혼합 시뮬레이션
    *   [Quartus 예제](/Digital_Logics/Quartus_schematics/) : FPGA 기반 논리 회로 설계
    *   [Proteus 예제](/Digital_Logics/Proteus/) : 마이크로컨트롤러 연동 시뮬레이션

### 2️⃣ [디지털시스템설계 (2학기)](https://docs.google.com/document/d/1w0CORrWaHI_NbjOskmIDs7_7yvQ0bz3ZSNFg1BX11ck/edit#heading=h.r1hokjytc0js)
*   **목표**: VHDL/Verilog를 이용한 하드웨어 설계 언어(HDL) 기초 및 응용
*   **주요 내용**: FPGA 보드 활용 실습 및 복잡한 디지털 시스템 설계

### 3️⃣ [마이크로컨트롤러 (1학기)](https://docs.google.com/document/d/1n3KUeXxMnC6K4D472Y-YwuZHPKo5krAnx2WdAsmD2wA/edit#heading=h.g1r703qpvjvj)
*   **목표**: AVR 아키텍처 이해 및 레지스터 기반 제어 학습
*   **실습 구성**:
    *   [Arduino 기반 예제](/Arduino_Examples) : 빠른 프로토타이핑
    *   [Register 기반 예제](/uC_Examples) : 하드웨어 직접 제어
    *   [C/Assembly 분석](/MicrochipStudio) : Disassembler를 통한 CPU 동작 원리 이해
    *   [C 언어 복습](/VS2019) : 임베디드 C 기초 다지기

### 4️⃣ [임베디드시스템 (2학기)](https://docs.google.com/document/d/1DVsG6Le9iVnEqlcv0TA36XSPXYZ1sAhT7xt2vGAz96Q/edit)
*   **목표**: 고성능 프로세서 환경에서의 임베디드 운영체제 및 응용 프로그래밍
*   **주요 플랫폼**: 
    *   [Raspberry Pi 실습](/RaspberryPi) : Linux 기반 C 프로그래밍, 멀티스레드(Semaphore)
    *   [nRF52840 예제](/Adafruit%20feather%20nRF52840%20express) : 저전력 블루투스(BLE) 통신

---

## 🛠️ 개발 환경 (Development Environment)

효과적인 학습을 위해 다음 도구들을 사용합니다:

*   **IDE**: 
    *   [Microchip Studio](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio) (AVR/ATmega 제어)
    *   [VS Code](https://code.visualstudio.com/) + [PlatformIO](https://platformio.org/) (추천 환경)
    *   Visual Studio 2019 (C 언어 기초)
*   **Simulation**:
    *   [Multisim](https://www.ni.com/ko-kr/support/downloads/software-products/download.multisim.html)
    *   [Proteus](https://www.labcenter.com/)
    *   [Wokwi](https://wokwi.com/) (Web 기반 시뮬레이터 - [예제 확인](/Wokwi/Blink/))
*   **HDL**: [Intel Quartus Prime](https://www.intel.co.kr/content/www/kr/ko/software/programmable/quartus-prime/overview.html)

---

## 🚀 시작하기 (Getting Started)

1.  **저장소 복제 (Clone)**:
    ```bash
    git clone https://github.com/sckim/Lectures.git
    ```
2.  **참고자료 확인**: [References.md](References.md)에서 교재 및 온라인 강의 링크를 확인하세요.
3.  **예제 실행**: 각 폴더 내의 프로젝트 파일을 해당 IDE에서 열어 실행해 볼 수 있습니다.

---

## ✉️ 문의 및 피드백 (Contact & Feedback)

학습 중 궁금한 점이나 보완이 필요한 내용은 언제든지 아래로 연락 바랍니다:
*   **이메일**: sckim@hknu.ac.kr
*   **GitHub Issues**: 오류 제보나 기능 제안은 Issue를 이용해 주세요.

---

## ⚖️ 라이선스 (License)

이 저장소의 코드는 [GNU General Public License v3.0](LICENSE)을 따릅니다.

---
*지속적으로 업데이트 중입니다. 학생 여러분의 학습에 도움이 되길 바랍니다!*
