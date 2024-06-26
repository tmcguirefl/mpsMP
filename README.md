# mspMP
This repository has one file that uses the metal performance shader library to create
a C style function header that provides access to Metal GPU matrix multiplication. 

It would be nicer if these libraries were available in C or C++ but I could only find Swift and
Objective-C support. 

## mpsMP the function call
short for mps Matrix Product. I believe from my limited reading that it will only support 
matrices up to 8000x8000. It also only supports float32 (8-btye floats). 
<pre>
void mpsMP(int rowsA, int columnsA, int rowsB, int columnsB, int rowsC, int columnsC, float *arrayA, float *arrayB, float *arrayC)
</pre>

## C test harness
Header File
<pre>
#ifndef mpsMPtest_h
#define mpsMPtest_h
#ifdef __cplusplus
extern "C" {
#endif

void mpsMP(int rowsA, int columnsA, int rowsB, int columnsB, int rowsC, int columnsC, float *arrayA, float *arrayB, float *arrayC);

#ifdef __cplusplus
}
#endif

#endif /* mpsMPtest_h */
</pre>


C source code to test
<pre>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "mpsMPtest.h"

void randomizeArray(float *array, int size) {
    for (int i = 0; i < size; i++) {
        array[i] = ((float)rand() / (float)RAND_MAX) * 2.0f - 1.0f;
    }
}

int main(int argc, const char * argv[]) {
    int rowsA = 5000;
    int columnsA = 2000;
    int rowsB = 2000;
    int columnsB = 3000;
    int rowsC = rowsA;
    int columnsC = columnsB;

    float *arrayA = (float *)malloc(rowsA * columnsA * sizeof(float));
    float *arrayB = (float *)malloc(rowsB * columnsB * sizeof(float));
    float *arrayC = (float *)calloc(rowsC * columnsC, sizeof(float)); // calloc initializes to zero

    srand((unsigned int)time(NULL));

    randomizeArray(arrayA, rowsA * columnsA);
    randomizeArray(arrayB, rowsB * columnsB);

    int result = mpsMP(rowsA, columnsA, rowsB, columnsB, rowsC, columnsC, arrayA, arrayB, arrayC);

    printf("Result first 10 matrix C:\n");
    for (int i = 0; i < 10; i++) {
        printf("%f \n", arrayC[i]);
    }

    free(arrayA);
    free(arrayB);
    free(arrayC);

    return result;
}
</pre>

## Words of Warning
This is far from turn key you would need to take the test harness code and set it up in xcode
You need to place the dylib in a directory that will get searched at link time. If you are using 
XCode on mac you will need to set up where the library builds to. This took me a while not being 
an experienced XCode user. So you have a lot of directories to make and put stuff into. You just 
can't clone and go. 

