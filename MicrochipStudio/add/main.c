/*
 * add.c
 *
 * Created: 2024-05-24 오후 11:55:54
 * Author : Soochan Kim
 */ 

#include <avr/io.h>

//int add(int a, int b)
//{
//	return a+b;
//}

int main(void)
{
	int i = 0;
	char a[80] = "Hankyong National University";
	
	for(i=0; i<80; i++) {
		a[i]= a[i]+i;
	}	
	
	return 1;
}

