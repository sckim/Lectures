cmake_minimum_required(VERSION 3.10)

# 프로젝트 이름 설정
project(LogicConverter)

# 컴파일할 소스 파일들을 모두 적어줍니다.
add_executable(LogicConverter 
    LogicConverter.cpp
    converter_boolean.cpp
    converter_minterm.cpp
    converter_simplify.cpp
    converter.h
)

if(MSVC)
    # 소스 코드와 실행 파일의 인코딩을 모두 UTF-8로 지정
    add_compile_options(/execution-charset:utf-8)
    add_compile_options(/source-charset:utf-8)
endif()
