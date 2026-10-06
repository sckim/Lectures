#!/usr/bin/env python3
"""async_demo.py : 13.14절  asyncio 맛보기 - 요리사 한 명이 기다리는 동안 다른 일을 한다

실행 : python3 async_demo.py         (bleak도 블루투스도 필요 없다)
비교 : 1) await asyncio.sleep() -> 세 작업이 겹쳐서 약 3초에 끝난다
       2) time.sleep()          -> 이벤트 루프가 3초 동안 멈춰 주문이 시작조차 못 한다(하면 안 되는 예)
"""

import asyncio
import time

T0 = time.monotonic()


def log(msg):
    print("%4.1f초  %s" % (time.monotonic() - T0, msg))


async def boil_noodles():                  # 라면 물 끓이기: 오래 기다리는 일
    log("라면: 물 올림")
    await asyncio.sleep(3)                 # 기다리는 동안 요리사는 다른 일을 한다
    log("라면: 완성")


async def take_order(table):              # 주문 받기: 짧게 기다리는 일
    log("주문: %d번 테이블 주문 받는 중" % table)
    await asyncio.sleep(1.5)
    log("주문: %d번 테이블 주문 완료" % table)


async def blocking_noodles():             # 나쁜 예: time.sleep은 루프 전체를 멈춘다
    log("라면(막힘): 물 올리고 냄비 앞에서 3초 서 있기")
    time.sleep(3)                          # await가 없으므로 다른 작업에 차례가 가지 않는다
    log("라면(막힘): 완성")


async def main():
    global T0
    print("=== 1) await asyncio.sleep: 협력해서 번갈아 실행 ===")
    T0 = time.monotonic()
    await asyncio.gather(boil_noodles(), take_order(1), take_order(2))
    log("모두 끝")

    print("=== 2) time.sleep: 한 작업이 루프를 붙잡음 ===")
    T0 = time.monotonic()
    await asyncio.gather(blocking_noodles(), take_order(1), take_order(2))
    log("모두 끝")


if __name__ == "__main__":
    asyncio.run(main())
