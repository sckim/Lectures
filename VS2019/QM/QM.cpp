//-------------------------------------------------------------------------------------------------------------
// Quine-McCluskey Algorithm
// =========================
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

#define TRUE 1
#define FALSE 0
#define MAXVARS 7
#define MAX 2048

// Global variables
int minterm[MAX][MAX];     // 1st: item, 2nd : reduction step
int mintermMask[MAX][MAX]; // mask of minterm, 2nd: reductin step
int used[MAX][MAX];        // used or not in reduction step

int result[MAX];    // valid minterm flag 
int primeMask[MAX]; // mintermMask for prime implicants
int prime[MAX];     // prime implicant
int ePrime[MAX];    // essential prime implicant (TRUE/FALSE)
int nePrime[MAX];   // non essential prime implicant

int numOfVariables = 0; // Number of Variables

// Count all set bits of the integer number
// int countSetbits(unsigned x)
// { // Taken from book "Hackers Delight"
//     x = x - ((x >> 1) & 0x55555555);
//     x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
//     x = (x + (x >> 4)) & 0x0F0F0F0F;
//     x = x + (x >> 8);
//     x = x + (x >> 16);
//     return x & 0x0000003F;
// }

// Function to count the number of 1s in the binary representation of an integer
int countSetbits(unsigned int numOfVariables)
{
    int count = 0;
    while (numOfVariables)
    {
        count += numOfVariables & 0x01; // Increment count if the least significant bit is 1
        numOfVariables >>= 1;           // Right shift the number to check the next bit
    }
    return count;
}

// Calculate hamming weight/distance of two integer numbers
int getHammingDistance(int v1, int v2)
{
    return countSetbits(v1 ^ v2); // xor
}

// Output upper part of term in console
void upperTerm(int bitfield, int mintermMask, int numOfVariables)
{
    if (mintermMask)
    {
        int z;
        for (z = numOfVariables; z>=0; z--)
        {
            if (mintermMask & (1 << z))
            {
                if (bitfield & (1 << z))
                    printf(" ");
                else
                    printf("_");
            }
        }
    }
}

// Output lower part of term in console
void lowerTerm(int mintermMask, int numOfVariables)
{
    if (mintermMask)
    {
        int z;
        for (z = numOfVariables; z>=0; z--)
        {
            if (mintermMask & (1 << z))
            {
                //                printf("%c", 'A' + z);
                printf("%c", 'Z' - z);
            }
        }
    }
}

// Output a term to console
void outputTerm(int bitfield, int mintermMask, int numOfVariables)
{
    printf("[%d] \r\n", bitfield);
    upperTerm(bitfield, mintermMask, numOfVariables);
    if (mintermMask)
        printf("\n");
    lowerTerm(mintermMask, numOfVariables);
}

// Determines whether "value" contains "part"
int contains(int value, int mintermMask, int part, int partmask)
{
    if ((value & partmask) == (part & partmask))
    {
        if ((mintermMask & partmask) == partmask)
            return TRUE;
    }
    return FALSE;
}

void initializeVariables(void)
{
    // Fill all arrays with default values
    for (int x = 0; x < MAX; x++)
    {
        primeMask[x] = 0;
        prime[x] = 0;
        result[x] = FALSE;
        ePrime[x] = FALSE;
        nePrime[x] = TRUE;
        for (int y = 0; y < MAX; y++)
        {
            mintermMask[x][y] = 0;
            minterm[x][y] = 0;
            used[x][y] = FALSE;
        }
    }
}

int getMinterms(void)
{
    printf("Enter number of variables: ");
    scanf(" %d", &numOfVariables);
    if (numOfVariables > MAXVARS)
    {
        fprintf(stderr, "ERROR: Number of variables too big!\n");
        return 0;
    }
    if (numOfVariables < 1)
    {
        fprintf(stderr, "ERROR: Number of variables must be at least 1!\n");
        return 0;
    }

    printf("Please enter desired results: (0 or 1)\r\n");
    for (int x = 0; x < (1 << numOfVariables); x++)
    {
        int value = 0;
        outputTerm(x, (1 << numOfVariables) - 1, numOfVariables);
        printf(" = ");
        scanf(" %d", &value);
        if (value)
        {
            mintermMask[x][0] = ((1 << numOfVariables) - 1);
            minterm[x][0] = x;
            result[x] = TRUE;
        }
        printf("\n");
    }

    return 1;
}

void printVariables(int len, int step)
{
        printf("\r\nstep = %d\r\n", step);
        for (int x = 0; x < len; x++)
        {
            printf("minterm mask = 0x%X, ", mintermMask[x][step]);
            printf("minterm = 0x%X, ", minterm[x][step]);
            printf("used = %d, ", used[x][step]);
            printf("primeMask = 0x%X, ", primeMask[step]);
            printf("prime = 0x%X, ", prime[x]);
            printf("ePrime = 0x%X, ", ePrime[x]);
            printf("nePrime = 0x%X, ", nePrime[x]);
            printf("result = %d\r\n", result[x]);
        }
 
    printf("==========================");
}

// Output of essential and required prime implicants 
void printReducedEquation(int prime_count)
{
    int count = 0;
    for (int x = 0; x < prime_count; x++)
    {
        if (ePrime[x] == TRUE)
        {
            if (count > 0)
                printf("   ");
            upperTerm(prime[x], primeMask[x], numOfVariables);
            count++;
        }
        else if ((ePrime[x] == FALSE) && (nePrime[x] == TRUE))
        {
            if (count > 0)
                printf("   ");
            upperTerm(prime[x], primeMask[x], numOfVariables);
            count++;
        }
    }
    printf("\n");
    count = 0;
    for (int x = 0; x < prime_count; x++)
    {
        if (ePrime[x] == TRUE)
        {
            if (count > 0)
                printf(" + ");
            lowerTerm(primeMask[x], numOfVariables);
            count++;
        }
        else if ((ePrime[x] == FALSE) && (nePrime[x] == TRUE))
        {
            if (count > 0)
                printf(" + ");
            lowerTerm(primeMask[x], numOfVariables);
            count++;
        }
    }
}

int main()
{
    int reduction = 0; // reduction step
    int prime_count = 0;
    int madeReduction = FALSE;

    int cur = 0;

    int term = 0;
    int termMask = 0;
    int found = 0;
    int count = 0;
    int lastPrime = 0;
    int res = 0; // actual result

    initializeVariables();
    // get minterms
    getMinterms();
    printf("\r\nShow initial variables");
    printVariables((1 << numOfVariables), 0);

    printf("\r\nShow recductions step : %d", reduction);
    for (reduction = 0; reduction < MAX; reduction++)
    {
        cur = 0;
        madeReduction = FALSE;
        for (int y = 0; y < MAX; y++)
        {
            for (int x = 0; x < MAX; x++)
            {
                if ((mintermMask[x][reduction]) && (mintermMask[y][reduction]))
                {
                    if (countSetbits(mintermMask[x][reduction]) > 1)  // Check if the number of 1's is 2 or more 
                    { // Do not allow complete removal (problem if all terms are 1)
                        if ((getHammingDistance(minterm[x][reduction] & mintermMask[x][reduction], minterm[y][reduction] & mintermMask[y][reduction]) == 1) && (mintermMask[x][reduction] == mintermMask[y][reduction]))
                        {
                            // Simplification only possible if 1 bit differs
                            term = minterm[x][reduction]; // could be minterm x or y
                            // e.g.:
                            // 1110
                            // 1111
                            // Should result in mintermMask of 1110
                            termMask = mintermMask[x][reduction] ^ (minterm[x][reduction] ^ minterm[y][reduction]);
                            term &= termMask;

                            found = FALSE;
                            for (int z = 0; z < cur; z++)
                            {
                                if ((minterm[z][reduction + 1] == term) && (mintermMask[z][reduction + 1] == termMask))
                                {
                                    found = TRUE;
                                }
                            }

                            if (found == FALSE)
                            {
                                minterm[cur][reduction + 1] = term;
                                mintermMask[cur][reduction + 1] = termMask;
                                cur++;
                            }
                            used[x][reduction] = TRUE;
                            used[y][reduction] = TRUE;
                            madeReduction = TRUE;
                        }
                    }
                }
            }
        }
        printVariables((1 << numOfVariables), reduction);

        if (madeReduction == FALSE)
            break; // exit loop early (speed optimisation)
    }

    prime_count = 0;
    printf("\r\nShow prime results");
    for (reduction = 0; reduction < MAX; reduction++)
    {
        for (int x = 0; x < MAX; x++)
        {
            // Determine all not used minterms
            if ((used[x][reduction] == FALSE) && (mintermMask[x][reduction]))
            {
                // Check if the same prime implicant is already in the list
                found = FALSE;
                for (int z = 0; z < prime_count; z++)
                {
                    if (((prime[z] & primeMask[z]) == (minterm[x][reduction] & mintermMask[x][reduction])) && (primeMask[z] == mintermMask[x][reduction]))
                        found = TRUE;
                }
                if (found == FALSE)
                {
                    // outputTerm(minterm[x][reduction], mintermMask[x][reduction], numOfVariables);
                    // printf("\n");
                    primeMask[prime_count] = mintermMask[x][reduction];
                    prime[prime_count] = minterm[x][reduction];
                    prime_count++;
                }
            }
        }
    }
   
    // find essential and not essential prime implicants
    // all alle prime implicants are set to "not essential" so far
    for (int y = 0; y < (1 << numOfVariables); y++)
    { // for all minterms
        count = 0;
        lastPrime = 0;
        if (mintermMask[y][0])
        {
            for (int x = 0; x < prime_count; x++)
            { // for all prime implicants
                if (primeMask[x])
                {
                    // Check if the minterm contains prime implicant  /  the ?erpr?en, ob der Minterm den Primimplikanten beinhaltet
                    if (contains(minterm[y][0], mintermMask[y][0], prime[x], primeMask[x]))
                    {
                        count++;
                        lastPrime = x;
                    }
                }
            }
            // If count = 1 then it is a essential prime implicant
            if (count == 1)
            {
                ePrime[lastPrime] = TRUE;
            }
        }
    }
    printf("Show essential prime results");
    // printVariables((1 << numOfVariables), 4);

    // successively testing if it is possible to remove prime implicants from the rest matrix
    for (int z = 0; z < prime_count; z++)
    {
        if (primeMask[z])
        {
            if ((ePrime[z] == FALSE))
            {                       // && (rwprim[z] == TRUE))
                nePrime[z] = FALSE; // mark as "not essential"
                for (int y = 0; y < (1 << numOfVariables); y++)
                { // for all possibilities
                    res = 0;
                    for (int x = 0; x < prime_count; x++)
                    {
                        if ((ePrime[x] == TRUE) || (nePrime[x] == TRUE))
                        { // essential prime implicant or marked as required  /  wesentlicher Primimplikant oder als ben?igt markiert
                            if ((y & primeMask[x]) == (prime[x] & primeMask[x]))
                            { // All bits must be 1  /  Es m?sen alle Bits auf einmal auf 1 sein (da And-Verkn?fung)
                                res = 1;
                                break;
                            }
                        }
                    }
                    // printf(" %d\t%d\n", result, result[y]);
                    if (res == result[y])
                    { // compare calculated result with input value /  Berechnetes ergebnis mit sollwert vergleichen
                      // printf("not needed\n"); //prime implicant not required  /  Primimplikant wird nicht ben?igt
                    }
                    else
                    {
                        // printf("needed\n");
                        nePrime[z] = TRUE; // prime implicant required  /  Primimplikant wird doch ben?igt
                    }
                }
            }
        }
    }

    printf("Show final results");
    //printVariables((1 << numOfVariables), 4);

    printf("\nResult:\r\n");
    printReducedEquation(prime_count);
    printf("\n");
    return 0;
}
