#!/usr/bin/env python3
"""report.py : 실습 13-4  logger.py가 모은 데이터를 표로 보고, CSV로 내보내고, 그래프(PNG)로 그린다

사용법 : python report.py summary                    # 장치별 건수·최저·최고·평균
         python report.py csv out.csv                # CSV 파일로 내보내기(엑셀에서 열 수 있다)
         python report.py plot out.png --last 300    # 최근 300건을 그래프로(matplotlib 필요)
         (공통 옵션) --db temperature.db
원본 : TS100-Gitbook 4.1.3절 "데이터 그래프로 그리기"(plt.ion 실시간 창)를
       화면 없이도(SSH, systemd) 동작하도록 PNG 파일 저장 방식으로 바꿈
"""

import argparse
import csv
import sqlite3


def cmd_summary(conn, args):
    rows = conn.execute(
        "SELECT COALESCE(device_name, address), COUNT(*), MIN(celsius), MAX(celsius),"
        " AVG(celsius), MIN(received_at), MAX(received_at)"
        " FROM temperature GROUP BY address ORDER BY 1").fetchall()
    print("%-14s %6s %6s %6s %6s  %s ~ %s" % ("장치", "건수", "최저", "최고", "평균", "처음", "마지막"))
    for name, n, lo, hi, avg, first, last in rows:
        print("%-14s %6d %6.2f %6.2f %6.2f  %s ~ %s" % (name, n, lo, hi, avg, first, last))


def cmd_csv(conn, args):
    cur = conn.execute("SELECT id, received_at, device_name, address, celsius, unit,"
                       " device_time FROM temperature ORDER BY id")
    # utf-8-sig: 엑셀이 한글·BOM을 알아보도록 BOM을 붙인다
    with open(args.out, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.writer(f)
        writer.writerow([d[0] for d in cur.description])     # 첫 줄: 열 이름
        n = 0
        for row in cur:
            writer.writerow(row)
            n += 1
    print("%s에 %d건을 썼다" % (args.out, n))


def cmd_plot(conn, args):
    import matplotlib
    matplotlib.use("Agg")                  # 화면(X window) 없이 파일로만 그린다
    import matplotlib.pyplot as plt
    from datetime import datetime

    rows = conn.execute("SELECT received_at, COALESCE(device_name, address), celsius"
                        " FROM temperature ORDER BY id DESC LIMIT ?", (args.last,)).fetchall()
    series = {}
    for t, name, c in reversed(rows):      # 오래된 것부터
        series.setdefault(name, ([], []))
        series[name][0].append(datetime.fromisoformat(t))
        series[name][1].append(c)

    fig, ax = plt.subplots(figsize=(9, 4))
    for name, (xs, ys) in series.items():
        ax.plot(xs, ys, marker=".", linewidth=1, label=name)
    ax.set_xlabel("time")
    ax.set_ylabel("temperature (deg C)")
    ax.set_title("BLE thermometer (last %d samples)" % len(rows))
    ax.grid(True, alpha=0.3)
    if series:
        ax.legend()
    fig.autofmt_xdate()
    fig.tight_layout()
    fig.savefig(args.out, dpi=100)
    print("%s 저장 (%d건)" % (args.out, len(rows)))


def main():
    parser = argparse.ArgumentParser(description="온도 데이터 보고서 (13장)")
    parser.add_argument("--db", default="temperature.db")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("summary")
    p = sub.add_parser("csv")
    p.add_argument("out")
    p = sub.add_parser("plot")
    p.add_argument("out")
    p.add_argument("--last", type=int, default=300)
    args = parser.parse_args()

    conn = sqlite3.connect(args.db)
    {"summary": cmd_summary, "csv": cmd_csv, "plot": cmd_plot}[args.cmd](conn, args)
    conn.close()


if __name__ == "__main__":
    main()
