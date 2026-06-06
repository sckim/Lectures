#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "converter.h"

void clear_input_buffer() {
    int c;
    while ((c = getchar()) != '\n' && c != EOF);
}

void handle_minterm_to_boolean() {
    int num_vars;
    printf("변수의 개수를 입력하세요 (1-4): ");
    if (scanf("%d", &num_vars) != 1 || num_vars < 1 || num_vars > 4) {
        printf("오류: 변수 개수는 1에서 4 사이여야 합니다.\n");
        clear_input_buffer();
        return;
    }

    int count;
    printf("입력할 minterm의 개수를 입력하세요: ");
    if (scanf("%d", &count) != 1 || count < 0 || count >(1 << num_vars)) {
        printf("오류: 유효하지 않은 개수입니다.\n");
        clear_input_buffer();
        return;
    }

    int minterms[MAX_MINTERMS];
    printf("minterm 번호를 입력하세요 (예: 0 1 3): ");
    for (int i = 0; i < count; i++) {
        if (scanf("%d", &minterms[i]) != 1) {
            printf("오류: 숫자 입력이 필요합니다.\n");
            clear_input_buffer();
            return;
        }
        if (minterms[i] < 0 || minterms[i] >= (1 << num_vars)) {
            printf("오류: minterm 번호 %d가 범위를 벗어났습니다.\n", minterms[i]);
            clear_input_buffer();
            return;
        }
    }

    char result[MAX_EXPR_LEN];
    minterm_to_boolean(num_vars, minterms, count, result);
    printf("결과 부울식: %s\n", result);
    clear_input_buffer();
}

void handle_boolean_to_minterm() {
    int num_vars;
    printf("사용할 변수의 개수를 입력하세요 (1-4): ");
    if (scanf("%d", &num_vars) != 1 || num_vars < 1 || num_vars > 4) {
        printf("오류: 변수 개수는 1에서 4 사이여야 합니다.\n");
        clear_input_buffer();
        return;
    }
    clear_input_buffer();

    char expression[MAX_EXPR_LEN];
    printf("부울식을 입력하세요 (예: A'B + AB'): ");
    if (fgets(expression, MAX_EXPR_LEN, stdin) == NULL) return;
    expression[strcspn(expression, "\n")] = 0; // Remove newline

    int minterms[MAX_MINTERMS];
    int count = 0;
    if (boolean_to_minterms(num_vars, expression, minterms, &count) == 0) {
        printf("결과 Minterms: ");
        if (count == 0) {
            printf("없음 (0)");
        }
        else {
            for (int i = 0; i < count; i++) {
                printf("m%d%s", minterms[i], (i == count - 1) ? "" : ", ");
            }
        }
        printf("\n");
    }
    else {
        printf("오류: 수식 해석 중 문제가 발생했습니다.\n");
    }
}

void handle_kmap_simplification() {
    int num_vars;
    printf("변수의 개수를 입력하세요 (1-4): ");
    if (scanf("%d", &num_vars) != 1 || num_vars < 1 || num_vars > 4) {
        printf("오류: 변수 개수는 1에서 4 사이여야 합니다.\n");
        clear_input_buffer();
        return;
    }

    int count;
    printf("입력할 minterm의 개수를 입력하세요: ");
    if (scanf("%d", &count) != 1 || count < 0 || count >(1 << num_vars)) {
        printf("오류: 유효하지 않은 개수입니다.\n");
        clear_input_buffer();
        return;
    }

    int minterms[MAX_MINTERMS];
    if (count > 0) {
        printf("minterm 번호를 입력하세요 (예: 0 1 3): ");
        for (int i = 0; i < count; i++) {
            if (scanf("%d", &minterms[i]) != 1) {
                printf("오류: 숫자 입력이 필요합니다.\n");
                clear_input_buffer();
                return;
            }
            if (minterms[i] < 0 || minterms[i] >= (1 << num_vars)) {
                printf("오류: minterm 번호 %d가 범위를 벗어났습니다.\n", minterms[i]);
                clear_input_buffer();
                return;
            }
        }
    }

    char result[MAX_EXPR_LEN];
    simplify_kmap(num_vars, minterms, count, result);
    printf("카르노 맵 간략화 결과: %s\n", result);
    clear_input_buffer();
}

void handle_qm_simplification() {
    int num_vars;
    printf("변수의 개수를 입력하세요 (1-4): ");
    if (scanf("%d", &num_vars) != 1 || num_vars < 1 || num_vars > 4) {
        printf("오류: 변수 개수는 1에서 4 사이여야 합니다.\n");
        clear_input_buffer();
        return;
    }

    int count;
    printf("입력할 minterm의 개수를 입력하세요: ");
    if (scanf("%d", &count) != 1 || count < 0 || count >(1 << num_vars)) {
        printf("오류: 유효하지 않은 개수입니다.\n");
        clear_input_buffer();
        return;
    }

    int minterms[MAX_MINTERMS];
    if (count > 0) {
        printf("minterm 번호를 입력하세요 (예: 0 1 3): ");
        for (int i = 0; i < count; i++) {
            if (scanf("%d", &minterms[i]) != 1) {
                printf("오류: 숫자 입력이 필요합니다.\n");
                clear_input_buffer();
                return;
            }
            if (minterms[i] < 0 || minterms[i] >= (1 << num_vars)) {
                printf("오류: minterm 번호 %d가 범위를 벗어났습니다.\n", minterms[i]);
                clear_input_buffer();
                return;
            }
        }
    }

    char result[MAX_EXPR_LEN];
    simplify_qm(num_vars, minterms, count, result);
    printf("QM 간략화 결과: %s\n", result);
    clear_input_buffer();
}

int main() {
    int choice;
    while (1) {
        printf("\n--- 논리회로 변환기 ---\r\n");
        printf("1. Minterm -> 부울식 변환\r\n");
        printf("2. 부울식 -> Minterm 변환\r\n");
        printf("3. 카르노 맵 간략화\r\n");
        printf("4. QM 간략화\r\n");
        printf("5. 종료\r\n");
        printf("선택: ");

        if (scanf("%d", &choice) != 1) {
            clear_input_buffer();
            continue;
        }

        switch (choice) {
        case 1:
            handle_minterm_to_boolean();
            break;
        case 2:
            handle_boolean_to_minterm();
            break;
        case 3:
            handle_kmap_simplification();
            break;
        case 4:
            handle_qm_simplification();
            break;
        case 5:
            printf("프로그램을 종료합니다.\n");
            return 0;
        default:
            printf("잘못된 선택입니다.\n");
        }
    }
    return 0;
}
