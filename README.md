# 🎓 임베디드 및 디지털 시스템 설계 강의 자료 (Embedded & Digital System Design)

디지털 회로의 기초 원리부터 마이크로컨트롤러를 활용한 임베디드 프로그래밍까지, 제가 담당하는 교과목의 참고자료와 실습 예제를 체계적으로 정리한 저장소입니다.

This repository systematically organizes reference materials and practical examples for courses covering everything from fundamental digital circuit principles to embedded programming using microcontrollers.

---

## 📂 저장소 구조 (Repository Structure)

```text
.
├── 📗 Digital_Logics/      # 디지털 논리회로 및 시스템 설계 (Multisim, Proteus, Quartus, Simulink)
├── 📘 MicrochipStudio/     # 마이크로컨트롤러 실습 (AVR, ATmega328P, C/Assembly CPU 동작 이해)
├── 📙 RaspberryPi/         # 임베디드 시스템 (C, 다중 스레드, GPIO, BLE IoT, Simulink)
├── 🛰️ Adafruit feather.../ # nRF52840 기반 BLE 및 시리얼 통신 예제
├── 💻 VS2019/              # C 언어 기초 및 데이터 처리 실습
├── 🔌 Schematics/          # KiCad 회로도/PCB (Analog Discovery 2 실습 확장 키트, 온보드 레벨 시프터)
├── 📄 References.md        # 상세 학습 참고자료 및 교재 목록
└── 📄 LICENSE              # GNU GPL v3.0
```

---

## 🎓 담당 교과목 (Courses)

### 1️⃣ [디지털논리회로 (1학기)](https://docs.google.com/document/d/1-Nbt2U4_RxmWI0knJ9PB-1zacaE4BrXKlVAKuqOXOog/edit#heading=h.l577gc53wk1r)
*   **목표**: 논리 게이트, 조합 회로 및 순차 회로의 기초 이해
*   **실습 도구별 예제**:
    *   [Multisim 예제](/Digital_Logics/Multisim/) : 기본 게이트, 가산기, 비교기, 코드 변환기, 카운터
    *   [Proteus 예제](/Digital_Logics/Proteus/) : 래치/플립플롭, 쉬프트 레지스터(74LS164/165/194/195), 멀티플렉서, 디코더
    *   [Quartus 예제](/Digital_Logics/Quartus_schematics/) : FPGA 기반 스키매틱 설계 (조합회로 → 카운터 → 상태머신 → 디지털 시계)
    *   [Simulink 예제](/Digital_Logics/Simulink/) : 모델 기반 설계 (가산기, 플립플롭, 카운터, FSM, 자판기, 신호등)

### 2️⃣ [디지털시스템설계 (2학기)](https://docs.google.com/document/d/1w0CORrWaHI_NbjOskmIDs7_7yvQ0bz3ZSNFg1BX11ck/edit#heading=h.r1hokjytc0js)
*   **목표**: VHDL/Verilog를 이용한 하드웨어 설계 언어(HDL) 기초 및 응용
*   **주요 내용**: FPGA 보드(DE1-SoC 등) 활용 실습 및 복잡한 디지털 시스템 설계
*   **참고자료**: [References.md](References.md)의 *VHDL/Verilog 문법* 항목 (HDLBits, ModelSim Testbench 튜토리얼 등)

### 3️⃣ [마이크로컨트롤러 (1학기)](https://docs.google.com/document/d/1n3KUeXxMnC6K4D472Y-YwuZHPKo5krAnx2WdAsmD2wA/edit#heading=h.g1r703qpvjvj)
*   **목표**: AVR 아키텍처 이해 및 레지스터 기반 제어 학습
*   **실습 구성**:
    *   [C/Assembly 분석](/MicrochipStudio) : Disassembler와 디버거를 통한 CPU 동작 원리 이해 (`asmStart`, `asmBlink`, `add`, `return`, `while`)
    *   [C 언어 복습](/VS2019) : 임베디드 C 기초 다지기 (구조체, 파일 입출력, 디지털 필터, 시리얼 통신)
    *   [AD2 확장 키트](/Schematics/AD2_extension) : Analog Discovery 2 연동 실습 보드 (KiCad, UNO/Nucleo/Feather 지원, I2C·PWM·SPI 레벨 시프터 온보드)

### 4️⃣ [임베디드시스템 (2학기)](https://docs.google.com/document/d/1DVsG6Le9iVnEqlcv0TA36XSPXYZ1sAhT7xt2vGAz96Q/edit)
*   **목표**: 고성능 프로세서 환경에서의 임베디드 운영체제 및 응용 프로그래밍
*   **주요 플랫폼**:
    *   교재 「라즈베리파이로 배우는 임베디드 시스템」 : 원고와 장별 예제 코드는 별도 저장소(`RaspberryPi_Textbook`, 비공개)에서 관리
    *   [Raspberry Pi 실습](/RaspberryPi) : Linux 기반 C 프로그래밍, 멀티스레드(Semaphore), 성능 측정
    *   [GPIO 제어](/RaspberryPi/Pigpio) : WiringPi / pigpio 라이브러리, RTC(DS1302), I2C LCD(PCF8574)
    *   [BLE IoT 프로젝트 (TS100)](/RaspberryPi/TS100/Gitbook) : BLE 체온계 → Raspberry Pi(Python) → AWS 클라우드 연동
    *   [nRF52840 예제](/Adafruit%20feather%20nRF52840%20express) : 저전력 블루투스(BLE) 통신 및 시리얼 통신

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
    *   [MATLAB/Simulink](https://www.mathworks.com/products/simulink.html)
*   **HDL/FPGA**: [Intel Quartus Prime](https://www.intel.co.kr/content/www/kr/ko/software/programmable/quartus-prime/overview.html)
*   **PCB 설계**: [KiCad](https://www.kicad.org/) ([KiCad 라이브러리 저장소](https://github.com/sckim/KiCAD))

---

## 🚀 시작하기 (Getting Started)

1.  **저장소 복제 (Clone)**:
    ```bash
    git clone https://github.com/sckim/Lectures.git
    ```
2.  **참고자료 확인**: [References.md](References.md)에서 교재 및 온라인 강의 링크를 확인하세요.
3.  **예제 실행**: 각 폴더의 README를 참고하여 프로젝트 파일을 해당 IDE에서 열어 실행합니다.
    *   Quartus 프로젝트는 `.qpf`, Microchip Studio는 `MicrochipStudio.atsln`, Visual Studio는 `VS2019.sln`을 엽니다.
    *   빌드 산출물(`db/`, `output_files/`, `Debug/` 등)은 저장소에 포함되지 않으므로 처음 열 때 한 번 컴파일하세요.

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
