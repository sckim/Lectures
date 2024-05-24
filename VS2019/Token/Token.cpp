#pragma warning(disable:4996)

#include <stdio.h>
#include <string.h>

int main(void)
{
	char* token;
	char string[80] = "a string, of, ,tokens\0,after null terminator";

	/* the string pointed to by string is broken up into the tokens
	   "a string", " of", " ", and "tokens" ; the null terminator (\0)
	   is encountered and execution stops after the token "tokens"     */
	token = strtok(string, ",");
	do
	{
		printf("token: %s\n", token);
	} while (token = strtok(NULL, ","));
}