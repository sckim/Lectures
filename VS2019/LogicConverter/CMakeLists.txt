cmake_minimum_required(VERSION 3.10)

# 프로젝트 이름 설정
project(LogicConverter)

# 컴파일할 소스 파일들을 모두 적어줍니다.
add_executable(LogicConverter 
    LogicConverter.cpp
    converter_boolean.cpp
    converter_minterm.cpp
    converter.h
)
