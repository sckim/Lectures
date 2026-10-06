"""hts.py : 13장  Health Thermometer Service(0x1809) 데이터 해석 모듈

블루투스와 무관한 "순수 계산" 코드만 모았다. bleak가 없어도 import되므로
PC(WSL)에서도 test_hts.py로 바로 시험할 수 있다.

근거 문서(Bluetooth SIG)
  - Health Thermometer Service 1.0 : Temperature Measurement(0x2A1C)는 Indicate 필수
  - GATT Specification Supplement  : 3.239 Temperature Measurement 구조와 Flags,
    3.80 Date Time, 3.242 Temperature Type, 2.1.1 FLOAT(medfloat32) 특수값
원본 : TS100-Gitbook 4.1.3절 temperature_calculate()/date_calculate()를 규격대로 고쳐 씀
  (Flags를 읽지 않던 문제, 24비트 가수의 부호를 무시하던 문제를 바로잡았다)
"""

from dataclasses import dataclass
from datetime import datetime
import math

# --- UUID: 16비트 값을 Bluetooth 기본 UUID(0000xxxx-0000-1000-8000-00805f9b34fb)에 끼운 128비트 형태
HTS_SERVICE_UUID = "00001809-0000-1000-8000-00805f9b34fb"       # Health Thermometer
TEMP_MEASUREMENT_UUID = "00002a1c-0000-1000-8000-00805f9b34fb"  # Temperature Measurement
DATE_TIME_UUID = "00002a08-0000-1000-8000-00805f9b34fb"         # Date Time (TS100 제조사 추가)

# --- Flags 비트 (GATT Specification Supplement 3.239.1) -----------------
FLAG_FAHRENHEIT = 0x01   # bit0: 0 = 섭씨, 1 = 화씨
FLAG_TIMESTAMP = 0x02    # bit1: Time Stamp(7바이트)가 뒤에 있음
FLAG_TEMP_TYPE = 0x04    # bit2: Temperature Type(1바이트)이 뒤에 있음

# --- FLOAT 특수값 (지수 0, 가수만 보고 판단; 규격 표 2.1) -------------------
FLOAT_SPECIAL = {
    0x7FFFFF: math.nan,     # NaN  (Not a Number)
    0x800000: math.nan,     # NRes (Not at this Resolution)
    0x7FFFFE: math.inf,     # +INF
    0x800002: -math.inf,    # -INF
    0x800001: math.nan,     # 예약값(Reserved for Future Use)
}

# --- Temperature Type 값 (GATT Specification Supplement 3.242.1) -------
TEMP_TYPE_NAMES = {
    1: "Armpit(겨드랑이)", 2: "Body(신체 일반)", 3: "Ear(귓불)", 4: "Finger(손가락)",
    5: "GI tract(위장관)", 6: "Mouth(입)", 7: "Rectum(직장)", 8: "Toe(발가락)",
    9: "Tympanum(고막)",
}


def to_signed(value, bits):
    """bits 비트짜리 2의 보수 값을 부호 있는 정수로 바꾼다. 예) to_signed(0xFE, 8) -> -2"""
    if value & (1 << (bits - 1)):        # 맨 위 비트(부호 비트)가 1이면 음수
        value -= 1 << bits
    return value


def decode_float32(raw):
    """IEEE 11073 32비트 FLOAT(4바이트, 리틀 엔디언)를 float로 바꾼다.

    상위 8비트 = 지수(exponent, 부호 있음), 하위 24비트 = 가수(mantissa, 부호 있음)
    값 = 가수 x 10^지수
    """
    if len(raw) != 4:
        raise ValueError("FLOAT는 4바이트여야 한다")
    word = int.from_bytes(raw, "little")      # 리틀 엔디언: 첫 바이트가 가장 낮은 자리
    mantissa_raw = word & 0xFFFFFF            # 하위 24비트
    exponent = to_signed(word >> 24, 8)       # 상위 8비트
    if exponent == 0 and mantissa_raw in FLOAT_SPECIAL:
        return FLOAT_SPECIAL[mantissa_raw]
    mantissa = to_signed(mantissa_raw, 24)
    if exponent >= 0:
        return float(mantissa * 10 ** exponent)
    return mantissa / 10 ** (-exponent)       # 정수로 나누면 반올림 오차가 가장 작다


def decode_date_time(raw):
    """Date Time(7바이트)을 datetime으로 바꾼다. 연·월·일이 0(모름)이면 None."""
    if len(raw) != 7:
        raise ValueError("Date Time은 7바이트여야 한다")
    year = int.from_bytes(raw[0:2], "little")
    month, day, hour, minute, second = raw[2], raw[3], raw[4], raw[5], raw[6]
    if year == 0 or month == 0 or day == 0:
        return None
    return datetime(year, month, day, hour, minute, second)


def encode_date_time(dt):
    """datetime을 Date Time(7바이트)으로 바꾼다. 0x2A08에 쓸 때 사용한다."""
    return bytes([dt.year & 0xFF, (dt.year >> 8) & 0xFF,
                  dt.month, dt.day, dt.hour, dt.minute, dt.second])


@dataclass
class TemperatureMeasurement:
    flags: int
    value: float              # 장치가 보낸 값 그대로(unit 단위)
    unit: str                 # "C" 또는 "F"
    celsius: float            # 섭씨로 맞춘 값(저장·비교용)
    timestamp: datetime = None
    temp_type: int = None
    extra: bytes = b""        # 규격 밖의 남는 바이트(있으면 기록만 해 둔다)

    @property
    def temp_type_name(self):
        if self.temp_type is None:
            return None
        return TEMP_TYPE_NAMES.get(self.temp_type, "Reserved(%d)" % self.temp_type)


def parse_temperature_measurement(data):
    """Temperature Measurement(0x2A1C) 값 한 개를 해석한다.

    구조: Flags(1) + 온도 FLOAT(4) + [Time Stamp(7)] + [Temperature Type(1)]
    대괄호 항목은 Flags의 해당 비트가 1일 때만 있다.
    """
    data = bytes(data)
    if len(data) < 5:
        raise ValueError("길이가 너무 짧다: %d바이트" % len(data))
    flags = data[0]
    value = decode_float32(data[1:5])
    pos = 5
    timestamp = None
    temp_type = None
    if flags & FLAG_TIMESTAMP:
        if len(data) < pos + 7:
            raise ValueError("Time Stamp 비트가 1인데 7바이트가 없다")
        timestamp = decode_date_time(data[pos:pos + 7])
        pos += 7
    if flags & FLAG_TEMP_TYPE:
        if len(data) < pos + 1:
            raise ValueError("Temperature Type 비트가 1인데 1바이트가 없다")
        temp_type = data[pos]
        pos += 1
    unit = "F" if flags & FLAG_FAHRENHEIT else "C"
    celsius = (value - 32.0) * 5.0 / 9.0 if unit == "F" else value
    return TemperatureMeasurement(flags, value, unit, celsius,
                                  timestamp, temp_type, data[pos:])
