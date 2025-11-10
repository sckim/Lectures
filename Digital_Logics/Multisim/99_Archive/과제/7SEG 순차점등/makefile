# 0 //Do not modify any of lines. Be sure to put 'Tab' before command.
# 1 Default Makefile
# 2 define some variables based on the AVR base path in $(AVR)
	CC=avr-gcc
	AS=avr-gcc -x assembler-with-cpp
	RM=rm -f
	RN=mv
	BIN=avr-objcopy
	ELFCOF=elfcoff
	SIZE=avr-size
	INCDIR=.
	LIBDIR=$(AVR)/WinAvr/Avr/Lib
	SHELL=$(AVR)/WinAvr/Bin/sh.exe
# 13 output format can be srec, ihex (avrobj is always created) #######
     FORMAT=ihex
# 15 put the name of the target mcu here (at90s8515, at90s8535, attiny22, atmega603 etc.)
	MCU=at90s2313
# 17 put the name of the target file here (without extension)
	TRG=ljc
# 19 put your C sourcefiles here
	SRC=$(TRG).c
# 21 put additional assembler source file here
	ASRC=
# 23 additional libraries and object files to link
	LIB=
# 25 additional includes to compile
	INC=
# 27 ###################### default compiler flags ##########################
	CPFLAGS=-g -O3 -Wall -Wstrict-prototypes -Wa,-ahlms=$(<:.c=.lst)
	ASFLAGS=-Wa,-gstabs
	LDFLAGS=-Wl,-Map=$(TRG).map,--cref
# 31 define all project specific object files
	OBJ= $(ASRC:.s=.o) $(SRC:.c=.o)
	CPFLAGS += -mmcu=$(MCU)
	ASFLAGS += -mmcu=$(MCU)
	LDFLAGS += -mmcu=$(MCU)
# 36 this defines the aims of the make process     
all:	$(TRG).obj $(TRG).elf $(TRG).rom $(TRG).eep $(TRG).ok $(TRG).cof  
# 38 compile: instructions to create assembler and/or object files from C source48 .cof
%o : %c
	$(CC) -c $(CPFLAGS) -I$(INCDIR) $< -o $@
%s : %c
	$(CC) -S $(CPFLAGS) -I$(INCDIR) $< -o $@
# 43 assemble: instructions to create object file from assembler files53
%o : %s
	$(AS) -c $(ASFLAGS) -I$(INCDIR) $< -o $@
# 46 link: instructions to create elf output file from object files56
%elf:	$(OBJ)
	$(CC) $(OBJ) $(LIB) $(LDFLAGS) -o $@
# 49 create avrobj file from elf output file59
%obj: %elf
	$(BIN) -O $(FORMAT) $< $@
# 52 create bin (ihex, srec) file from elf output file 62 
%rom: %elf
	$(BIN) -O $(FORMAT) $< $@
%eep: %elf
	$(BIN) -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 -O $(FORMAT) $< $@
%cof: %elf
	$(ELFCOF) $< $(OUT) $(TRG)COF $*cof 
#59 If all other steps compile ok then echo "Errors: none".$(ELFCOF) $< $(OUT) $@ $*cof
%ok:
	@echo "Errors: none" 
# 62 make instruction to delete created files67
clean:
	$(RM) $(OBJ)
	$(RM) $(SRC:.c=.s)
	$(RM) $(SRC:.c=.lst)
	$(RM) $(TRG).map
	$(RM) $(TRG).elf
	$(RM) $(TRG).obj
	$(RM) $(TRG).eep
	$(RM) $(TRG).rom
	$(RM) $(TRG).cof
	$(RM) *.bak
	$(RM) *.log
size:
	$(SIZE) $(TRG).elf
# 77 ##### dependecies, add any dependencies you need here ###################
$(TRG).o : $(TRG).c




