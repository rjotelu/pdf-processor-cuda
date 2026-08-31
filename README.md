# pdf-processor-cuda

GPU-accelerated PDF to cropped Markdown converter using **NVIDIA CUDA**.

## Build

```bash
# Build GPU library (stub for CPU fallback)
gcc -shared -fPIC -o gpu_lib/libgpu_crop.so gpu_lib/gpu_crop.c

# Build CUDA binary
CGO_ENABLED=1 go build -tags cuda -o bin/pdf-processor ./cmd/main.go

# Build CPU-only binary
go build -o bin/pdf-processor ./cmd/main.go
```

## Usage

```bash
./bin/pdf-processor -dir /path/to/pdfs -workers 8
```

## GitHub

```bash
git clone https://github.com/rjotelu/pdf-processor-cuda.git
cd pdf-processor-cuda
./build.sh
```