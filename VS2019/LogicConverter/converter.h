#ifndef CONVERTER_H
#define CONVERTER_H

#define MAX_EXPR_LEN 256
#define MAX_MINTERMS 16 // For 4 variables, 2^4 = 16

/**
 * Converts a list of minterms to a Sum of Products (SOP) boolean expression string.
 * @param num_vars Number of variables (1-4)
 * @param minterms Array of minterm integers
 * @param count Number of minterms in the array
 * @param result Buffer to store the resulting boolean expression string
 */
void minterm_to_boolean(int num_vars, int *minterms, int count, char *result);

/**
 * Finds minterms for a given boolean expression.
 * @param num_vars Number of variables (1-4)
 * @param expression The boolean expression string (e.g., "A'*B + C")
 * @param minterms Output array to store found minterms
 * @param count Output pointer to store the number of found minterms
 * @return 0 on success, non-zero on error (e.g., parsing error)
 */
int boolean_to_minterms(int num_vars, const char *expression, int *minterms, int *count);

/**
 * Simplifies a boolean expression using Karnaugh Map method.
 * @param num_vars Number of variables (1-4)
 * @param minterms Array of minterm integers
 * @param count Number of minterms in the array
 * @param result Buffer to store the resulting simplified boolean expression string
 */
void simplify_kmap(int num_vars, int *minterms, int count, char *result);

/**
 * Simplifies a boolean expression using Quine-McCluskey method.
 * @param num_vars Number of variables (1-4)
 * @param minterms Array of minterm integers
 * @param count Number of minterms in the array
 * @param result Buffer to store the resulting simplified boolean expression string
 */
void simplify_qm(int num_vars, int *minterms, int count, char *result);

#endif // CONVERTER_H
