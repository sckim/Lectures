"""test_hts.py : 13장  hts.py 해석 함수를 예제 바이트로 확인한다 (블루투스 장치 불필요)

실행 : python3 test_hts.py        -> 각 예제의 결과를 출력하고, 틀리면 AssertionError로 멈춘다
"""

import math
from datetime import datetime

from hts import (decode_float32, decode_date_time, encode_date_time,
                 parse_temperature_measurement)


def show(title, hexstr):
    data = bytes.fromhex(hexstr)
    m = parse_temperature_measurement(data)
    print("%-28s %-40s -> %s %s, time=%s, type=%s, extra=%s"
          % (title, hexstr, m.value, m.unit, m.timestamp, m.temp_type_name,
             m.extra.hex(" ") or "-"))
    return m


# 1) 가장 단순한 경우: Flags=0x00(섭씨, 부가 필드 없음)
#    FLOAT = 0xFE000DDE -> 지수 0xFE = -2, 가수 0x000DDE = 3550 -> 3550 x 10^-2 = 35.50
m = show("1) 섭씨 35.50", "00 DE 0D 00 FE")
assert m.unit == "C" and m.value == 35.5 and m.timestamp is None

# 2) TS100 시뮬레이터가 보내는 12바이트: Flags=0x00인데 뒤에 날짜 7바이트가 더 붙어 있다
#    규격대로 읽으면 날짜는 '남는 바이트(extra)'가 된다 -> Pi의 수신 시각을 쓰면 된다
m = show("2) 시뮬레이터 36.40", "00 38 0E 00 FE E8 07 01 01 00 00 05")
assert m.value == 36.4 and m.timestamp is None and len(m.extra) == 7

# 3) Time Stamp 비트(0x02)가 켜진 경우: 2025-12-11 14:37:00
#    연도 2025 = 0x07E9 -> 리틀 엔디언으로 E9 07
m = show("3) 시각 포함 36.50", "02 6D 01 00 FF E9 07 0C 0B 0E 25 00")
assert m.value == 36.5 and m.timestamp == datetime(2025, 12, 11, 14, 37, 0)

# 4) Temperature Type 비트(0x04)까지: 0x06 = 시각+종류, 종류 1 = 겨드랑이
m = show("4) 시각+종류 37.2", "06 74 01 00 FF E9 07 0C 0B 0E 25 00 01")
assert m.value == 37.2 and m.temp_type == 1

# 5) 화씨(Flags bit0 = 1): 98.6 F = 37.0 C
m = show("5) 화씨 98.6", "01 DA 03 00 FF")
assert m.unit == "F" and m.value == 98.6 and abs(m.celsius - 37.0) < 1e-9

# 6) 음수: -1.5 C. 가수 -15 = 0xFFFFF1(24비트 2의 보수), 지수 -1 = 0xFF
#    원본 코드(부호 무시)로 계산하면 16777201 x 0.1 = 1677720.1 이라는 엉뚱한 값이 나온다
m = show("6) 음수 -1.5", "00 F1 FF FF FF")
assert m.value == -1.5
naive = (0xF1 + (0xFF << 8) + (0xFF << 16)) * 10 ** -1
print("   (원본 방식으로 계산하면 %.1f)" % naive)

# 7) 특수값: NaN(0x007FFFFF), +INF(0x007FFFFE)
assert math.isnan(decode_float32(bytes.fromhex("FF FF 7F 00")))
assert decode_float32(bytes.fromhex("FE FF 7F 00")) == math.inf
print("7) 특수값 NaN, +INF 확인")

# 8) Date Time 왕복 변환 (0x2A08에 쓸 바이트)
dt = datetime(2026, 10, 2, 9, 5, 30)
raw = encode_date_time(dt)
print("8) Date Time %s -> %s" % (dt, raw.hex(" ")))
assert raw == bytes.fromhex("EA 07 0A 02 09 05 1E") and decode_date_time(raw) == dt

# 9) 잘못된 길이는 예외로 알려 준다
try:
    parse_temperature_measurement(bytes.fromhex("02 6D 01 00 FF E9 07"))
except ValueError as e:
    print("9) 짧은 데이터 -> ValueError:", e)
else:
    raise AssertionError("ValueError가 나야 한다")

print("모든 예제 통과")
