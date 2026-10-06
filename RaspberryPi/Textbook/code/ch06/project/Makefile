# 실습 6-5  여러 파일 프로젝트의 Makefile (헤더 의존성 자동 추적)
#
#   make          빌드 (바뀐 파일만 다시 컴파일)
#   make clean    산출물 삭제
#   make V=1      실제 실행되는 명령줄을 모두 보기

# ---- 변수 ----
CC       = gcc
CFLAGS   = -Wall -Wextra -O2 -g
# 컴파일하면서 헤더 의존성 파일(.d)을 함께 만든다
CPPFLAGS = -MMD -MP
# util.c의 sqrt 때문에 수학 라이브러리가 필요하다
LDLIBS   = -lm

TARGET   = templog
SRCS     = main.c sensor.c util.c
# 치환 참조: main.c sensor.c util.c → main.o sensor.o util.o
OBJS     = $(SRCS:.c=.o)
# main.d sensor.d util.d
DEPS     = $(OBJS:.o=.d)

# V=1 이면 명령줄을 보여 주고, 아니면 @로 숨긴 뒤 짧은 안내만 출력한다
ifeq ($(V),1)
Q =
else
Q = @
endif

.PHONY: all clean

# ---- 규칙: 첫 번째 타깃이 기본 목표 ----
all: $(TARGET)

# 링크: 목적 파일 전부($^)를 묶어 실행 파일($@)을 만든다
$(TARGET): $(OBJS)
	@echo "  LINK  $@   (새로 바뀐 의존 파일 \$$? = $?)"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

# 패턴 규칙: 어떤 .c든 같은 이름의 .o로 컴파일한다
%.o: %.c
	@echo "  CC    $<  ->  $@"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS) $(DEPS)

# 컴파일러가 만든 의존성 파일을 읽어 들인다(처음에는 없으므로 - 로 오류 무시)
-include $(DEPS)
