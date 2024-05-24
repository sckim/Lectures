J = 1 << 1
CO = 1 << 2
CE = 1 << 3
OI = 1 << 4
BI = 1 << 5
SU = 1 << 6
EO = 1 << 7

cHigh = 8
AO = 1 << cHigh
AI = 1 << 1 << cHigh
II = 1 << 2 << cHigh
IO = 1 << 3 << cHigh
RO = 1 << 4 << cHigh
RI = 1 << 5 << cHigh
MI = 1 << 6 << cHigh
HLT = 1 << 7 << cHigh

opcode = (
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,  # fetch
    MI | CO, RO | II | CE, MI | IO, RO | AI, 0, 0, 0, 0,  # LDA
    MI | CO, RO | II | CE, MI | IO, RO | BI, AI | EO, 0, 0, 0, #ADD
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, 0, 0, 0, 0, 0, 0,
    MI | CO, RO | II | CE, OI | AO, 0, 0, 0, 0, 0,  # OUT
    MI | CO, RO | II | CE, HLT, 0, 0, 0, 0, 0,  # HALT
)
# opcode = bytearray([
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, MI|IO, RO|AI, 0, 0, 0, 0,
#     MI, RO|II, MI|IO, RO, AI, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, 0, 0, 0, 0, 0, 0,
#     MI, RO|II, AO, 0, 0, 0, 0, 0,
#     MI, RO|II, HLT, 0, 0, 0, 0, 0,
#
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, BI, EO, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0,
#     CO, CE, OI, 0, 0, 0, 0, 0,
#     CO, CE, 0, 0, 0, 0, 0, 0]
# )

code =bytearray([])
for i in range(0, 16):
    for j in range(0, 8):
        code.append(opcode[i * 8 + j] >> 8)
        print("%02X " % (opcode[i * 8 + j] >> 8), end="")
    print("")

for i in range(0, 16):
    for j in range(0, 8):
        code.append(opcode[i * 8 + j] & 0xFF)
        print("%02X " % (opcode[i * 8 + j] & 0xFF), end="")
    print("")

with open("opecode.bin", "wb") as out_file:
    out_file.write(code);

digits = bytearray([
    0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70, 0x7F, 0x7b])

code = bytearray([])
for i in range(0, 256):
    code.append(digits[i % 10])

for i in range(0, 256):
    code.append(digits[int((i / 10) % 10)])

for i in range(0, 256):
    code.append(digits[int((i / 100) % 10)])

for i in range(0, 256):
    code.append(0)

for i in range(0, 128):
    code.append(digits[abs(i) % 10])

for i in range(-128, 0):
    code.append(digits[abs(i) % 10])

for i in range(0, 128):
    code.append(digits[int((abs(i / 10)) % 10)])

for i in range(-128, 0):
    code.append(digits[int((abs(i / 10)) % 10)])

for i in range(0, 128):
    code.append(digits[int((abs(i / 100)) % 10)])

for i in range(-128, 0):
    code.append(digits[int((abs(i / 100)) % 10)])

for i in range(0, 128):
    code.append(0x0)

for i in range(1, 129):
    code.append(0x1)

display = code + bytearray([0xea] * (16384 - len(code)))

with open("display.bin", "wb") as out_file:
    out_file.write(display);


digits = bytearray([
    0x1e, 0x2f, 0xe0, 0xf0,
    0x0, 0x0, 0x0, 0,
    0x0, 0x0, 0x0, 0,
    0x0, 0x0, 0x1c, 0x0e])

with open("prog.bin", "wb") as out_file:
    out_file.write(digits);
