// to solve scanf problem
#pragma warning (disable : 4996)
#include <stdio.h>
#include<string.h>

#define CAPACITY 100	// the number of persons = 100
#define BUFFER_SIZE 20

char* names[CAPACITY];
char* numbers[CAPACITY];
int n = 0;

void help(void);
void add(void);
void find(void);
void status(void);
void del(void);

int main() {
	char command[BUFFER_SIZE];

	help();
	while (1) {
		printf("$ ");
		scanf("%s", command);

		if (strcmp(command, "add") == 0)         //strcmp 0
			add();
		else if (strcmp(command, "find") == 0)
			find();
		else if (strcmp(command, "status") == 0)
			status();
		else if (strcmp(command, "delete") == 0)
			del();
		else if (strcmp(command, "help") == 0)
			help();
		else if (strcmp(command, "exit") == 0)
			break;
	}
	return 0;
}

void help(void)
{
	printf("=====================\n");
	printf("|     Commands      |\n");
	printf("=====================\n");
	printf("add: append name\n");
	printf("find: search name\n");
	printf("status: show name and number\n");
	printf("delete: del name\n");
	printf("exit: quit program\n");
}

void add(void) {
	char buf1[BUFFER_SIZE], buf2[BUFFER_SIZE];
	scanf("%s", buf1);
	scanf("%s", buf2);

	names[n] = strdup(buf1);                //strdup strcpy
											// allocate memory and copy the string
	numbers[n] = strdup(buf2);
	n++;

	printf("%s was added successfully. \n", buf1);
}

void find(void) {
	char buf[BUFFER_SIZE];
	scanf("%s", buf);

	int i;
	for (i = 0; i < n; i++) {
		if (strcmp(buf, names[i]) == 0) {
			printf("%s\n", numbers[i]);
			return;
		}
	}
	printf("No person named '%s' exists.\n", buf);
}

void status(void) {
	int i;
	for (i = 0; i < n; i++)
		printf("%s %s\n", names[i], numbers[i]);
	printf("Total %d person.\n", n);
}

void del(void) {
	char buf[BUFFER_SIZE];
	scanf("%s", buf);

	int i;
	for (i = 0; i < n; i++) {
		if (strcmp(buf, names[i]) == 0) {
			names[i] = names[n - 1];
			numbers[i] = numbers[n - 1];
			n--;
			printf("'%s' was deleted successfully.\n", buf);
			return;
		}
	}
	printf("No person named '%s' exists.\n", buf);
}
