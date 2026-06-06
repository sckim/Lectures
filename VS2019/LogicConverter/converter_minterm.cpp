#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>
#include "converter.h"

void minterm_to_boolean(int num_vars, int *minterms, int count, char *result) {
    result[0] = '\0';
    if (count == 0) {
        strcpy(result, "0");
        return;
    }

    for (int i = 0; i < count; i++) {
        int m = minterms[i];
        char term[32] = "";
        
        for (int v = 0; v < num_vars; v++) {
            char var_name = 'A' + v;
            int bit_pos = num_vars - 1 - v;
            int bit_val = (m >> bit_pos) & 1;
            
            char var_str[4];
            if (bit_val == 1) {
                sprintf(var_str, "%c", var_name);
            } else {
                sprintf(var_str, "%c'", var_name);
            }
            strcat(term, var_str);
        }
        
        strcat(result, term);
        if (i < count - 1) {
            strcat(result, " + ");
        }
    }
}
