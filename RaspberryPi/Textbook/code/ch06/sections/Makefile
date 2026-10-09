# 실습 6-4  ELF 섹션 크기 비교
CC     = gcc
CFLAGS = -Wall -O0

PROGS = sections_base sections_data sections_bss

.PHONY: all compare clean

all: $(PROGS)

sections_base: sections.c
	$(CC) $(CFLAGS) -o $@ $<

sections_data: sections.c
	$(CC) $(CFLAGS) -DADD_DATA -o $@ $<

sections_bss: sections.c
	$(CC) $(CFLAGS) -DADD_BSS -o $@ $<

compare: $(PROGS)
	size $(PROGS)
	@echo
	ls -l $(PROGS)

clean:
	rm -f $(PROGS)
