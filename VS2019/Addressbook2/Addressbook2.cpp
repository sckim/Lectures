#pragma warning (disable : 4996)

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define INIT_CAPACITY 3 //배열 재할당위해 작은값으로 지정 
#define BUFFER_SIZE 50

char** names;
char** numbers;
int n = 0;
int capacity = INIT_CAPACITY;  //size of arrays

char delim[] = " ";

void help(void);
void add(char* name, char* number);
int search(char* name);
void find(char* name);
void status(void);
void remove(char* name);
void load(char* fileName);
void save(char* fileName);
void reallocate(void);

int read_line(char str[], int limit)
{
	int ch, i = 0;

	while ((ch = getchar()) != '\n') {
		if (i < limit - 1)
			str[i++] = ch;
	}
	str[i] = '\0';

	return i;
} //line단위 입력은 fgets, getline등의 함수들을 이용할 수 있다.

void init_directory() {
	names = (char**)malloc(INIT_CAPACITY * sizeof(char*));
	numbers = (char**)malloc(INIT_CAPACITY * sizeof(char*));
}

void process_command() {
	char command_line[BUFFER_SIZE];
	char* command, * argument1, * argument2;

	while (1) {
		printf("$ ");

		if (read_line(command_line, BUFFER_SIZE) <= 0)
			continue;
		command = strtok(command_line, delim);
		if (command == NULL) continue;
		if (strcmp(command, "load") == 0) {
			argument1 = strtok(NULL, delim);
			//load filename
			if (argument1 == NULL) {
				printf("File name required.\n");
				continue;
			}
			load(argument1);
		}

		else if (strcmp(command, "add") == 0) {
			argument1 = strtok(NULL, delim);
			argument2 = strtok(NULL, delim);
			//add sckim 01030393632
			if (argument1 == NULL || argument2 == NULL) {
				printf("Invalid arguments.\n");
				continue;
			}
			add(argument1, argument2);
			printf("%s was added successfully.\n", argument1);
		}

		else if (strcmp(command, "find") == 0) {
			argument1 = strtok(NULL, delim);
			if (argument1 == NULL) {
				printf("Invalid arguments.\n");
				continue;
			}
			find(argument1);
		}
		else if (strcmp(command, "status") == 0)
			status();
		else if (strcmp(command, "remove") == 0) {
			argument1 = strtok(NULL, delim);
			if (argument1 == NULL) {
				printf("Invalid arguments.\n");
				continue;
			}
			remove(argument1);
		}
		else if (strcmp(command, "save") == 0) {

			argument1 = strtok(NULL, delim);
			argument2 = strtok(NULL, delim);

			if (argument1 == NULL || strcmp("as", argument1) != 0
				|| argument2 == NULL) {
				printf("Invalid command format.\n");
				continue;
			}

			save(argument2);
		}
		else if (strcmp(command, "help") == 0)
			help();
		else if (strcmp(command, "exit") == 0) 
			break;	
	}
}

void load(char* fileName) {
	char buf1[BUFFER_SIZE];
	char buf2[BUFFER_SIZE];

	FILE* fp = fopen(fileName, "r");
	if (fp == NULL) {
		printf("Open failed.\n");
		return;
	}
	while ((fscanf(fp, "%s", buf1) != EOF)) {
		fscanf(fp, "%s", buf2);
		add(buf1, buf2);
	}
	fclose(fp);
}

void save(char* fileName) {
	int i;
	FILE* fp = fopen(fileName, "w");
	if (fp == NULL) {
		printf("Open failed.\n");
		return;
	}

	for (i = 0; i < n; i++) {
		fprintf(fp, "%s %s\n", names[i], numbers[i]);
	}
	fclose(fp);
}

void remove(char* name) {
	int i = search(name);
	int j = i;

	if (i == -1) {
		printf("No person named '%s' exists.\n", name);
		return;
	}


	for (; j < n - 1; j++) {
		names[j] = names[j + 1];
		numbers[j] = numbers[j + 1];
	}
	n--;
	printf("'%s' was deleted successfully. \n", name);
}

void find(char* name) {
	int index = search(name);
	if (index == -1)
		printf("No person named '%s' exists.\n", name);
	else
		printf("%s\n", numbers[index]);
}


int search(char* name) {
	int i;
	for (i = 0; i < n; i++) {
		if (strcmp(name, names[i]) == 0) {
			return i;
		}
	}
	return -1;
}

void add(char* name, char* number) {
	int i;

	if (n >= capacity)
		reallocate();

	// 아래 배열에서 추가하고자 이름과 비교하여
	// 순서가 높으면 뒤로 하나씩 밀어냄
	i = n - 1;	
	while (i >= 0 && strcmp(names[i], name) > 0) {
		names[i + 1] = names[i];
		numbers[i + 1] = numbers[i];
		i--;
	}
	names[i+1] = strdup(name);
	numbers[i+1] = strdup(number);
	n++;
}

void reallocate(void)
{
	int i;

	capacity *= 2;

	char** tmp1 = (char**)malloc(capacity * sizeof(char*));
	char** tmp2 = (char**)malloc(capacity * sizeof(char*));

	for (i = 0; i < n; i++) {
		tmp1[i] = names[i];
		tmp2[i] = numbers[i];
	}

	free(names);
	free(numbers);

	names = tmp1;
	numbers = tmp2;
}

void help(void)
{
	printf("=====================\n");
	printf("|     Commands      |\n");
	printf("=====================\n");
	printf("add: append name phone_number\n");
	printf("find: search name\n");
	printf("load: read a file\n");
	printf("save: save as data_file\n");
	printf("status: show name and number\n");
	printf("remove: remove name\n");
	printf("exit: quit program\n");
}

void status() {
	int i;
	for (i = 0; i < n; i++)
		printf("%s %s\n", names[i], numbers[i]);
	printf("Total %d person.\n", n);
}

int main() {
	help();
	init_directory();
	process_command();
	return 0;
}