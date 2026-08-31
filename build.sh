#!/bin/bash
set -e

# Build GPU library
mkdir -p gpu_lib
gcc -shared -fPIC -o gpu_lib/libgpu_crop.so gpu_lib/gpu_crop.c

# Build binaries
mkdir -p bin

# CUDA version
echo "Building CUDA binary..."
CGO_ENABLED=1 go build -tags cuda -o bin/pdf-processor-cuda ./cmd/ 2>/dev/null || echo "CUDA binary requires nvcc"

# CPU version  
echo "Building CPU binary..."
go build -o bin/pdf-processor-cpu ./cmd/

echo "Done!"