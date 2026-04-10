# 💻 Visual Studio 2019 C/C++ 실습 예제

이 폴더는 C 언어의 기초부터 데이터 처리, 파일 입출력, 시리얼 통신 등 실무적인 프로그래밍 기법을 학습하기 위한 Visual Studio 2019 프로젝트들을 포함하고 있습니다.

This folder contains Visual Studio 2019 projects for learning C language basics, data processing, file I/O, and practical programming techniques like serial communication.

---

## 📂 프로젝트 목록 (Project List)

| 폴더명 (Folder) | 주요 내용 (Description) |
| :--- | :--- |
| **Addressbook** | 구조체와 파일 입출력을 활용한 주소록 관리 예제 (`Addressbook1`, `Addressbook2`, `AddBook1`) |
| **DigitalFilter** | FIR/IIR 필터 구현 및 신호 처리 기초 실습 |
| **SerialCommunication** | Windows API를 이용한 RS-232 시리얼 통신 예제 |
| **Arg** | 명령행 인자(`argc`, `argv`) 처리 방법 실습 |
| **Array_test / Bounds** | 배열의 활용 및 인덱스 범위 초과(Boundary check) 관련 실습 |
| **DataFormat** | 데이터 포맷 변환 및 서식화된 입출력 실습 |
| **Token** | `strtok` 함수를 이용한 문자열 파싱(Tokenizing) 실습 |
| **Listing10_xx** | 'C Primer Plus' 교재의 주요 예제 코드 실습 |
| **QM** | 상태 머신(State Machine) 또는 특정 알고리즘 테스트 |

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **개발 도구**: Visual Studio 2019 (또는 상위 버전)
2.  **실행 방법**:
    *   `VS2019.sln` 파일을 열어 전체 솔루션을 로드합니다.
    *   원하는 프로젝트를 **'시작 프로젝트로 설정(Set as Startup Project)'** 한 후 `F5`를 눌러 실행합니다.
3.  **참고 사항**: 
    *   일부 프로젝트는 `strtok` 등 이전 스타일의 함수를 사용하므로 `#pragma warning(disable:4996)`이 포함되어 있을 수 있습니다.
    *   시리얼 통신 예제는 실제 COM 포트 설정에 따라 수정이 필요할 수 있습니다.

---

## 📚 관련 자료
*   [C Primer Plus (6th Edition)](c-primer-plus-book-6ed.url) - 교재 관련 참고 링크
*   [메인 README.md로 돌아가기](../README.md)
