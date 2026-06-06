# 🛠️ Microchip Studio를 이용한 AVR 실습 예제

이 폴더는 Microchip Studio (구 Atmel Studio)를 사용하여 AVR 마이크로컨트롤러의 기본 동작과 CPU 구조를 이해하기 위한 실습 프로젝트들을 포함하고 있습니다.

This folder contains Microchip Studio projects for understanding the basic operations and CPU architecture of AVR microcontrollers.

---

## 📂 프로젝트 목록 (Project List)

| 폴더명 (Folder) | 주요 내용 (Description) | 언어 (Language) |
| :--- | :--- | :--- |
| **asmStart** | 레지스터(`r16`) 값을 1씩 증가시키는 가장 기초적인 어셈블리 예제 | Assembly |
| **asmBlink** | `DDRB`와 `PORTB` 레지스터를 직접 제어하여 LED를 점멸하는 어셈블리 예제 | Assembly |
| **return** | 함수 반환(`return`) 시 CPU의 스택 및 레지스터 변화를 관찰하기 위한 예제 | C |
| **while** | 무한 루프(`while(1)`)가 CPU 레벨에서 어떻게 구현되는지 확인하는 예제 | C |
| **add** | 두 수의 합을 구하는 함수 호출 과정과 매개변수 전달 방식을 관찰하는 예제 | C |

---

## 🔍 학습 목표 (Learning Objectives)

1.  **CPU 동작 이해**: 어셈블리 코드를 통해 CPU의 레지스터(Register), 프로그램 카운터(PC), 산술논리연산장치(ALU)의 동작을 직접 관찰합니다.
2.  **C 언어의 기계어 변환**: 작성한 C 코드가 실제 CPU에서 어떤 어셈블리 명령어로 변환되어 실행되는지 디버거를 통해 확인합니다.
3.  **디버깅 기술**: Microchip Studio의 시뮬레이터와 디버거를 활용하여 단계별 실행(Step-by-step) 및 메모리 구조를 파악합니다.

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **개발 도구**: [Microchip Studio v.7.0](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio)
2.  **실행 방법**:
    *   `MicrochipStudio.atsln` 파일을 열어 전체 솔루션을 로드합니다.
    *   원하는 프로젝트를 **'Set as StartUp Project'**로 설정합니다.
    *   `Debug` -> `Start Debugging and Break (Alt+F5)`를 눌러 시뮬레이션을 시작합니다.
    *   `Processor Status`, `Registers`, `Disassembly` 창을 띄워 놓고 한 단계씩 실행(`F11`)하며 변화를 관찰합니다.

---

## 📚 관련 자료
*   [마이크로컨트롤러 강의 자료](https://docs.google.com/document/d/1n3KUeXxMnC6K4D472Y-YwuZHPKo5krAnx2WdAsmD2wA/edit#heading=h.g1r703qpvjvj)
*   [메인 README.md로 돌아가기](../README.md)
