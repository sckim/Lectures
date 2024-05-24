digits = bytearray([
0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70, 0x7F, 0x7b])

code = bytearray([])
for i in range(0, 256) :
    code.append(digits[i%10])

for i in range(0, 256) :
    code.append(digits[int((i/10)%10)])

for i in range(0, 256) :
    code.append(digits[int((i/100)%10)])

for i in range(0, 256) :
    code.append(0)

for i in range(0, 128) :
    code.append(digits[abs(i)%10])

for i in range(-128, 0) :
    code.append(digits[abs(i)%10])
    
for i in range(0, 128) :
    code.append(digits[int((abs(i / 10)) % 10)])

for i in range(-128, 0) :
    code.append(digits[int((abs(i / 10)) % 10)])

for i in range(0, 128) :
    code.append(digits[int((abs(i / 100)) % 10)])

for i in range(-128, 0) :
    code.append(digits[int((abs(i / 100)) % 10)])

for i in range(0, 128) :
    code.append(0x0)

for i in range(1, 129) :
    code.append(0x1)

rom = code + bytearray([0xea]*(16384-len(code)))

with open("rom.bin", "wb") as out_file:
    out_file.write(rom);