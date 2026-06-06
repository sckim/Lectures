#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "converter.h"

typedef struct {
    int mask;     // bitmask of used variables (1 if variable is present, 0 if it's a 'don't care' -)
    int value;    // value of variables (only bits where mask is 1 are relevant)
    int covered_minterms[MAX_MINTERMS];
    int minterm_count;
    int is_combined;
} Implicant;

// Helper to convert implicant to string
void implicant_to_string(int num_vars, Implicant *imp, char *out) {
    if (imp->mask == 0) {
        strcpy(out, "1"); // Logical true
        return;
    }
    out[0] = '\0';
    for (int i = 0; i < num_vars; i++) {
        int bit = num_vars - 1 - i;
        if ((imp->mask >> bit) & 1) {
            char var_str[4];
            if ((imp->value >> bit) & 1) {
                sprintf(var_str, "%c", 'A' + i);
            } else {
                sprintf(var_str, "%c'", 'A' + i);
            }
            strcat(out, var_str);
        }
    }
}

// QM Algorithm Implementation
void simplify_qm(int num_vars, int *minterms, int count, char *result) {
    if (count == 0) {
        strcpy(result, "0");
        return;
    }
    if (count == (1 << num_vars)) {
        strcpy(result, "1");
        return;
    }

    Implicant prime_implicants[64];
    int pi_count = 0;

    // Current and next stage implicants
    Implicant current[64];
    int current_count = 0;

    for (int i = 0; i < count; i++) {
        current[current_count].mask = (1 << num_vars) - 1;
        current[current_count].value = minterms[i];
        current[current_count].minterm_count = 1;
        current[current_count].covered_minterms[0] = minterms[i];
        current[current_count].is_combined = 0;
        current_count++;
    }

    while (current_count > 0) {
        Implicant next[64];
        int next_count = 0;

        for (int i = 0; i < current_count; i++) {
            for (int j = i + 1; j < current_count; j++) {
                // If they have the same mask and differ by exactly one bit in values
                if (current[i].mask == current[j].mask) {
                    int diff = current[i].value ^ current[j].value;
                    // Check if diff is a single bit and that bit is in the mask
                    if ((diff & (diff - 1)) == 0 && (diff & current[i].mask)) {
                        current[i].is_combined = 1;
                        current[j].is_combined = 1;

                        int new_mask = current[i].mask ^ diff;
                        int new_value = current[i].value & new_mask;

                        // Check if already exists in next
                        int exists = 0;
                        for (int k = 0; k < next_count; k++) {
                            if (next[k].mask == new_mask && next[k].value == new_value) {
                                exists = 1;
                                break;
                            }
                        }

                        if (!exists) {
                            next[next_count].mask = new_mask;
                            next[next_count].value = new_value;
                            next[next_count].is_combined = 0;
                            
                            // Combine minterms
                            int m_idx = 0;
                            for(int m=0; m<current[i].minterm_count; m++) 
                                next[next_count].covered_minterms[m_idx++] = current[i].covered_minterms[m];
                            for(int m=0; m<current[j].minterm_count; m++) 
                                next[next_count].covered_minterms[m_idx++] = current[j].covered_minterms[m];
                            next[next_count].minterm_count = m_idx;
                            
                            next_count++;
                        }
                    }
                }
            }
        }

        // Collect Prime Implicants
        for (int i = 0; i < current_count; i++) {
            if (!current[i].is_combined) {
                // Avoid duplicates
                int exists = 0;
                for (int k = 0; k < pi_count; k++) {
                    if (prime_implicants[k].mask == current[i].mask && prime_implicants[k].value == current[i].value) {
                        exists = 1; break;
                    }
                }
                if (!exists) {
                    prime_implicants[pi_count++] = current[i];
                }
            }
        }

        // Move to next stage
        for (int i = 0; i < next_count; i++) {
            current[i] = next[i];
        }
        current_count = next_count;
    }

    // Step 2: PI Table to find minimal cover
    // Since it's max 4 vars, we can use a simple greedy approach for simplicity
    // or just find Essential PIs first.
    
    int covered[16] = {0};
    int remaining = count;
    result[0] = '\0';

    while (remaining > 0) {
        // Find PI that covers most uncovered minterms
        int best_pi = -1;
        int max_new_cover = -1;

        for (int i = 0; i < pi_count; i++) {
            int new_cover = 0;
            for (int j = 0; j < prime_implicants[i].minterm_count; j++) {
                int m = prime_implicants[i].covered_minterms[j];
                int is_already_covered = 0;
                for (int k = 0; k < count; k++) {
                    if (minterms[k] == m && covered[k]) { is_already_covered = 1; break; }
                }
                if (!is_already_covered) new_cover++;
            }

            if (new_cover > max_new_cover) {
                max_new_cover = new_cover;
                best_pi = i;
            }
        }

        if (best_pi == -1) break;

        // Add to result
        char term[32];
        implicant_to_string(num_vars, &prime_implicants[best_pi], term);
        if (result[0] != '\0') strcat(result, " + ");
        strcat(result, term);

        // Mark as covered
        for (int j = 0; j < prime_implicants[best_pi].minterm_count; j++) {
            int m = prime_implicants[best_pi].covered_minterms[j];
            for (int k = 0; k < count; k++) {
                if (minterms[k] == m && !covered[k]) {
                    covered[k] = 1;
                    remaining--;
                }
            }
        }
    }
}

void simplify_kmap(int num_vars, int *minterms, int count, char *result) {
    // Show K-Map grid
    printf("\n--- K-Map (%d variables) ---\n", num_vars);
    
    int map[16] = {0};
    for (int i = 0; i < count; i++) map[minterms[i]] = 1;

    if (num_vars == 2) {
        printf("   B=0 B=1\n");
        printf("A=0 %d   %d\n", map[0], map[1]);
        printf("A=1 %d   %d\n", map[2], map[3]);
    } else if (num_vars == 3) {
        // Gray code: 00, 01, 11, 10
        int cols[] = {0, 1, 3, 2}; 
        printf("      BC=00 01 11 10\n");
        printf("A=0   ");
        for(int j=0; j<4; j++) printf("%d  ", map[cols[j]]);
        printf("\nA=1   ");
        for(int j=0; j<4; j++) printf("%d  ", map[4 + cols[j]]);
        printf("\n");
    } else if (num_vars == 4) {
        int gray[] = {0, 1, 3, 2};
        printf("        CD=00 01 11 10\n");
        for (int i = 0; i < 4; i++) {
            printf("AB=%d%d   ", (gray[i] >> 1) & 1, gray[i] & 1);
            for (int j = 0; j < 4; j++) {
                int m = (gray[i] << 2) | gray[j];
                printf("%d  ", map[m]);
            }
            printf("\n");
        }
    } else if (num_vars == 1) {
        printf("A=0: %d\n", map[0]);
        printf("A=1: %d\n", map[1]);
    }

    // Use QM logic for simplification result
    simplify_qm(num_vars, minterms, count, result);
}
