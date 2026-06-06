#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "converter.h"

// Simple Stack implementation
typedef struct {
    char data[MAX_EXPR_LEN];
    int top;
} CharStack;

void push(CharStack *s, char c) {
    s->data[++(s->top)] = c;
}

char pop(CharStack *s) {
    return s->data[(s->top)--];
}

char peek(CharStack *s) {
    if (s->top == -1) return '\0';
    return s->data[s->top];
}

int is_empty(CharStack *s) {
    return s->top == -1;
}

int get_precedence(char op) {
    switch (op) {
        case '\'': return 3;
        case '*': return 2;
        case '+': return 1;
        case '(': return 0;
        default: return -1;
    }
}

int infix_to_postfix(const char *infix, char *postfix) {
    CharStack s;
    s.top = -1;
    int k = 0;
    char prev = '\0';

    for (int i = 0; infix[i]; i++) {
        char c = infix[i];

        if (isspace(c)) continue;

        // Check for implicit multiplication
        if ((c == '(' || (c >= 'A' && c <= 'D')) &&
            ((prev >= 'A' && prev <= 'D') || prev == ')' || prev == '\'')) {
            int prec = get_precedence('*');
            while (!is_empty(&s) && get_precedence(peek(&s)) >= prec) {
                postfix[k++] = pop(&s);
            }
            push(&s, '*');
        }

        if (c >= 'A' && c <= 'D') {
            postfix[k++] = c;
        } else if (c == '(') {
            push(&s, c);
        } else if (c == ')') {
            while (!is_empty(&s) && peek(&s) != '(') {
                postfix[k++] = pop(&s);
            }
            if (!is_empty(&s) && peek(&s) == '(') {
                pop(&s);
            } else {
                return -1; // Mismatched parentheses
            }
        } else {
            int prec = get_precedence(c);
            if (prec == -1) return -1; // Unknown operator

            while (!is_empty(&s) && get_precedence(peek(&s)) >= prec) {
                postfix[k++] = pop(&s);
            }
            push(&s, c);
        }
        prev = c;
    }

    while (!is_empty(&s)) {
        if (peek(&s) == '(') return -1;
        postfix[k++] = pop(&s);
    }
    postfix[k] = '\0';
    return 0;
}

int evaluate_postfix(const char *postfix, int *vars) {
    int stack[MAX_EXPR_LEN];
    int top = -1;

    for (int i = 0; postfix[i]; i++) {
        char c = postfix[i];

        if (c >= 'A' && c <= 'D') {
            stack[++top] = vars[c - 'A'];
        } else if (c == '\'') {
            if (top < 0) return -1;
            stack[top] = !stack[top];
        } else if (c == '*') {
            if (top < 1) return -1;
            int op2 = stack[top--];
            int op1 = stack[top--];
            stack[++top] = op1 && op2;
        } else if (c == '+') {
            if (top < 1) return -1;
            int op2 = stack[top--];
            int op1 = stack[top--];
            stack[++top] = op1 || op2;
        }
    }

    return (top == 0) ? stack[0] : -1;
}

int boolean_to_minterms(int num_vars, const char *expression, int *minterms, int *count) {
    char postfix[MAX_EXPR_LEN];
    if (infix_to_postfix(expression, postfix) != 0) {
        return -1;
    }

    *count = 0;
    int total_combinations = 1 << num_vars;
    
    for (int i = 0; i < total_combinations; i++) {
        int vars[4] = {0, 0, 0, 0};
        for (int v = 0; v < num_vars; v++) {
            vars[v] = (i >> (num_vars - 1 - v)) & 1;
        }

        int result = evaluate_postfix(postfix, vars);
        if (result == -1) return -1; // Evaluation error
        
        if (result == 1) {
            minterms[(*count)++] = i;
        }
    }

    return 0;
}
