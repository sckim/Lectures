#pragma warning(disable: 4996)

#include <stdio.h>

int main(void)
{
	int i;
	FILE* fp;
	int ch;

	fp = fopen("readme.txt", "r");
	ch = getc(fp);
	while (ch != EOF) {
		putchar(ch);
		ch = getc(fp);
	}
	return 0;
}
