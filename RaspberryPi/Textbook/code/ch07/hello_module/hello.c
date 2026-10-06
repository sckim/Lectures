// SPDX-License-Identifier: GPL-2.0
/*
 * hello.c : 실습 7-4  가장 작은 커널 모듈
 * 빌드 : make                      (Pi에서. linux-headers-rpi-v8 패키지 필요)
 * 실행 : sudo insmod hello.ko who=Pi4  →  sudo dmesg | tail  →  sudo rmmod hello
 */
#include <linux/init.h>      /* __init, __exit 표시 */
#include <linux/module.h>    /* module_init, MODULE_LICENSE 등 */
#include <linux/moduleparam.h>
#include <linux/kernel.h>    /* pr_info */
#include <linux/utsname.h>   /* utsname(): 지금 실행 중인 커널의 이름 정보 */

/* 모듈 매개변수: insmod 할 때 who=이름 으로 바꿀 수 있다 */
static char *who = "student";
module_param(who, charp, 0444);   /* 0444: /sys/module/hello/parameters/who 를 읽기 전용으로 공개 */
MODULE_PARM_DESC(who, "인사할 대상 이름");

/* insmod 때 한 번 실행된다. 0을 돌려주면 "적재 성공" */
static int __init hello_init(void)
{
	pr_info("hello: Hello, %s! (kernel %s)\n", who, utsname()->release);
	return 0;
}

/* rmmod 때 한 번 실행된다 */
static void __exit hello_exit(void)
{
	pr_info("hello: Goodbye, %s!\n", who);
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");                 /* GPL이 아니면 커널이 "tainted" 경고를 남긴다 */
MODULE_AUTHOR("Embedded Systems Class");
MODULE_DESCRIPTION("Chapter 7 hello world kernel module");
