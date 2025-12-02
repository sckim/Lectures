#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Define constants
#define FS 256
#define FC1 0.5
#define FC2 10
#define N 10
#define PI 3.14159265358979323846

// Function to apply FIR filter
void apply_fir_filter(const double* coeffs, int numCoeffs, const double* input, double* output, int signalLength) {
    for (int i = 0; i < signalLength; i++) {
        output[i] = 0.0;
        for (int j = 0; j < numCoeffs; j++) {
            if (i - j >= 0) {
                output[i] += coeffs[j] * input[i - j];
            }
        }
    }
}

// Function to apply IIR filter
void apply_iir_filter(const double* b, const double* a, int numCoeffs, const double* input, double* output, int signalLength) {
    for (int i = 0; i < signalLength; i++) {
        output[i] = 0.0;
        for (int j = 0; j < numCoeffs; j++) {
            if (i - j >= 0) {
                output[i] += b[j] * input[i - j];
                if (j > 0) {
                    output[i] -= a[j] * output[i - j];
                }
            }
        }
    }
}

// Function to generate a test signal
void generate_test_signal(double* signal, int length, double fs) {
    for (int i = 0; i < length; i++) {
        double t = (double)i / fs;
        signal[i] = cos(2 * PI * 1 * t) + 0.5 * cos(2 * PI * 50 * t); // 1Hz and 50Hz components
    }
}

int main() {
    // Example IIR filter coefficients (replace with your actual coefficients)
    double b[] = { 0.0201, 0.1576, 0.4540, 0.4540, 0.1576, 0.0201 };  // Numerator coefficients
    double a[] = { 1.0, -0.5, 0.25, -0.125, 0.0625, -0.03125 };       // Denominator coefficients
    int numCoeffs = sizeof(b) / sizeof(b[0]);

    // Signal length and sampling frequency
    const int signalLength = 2560; // 10 seconds of data at 256 Hz
    double fs = FS;

    // Allocate memory for input and output signals
    double* input = (double*)malloc(signalLength * sizeof(double));
    double* output = (double*)malloc(signalLength * sizeof(double));

    // Generate test signal
    generate_test_signal(input, signalLength, fs);

    // Apply IIR filter
    apply_iir_filter(b, a, numCoeffs, input, output, signalLength);

    // Print the input and output signals
    printf("Input Signal:\n");
    for (int i = 0; i < signalLength; i++) {
        printf("%f\n", input[i]);
    }

    printf("\nFiltered Signal:\n");
    for (int i = 0; i < signalLength; i++) {
        printf("%f\n", output[i]);
    }

    // Free allocated memory
    free(input);
    free(output);

    return 0;
}
