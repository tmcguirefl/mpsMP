//
//  mpsMP.m
//  mpsMP
//
//  Created by Thomas McGuire on 6/5/24.
//


#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

void mpsMP(int rowsA, int columnsA, int rowsB, int columnsB, int rowsC, int columnsC, float *arrayA, float *arrayB, float *arrayC) {
    @autoreleasepool {
        NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
        id<MTLDevice> device = nil;

        for (id<MTLDevice> dev in devices) {
            if (MPSSupportsMTLDevice(dev)) {
                device = dev;
                break;
            }
        }

        if (!device) {
            NSLog(@"No suitable Metal device found");
            return;
        }

 
        id<MTLCommandQueue> commandQueue = [device newCommandQueue];

        MPSMatrixMultiplication *matrixMultiplication = [[MPSMatrixMultiplication alloc] initWithDevice:device transposeLeft:NO transposeRight:NO resultRows:rowsC resultColumns:columnsC interiorColumns:columnsA alpha:1 beta:0];

        id<MTLBuffer> bufferA = [device newBufferWithBytes:arrayA length:rowsA * columnsA * sizeof(float) options:0];
        id<MTLBuffer> bufferB = [device newBufferWithBytes:arrayB length:rowsB * columnsB * sizeof(float) options:0];
        id<MTLBuffer> bufferC = [device newBufferWithLength:rowsC * columnsC * sizeof(float) options:0];

        MPSMatrixDescriptor *descA = [MPSMatrixDescriptor matrixDescriptorWithDimensions:rowsA columns:columnsA rowBytes:columnsA * sizeof(float) dataType:MPSDataTypeFloat32];
        MPSMatrixDescriptor *descB = [MPSMatrixDescriptor matrixDescriptorWithDimensions:rowsB columns:columnsB rowBytes:columnsB * sizeof(float) dataType:MPSDataTypeFloat32];
        MPSMatrixDescriptor *descC = [MPSMatrixDescriptor matrixDescriptorWithDimensions:rowsC columns:columnsC rowBytes:columnsC * sizeof(float) dataType:MPSDataTypeFloat32];

        MPSMatrix *matrixA = [[MPSMatrix alloc] initWithBuffer:bufferA descriptor:descA];
        MPSMatrix *matrixB = [[MPSMatrix alloc] initWithBuffer:bufferB descriptor:descB];
        MPSMatrix *matrixC = [[MPSMatrix alloc] initWithBuffer:bufferC descriptor:descC];

        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        [matrixMultiplication encodeToCommandBuffer:commandBuffer leftMatrix:matrixA rightMatrix:matrixB resultMatrix:matrixC];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];

        // Copy the result back to arrayC
        const float *rawPointer = matrixC.data.contents;
        memcpy(arrayC, rawPointer, rowsC * columnsC * sizeof(float));
    }
}

