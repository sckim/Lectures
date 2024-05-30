// Datalength.cpp : 이 파일에는 'main' 함수가 포함됩니다. 거기서 프로그램 실행이 시작되고 종료됩니다.
//
#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
// #define printf_s printf
// #define fopen_s fopen

int main()
{
	char str1 = '1';
	char str2[10] = "sckim";
	int  iBuffer[2] = { 1, -1 };
	float fValue = 12.125;
	FILE* fp;

	printf("bool : %d\r\n", sizeof(bool));
	printf("char : %d\r\n", sizeof(char));
	printf("int : %d\r\n", sizeof(int));
	printf("short : %d\r\n", sizeof(short));
	printf("long : %d\r\n", sizeof(long));
	printf("float : %d\r\n", sizeof(float));
	printf("double : %d\r\n", sizeof(double));

	fp = fopen("data.bin", "wb");
	//       => fp = fopen("data.bin", "wb");
		//save '1' as character
	fwrite(&str1, sizeof(char), 1, fp);
	//save 'sckim' as character array (string)
	fwrite(str2, sizeof(char), 10, fp);
	//save 1 and -1 as integer
	fwrite(iBuffer, sizeof(int), 2, fp);
	iBuffer[0] = 0x12345678;
	iBuffer[1] = -0x12345678;
	//save 0x12345678 and -0x12345678 (Hexadecimaal) as integer
	fwrite(iBuffer, sizeof(int), 2, fp);
	// save 12.125 as floating number
	fwrite(&fValue, sizeof(float), 1, fp);
	fValue = -fValue;
	// save -12.125 as floating number
	fwrite(&fValue, sizeof(float), 1, fp);
	fclose(fp);
}
