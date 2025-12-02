#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Define constants
#define FS 256
#define FC1 0.5
#define FC2 10
#define N 10
#define PI 3.14159265358979323846
#define CHUNK_SIZE 256  // Size of each data chunk

// Function to apply IIR filter to a chunk of data
void apply_iir_filter_chunk(const double* b, const double* a, int numCoeffs, const double* input, double* output, int chunkSize, double* x, double* y) {
    for (int i = 0; i < chunkSize; i++) {
        x[0] = input[i];
        y[0] = b[0] * x[0];

        for (int j = 1; j < numCoeffs; j++) {
            if (i - j >= 0) {
                y[0] += b[j] * x[j] - a[j] * y[j];
            }
        }

        output[i] = y[0];

        // Shift the x and y arrays for the next sample
        for (int j = numCoeffs - 1; j > 0; j--) {
            x[j] = x[j - 1];
            y[j] = y[j - 1];
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
    const int totalLength = 2560; // 10 seconds of data at 256 Hz
    const int chunkSize = CHUNK_SIZE;
    double fs = FS;

    // Allocate memory for input and output signals
    double* input = (double*)malloc(totalLength * sizeof(double));
    double* output = (double*)malloc(totalLength * sizeof(double));

    // Generate test signal
    generate_test_signal(input, totalLength, fs);

    // Filter states
    double x[numCoeffs];  // Past input samples
    double y[numCoeffs];  // Past output samples

    // Initialize filter states to zero
    for (int i = 0; i < numCoeffs; i++) {
        x[i] = 0.0;
        y[i] = 0.0;
    }

    // Process the signal in chunks
    for (int start = 0; start < totalLength; start += chunkSize) {
        int length = (start + chunkSize < totalLength) ? chunkSize : (totalLength - start);
        apply_iir_filter_chunk(b, a, numCoeffs, &input[start], &output[start], length, x, y);
    }

    // Print the input and output signals
    printf("Input Signal:\n");
    for (int i = 0; i < totalLength; i++) {
        printf("%f\n", input[i]);
    }

    printf("\nFiltered Signal:\n");
    for (int i = 0; i < totalLength; i++) {
        printf("%f\n", output[i]);
    }

    // Free allocated memory
    free(input);
    free(output);

    return 0;
}
