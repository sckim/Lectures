#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_TERMS 100

typedef struct {
    char term[20];
    int used;
} Implicant;

int hammingDistance(char *a, char *b) {
    int count = 0;
    while (*a && *b) {
        if (*a++ != *b++) count++;
    }
    return count;
}

char* combineTerms(char *a, char *b) {
    static char result[20];
    strcpy(result, a);
    if (hammingDistance(a, b) == 1) {
        for (int i = 0; a[i] != '\0'; i++) {
            if (a[i] != b[i]) result[i] = '-';
        }
        return result;
    }
    return NULL;
}

void findPrimeImplicants(Implicant terms[], int n, Implicant primes[]) {
    int p_index = 0;
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            char *combined = combineTerms(terms[i].term, terms[j].term);
            if (combined) {
                primes[p_index].used = 0;
                strcpy(primes[p_index++].term, combined);
                terms[i].used = terms[j].used = 1;
            }
        }
    }
    // Adding terms that cannot be combined anymore
    for (int i = 0; i < n; i++) {
        if (!terms[i].used) {
            strcpy(primes[p_index].term, terms[i].term);
            primes[p_index++].used = 0;
        }
    }
}

int main() {
    Implicant terms[MAX_TERMS] = {
        {"0000", 0}, {"0001", 0}, {"0011", 0}, {"0111", 0}, {"1111", 0}
    };
    Implicant primes[MAX_TERMS];

    findPrimeImplicants(terms, 5, primes);
    
    printf("Prime Implicants:\n");
    for (int i = 0; i < MAX_TERMS && primes[i].term[0]; i++) {
        if (!primes[i].used)
            printf("%s\n", primes[i].term);
    }
    
    return 0;
}
