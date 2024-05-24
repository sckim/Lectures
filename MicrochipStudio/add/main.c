/*
 * add.c
 *
 * Created: 2024-05-24 오후 11:55:54
 * Author : Soochan Kim
 */ 

#include <avr/io.h>

int add(int a, int b)
{
	return a+b;
}

int main(void)
{
	int a = 10;
	int b = 2;
	
	b = add(a, b);
	
	return b;
}

