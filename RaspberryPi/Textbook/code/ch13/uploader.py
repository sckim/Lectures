#!/usr/bin/env python3
"""uploader.py : 실습 13-6(선택)  아직 올리지 않은 측정값을 HTTPS로 클라우드 API에 보낸다

설정은 코드가 아니라 환경 변수로 받는다(비밀번호·토큰을 소스에 적지 않는다).
  GATEWAY_UPLOAD_URL    올릴 주소. 반드시 https://  (예: https://example.invalid/api/temperature)
  GATEWAY_API_TOKEN     (선택) 인증 토큰. Authorization: Bearer <토큰> 헤더로 보낸다
  GATEWAY_UPLOAD_METHOD (선택) POST(기본, JSON 본문) 또는 GET(TS100-Gitbook 5.10절 API 형식)
사용법 : python uploader.py --once          # 한 번 올리고 끝(systemd 타이머용)
         python uploader.py --interval 60   # 60초마다 반복
원본 : TS100/main_cloud.py send_cloud() (주소를 코드에 적던 방식을 환경 변수로 바꾸고,
       실패한 건은 DB에 남겨 두었다가 다음에 다시 보내도록 고침)
"""

import argparse
import json
import os
import sqlite3
import sys
import time
import urllib.error
import urllib.parse
import urllib.request


def load_config():
    url = os.environ.get("GATEWAY_UPLOAD_URL", "")
    if not url.startswith("https://"):
        sys.exit("GATEWAY_UPLOAD_URL이 없거나 https://로 시작하지 않는다")
    method = os.environ.get("GATEWAY_UPLOAD_METHOD", "POST").upper()
    if method not in ("POST", "GET"):
        sys.exit("GATEWAY_UPLOAD_METHOD는 POST 또는 GET")
    return url, os.environ.get("GATEWAY_API_TOKEN", ""), method


def send_one(url, token, method, row):
    """측정값 한 건을 보낸다. 성공(2xx)이면 True."""
    rid, received_at, name, address, celsius = row
    record = {"name": name or address, "address": address,
              "temperature": round(celsius, 2), "date": received_at.replace("T", " ")}
    headers = {"User-Agent": "ch13-gateway"}
    if token:
        headers["Authorization"] = "Bearer " + token
    if method == "GET":                     # 쿼리 문자열: ?name=..&temperature=..&date=..
        query = urllib.parse.urlencode({k: record[k] for k in ("name", "temperature", "date")})
        req = urllib.request.Request(url + "?" + query, headers=headers, method="GET")
    else:                                   # JSON 본문
        headers["Content-Type"] = "application/json"
        req = urllib.request.Request(url, data=json.dumps(record).encode("utf-8"),
                                     headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return 200 <= resp.status < 300
    except urllib.error.HTTPError as e:     # 서버가 4xx/5xx로 답함
        print("id=%d 거부됨: HTTP %d" % (rid, e.code))
    except (urllib.error.URLError, TimeoutError, OSError) as e:   # 네트워크 문제
        print("id=%d 전송 실패: %s" % (rid, e))
    return False


def upload_pending(db, url, token, method, batch):
    conn = sqlite3.connect(db, timeout=10)
    rows = conn.execute("SELECT id, received_at, device_name, address, celsius FROM temperature"
                        " WHERE uploaded = 0 AND celsius IS NOT NULL ORDER BY id LIMIT ?",
                        (batch,)).fetchall()
    ok = 0
    for row in rows:
        if not send_one(url, token, method, row):
            break                           # 실패하면 멈추고 다음 번에 그 건부터 다시
        conn.execute("UPDATE temperature SET uploaded = 1 WHERE id = ?", (row[0],))
        conn.commit()
        ok += 1
    conn.close()
    print("올림 %d건 / 대기 %d건" % (ok, len(rows)))
    return ok


def main():
    parser = argparse.ArgumentParser(description="측정값 클라우드 업로더 (13장, 선택)")
    parser.add_argument("--db", default="temperature.db")
    parser.add_argument("--batch", type=int, default=100, help="한 번에 올릴 최대 건수")
    parser.add_argument("--once", action="store_true", help="한 번만 실행")
    parser.add_argument("--interval", type=float, default=60.0, help="반복 간격(초)")
    args = parser.parse_args()

    url, token, method = load_config()
    print("업로드 대상: %s (%s, 토큰 %s)" % (urllib.parse.urlsplit(url).netloc, method,
                                         "있음" if token else "없음"))   # 토큰 값은 출력하지 않는다
    while True:
        upload_pending(args.db, url, token, method, args.batch)
        if args.once:
            break
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
