# 🔌 AD2 확장 키트 (Analog Discovery 2 Extension Kit)

Analog Discovery 2(AD2)와 마이크로컨트롤러 보드를 함께 꽂아 실습하는 확장 보드의 KiCad 프로젝트입니다.
Arduino UNO R3 호환 헤더, STM32 Nucleo Morpho 헤더(CN7/CN10), Adafruit Feather 소켓을 지원하며, 5V 주변장치(LCD, PWM)와 3.3V 주변장치(SPI)를 위한 레벨 시프터가 보드에 실장되어 있습니다.

---

## 📂 파일 구성 (Files)

| 파일 | 내용 |
| :--- | :--- |
| `Experimental_Kit.kicad_pro` | KiCad 프로젝트 파일 (이 파일을 여세요) |
| `Experimental_Kit.kicad_sch` | 회로도 |
| `Experimental_Kit.kicad_pcb` | PCB (2층, 배선 및 GND 동박 완료) |
| `AD2_extension.kicad_sym`, `sym-lib-table` | 프로젝트 심볼 라이브러리 (TXU0304PW) |
| `AD2_extension.pretty/`, `fp-lib-table` | 프로젝트 풋프린트 라이브러리 (UNO 실드 헤더, 2×19 미러 소켓) |

---

## 🧩 커넥터 (Connectors)

| 레퍼런스 | 이름 | 용도 |
| :--- | :--- | :--- |
| A1 | Arduino_UNO_R3 | Arduino UNO R3 호환 헤더 |
| J11 / J13 | CN7 / CN10 | STM32 Nucleo Morpho 헤더 |
| MS1 | Feather | Adafruit Feather 소켓 |
| J10 | AD2 | Analog Discovery 2 연결 |
| J2 | Keypad | 키패드 (전원 IOREF) |
| J3 | LCD | I2C LCD (5V, 레벨 시프트된 SDA/SCL) |
| J5 / J6 | PWM | 5V PWM 출력 (DIO3 / DIO5) |
| J14 | SPI | 3.3V SPI 장치 |
| J12 | IOREF | IOREF–3V3 연결 헤더 (아래 참고) |
| J7 / J9 | AREF / W1 | 아날로그 기준 전압 / AD2 파형 발생기 |

---

## 🔁 온보드 레벨 시프터 (On-board Level Shifters)

이전 버전은 BSS138 레벨 시프터 모듈을 헤더(J2/J4)에 꽂아 사용했으나, 현재는 보드에 직접 실장했습니다.
호스트 쪽 전압은 **IOREF**를 기준으로 하므로 5V 보드(UNO)와 3.3V 보드(Nucleo, Feather) 모두에서 규격에 맞는 신호 레벨이 나옵니다.

| 신호 | 회로 | 방향 |
| :--- | :--- | :--- |
| SDA, SCL → LCD | 2N7002 MOSFET (Q1, Q2), 호스트 쪽 풀업 4.7kΩ, 5V 쪽 풀업 10kΩ | 양방향 |
| DIO3, DIO5 → PWM | 2N7002 MOSFET (Q3, Q4), 풀업 10kΩ | IOREF → 5V |
| DIO13/11/10 → SCK/MOSI/CS | TXU0304 (U1), VCCA = IOREF, VCCB = 3.3V | 호스트 → 장치 |
| MISO ← DIO12 | TXU0304 (U1) | 장치 → 호스트 |

> ⚠️ **Feather 사용 시**: Feather에는 IOREF 핀이 없으므로 **J12(IOREF)에 점퍼를 꽂아** IOREF를 3.3V에 연결해야 레벨 시프터가 동작합니다. UNO/Nucleo 사용 시에는 점퍼를 빼 두세요.

---

## 🛠️ 여는 방법 (How to Open)

1. [KiCad](https://www.kicad.org/) 최신 버전을 설치합니다.
2. `Experimental_Kit.kicad_pro`를 엽니다. 프로젝트 라이브러리(`sym-lib-table`, `fp-lib-table`)는 자동으로 로드됩니다.
3. 추가 라이브러리는 [KiCad 라이브러리 저장소](https://github.com/sckim/KiCAD)를 참고하세요.

---

*[메인 README.md로 돌아가기](../../README.md)*
