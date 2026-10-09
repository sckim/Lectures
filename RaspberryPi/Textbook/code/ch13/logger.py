#!/usr/bin/env python3
"""logger.py : 실습 13-4  여러 체온계의 온도를 동시에 받아 SQLite 데이터베이스에 저장한다

사용법 : python logger.py --name TS100                    # 이름이 TS100으로 시작하는 장치 모두
         python logger.py --address AA:.. --address BB:..  # 주소를 직접 지정(여러 개 가능)
         python logger.py --name TS100 --db ~/ch13/temperature.db
끝내기 : Ctrl+C 또는 systemctl stop gateway (SIGTERM)
원본 : TS100-Gitbook 4.1.3절 "데이터 저장", 4.1.4절 "2대 이상 기기 연결"
       (tkinter 화면 대신 장치마다 asyncio 태스크 하나, 수신 시각·원시 바이트까지 저장)
"""

import argparse
import asyncio
import signal
import sqlite3
from datetime import datetime

from bleak import BleakScanner

from hts import HTS_SERVICE_UUID
from read_temp import monitor

SCHEMA = """
CREATE TABLE IF NOT EXISTS temperature (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    received_at  TEXT    NOT NULL,          -- Pi가 받은 시각(ISO 8601, 지역 시각)
    device_name  TEXT,
    address      TEXT    NOT NULL,
    celsius      REAL,                      -- 섭씨로 맞춘 값
    unit         TEXT,                      -- 장치가 보낸 단위 C/F
    device_time  TEXT,                      -- 장치가 보낸 Time Stamp(있을 때만)
    raw_hex      TEXT    NOT NULL,          -- 받은 바이트 그대로(나중에 다시 해석할 수 있게)
    uploaded     INTEGER NOT NULL DEFAULT 0 -- 실습 13-6 업로더가 1로 바꾼다
);
CREATE INDEX IF NOT EXISTS idx_temperature_time ON temperature(received_at);
"""


def open_db(path):
    conn = sqlite3.connect(path, timeout=10)  # 업로더가 동시에 읽어도 10초까지 기다린다
    conn.executescript(SCHEMA)
    return conn


async def discover_targets(name, scan_time):
    """이름 앞부분(없으면 0x1809 광고)으로 장치 주소 목록을 만든다."""
    found = await BleakScanner.discover(timeout=scan_time, return_adv=True)
    targets = []
    for address, (device, adv) in found.items():
        dev_name = adv.local_name or device.name or ""
        if (name and dev_name.startswith(name)) or \
           (not name and HTS_SERVICE_UUID in adv.service_uuids):
            targets.append(address)
    return sorted(targets)


async def main():
    parser = argparse.ArgumentParser(description="BLE 체온 게이트웨이 로거 (13장)")
    parser.add_argument("--address", action="append", default=[], help="장치 주소(반복 가능)")
    parser.add_argument("--name", default="", help="장치 이름 앞부분 (예: TS100)")
    parser.add_argument("--db", default="temperature.db", help="SQLite 파일 경로")
    parser.add_argument("--scan-time", type=float, default=10.0, help="처음 찾기 시간(초)")
    parser.add_argument("--set-time", action="store_true", help="연결 때 0x2A08에 현재 시각 쓰기")
    args = parser.parse_args()

    conn = open_db(args.db)
    count = 0

    def save(device, m, raw):                     # 모든 장치의 콜백이 이 함수를 부른다
        nonlocal count
        now = datetime.now().isoformat(timespec="seconds")
        conn.execute(
            "INSERT INTO temperature (received_at, device_name, address, celsius, unit,"
            " device_time, raw_hex) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (now, device.name, device.address, m.celsius, m.unit,
             m.timestamp.isoformat() if m.timestamp else None, raw.hex()))
        conn.commit()
        count += 1
        print("%s  %-14s %.2f C  (저장 %d건)" % (now, device.name or device.address,
                                               m.celsius, count))

    stop = asyncio.Event()
    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)

    targets = args.address or await discover_targets(args.name, args.scan_time)
    if not targets:
        print("대상 장치를 찾지 못했다. 장치가 광고 중인지 확인한다.")
        conn.close()
        raise SystemExit(1)                       # systemd의 Restart=on-failure가 다시 띄운다
    print("대상 %d대: %s" % (len(targets), ", ".join(targets)))

    # 장치마다 monitor() 하나씩: 한 대가 끊겨도 나머지는 계속 받는다.
    # 찾기·연결은 한 번에 한 장치만 하도록 잠금 하나를 함께 쓴다(BlueZ 충돌 방지)
    connect_lock = asyncio.Lock()
    await asyncio.gather(*(monitor(addr, "", save, stop, args.set_time,
                                   connect_lock=connect_lock)
                           for addr in targets))
    conn.close()
    print("종료: 이번 실행에서 %d건 저장" % count)


if __name__ == "__main__":
    asyncio.run(main())
