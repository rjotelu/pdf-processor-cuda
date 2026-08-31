# pdf-processor-cuda

GPU-accelerated PDF to cropped Markdown converter using **NVIDIA CUDA**.

## Binaries

| Binary | Description |
|--------|-------------|
| `bin/pdf-processor-cpu` | CPU-only version |
| `bin/pdf-processor-cuda` | CUDA version (requires `libgpu_crop.so`) |

## Build

```bash
# Build CPU version
go build -o bin/pdf-processor-cpu ./cmd/

# Build CUDA version
gcc -shared -fPIC -o gpu_lib/libgpu_crop.so gpu_lib/gpu_crop.c
CGO_ENABLED=1 go build -tags rocm -o bin/pdf-processor-cuda ./cmd/
```

## Usage

```bash
./bin/pdf-processor-cpu -dir /path/to/pdfs -workers 8

./bin/pdf-processor-cuda -dir /path/to/pdfs -workers 8
```

## GitHub

- Repository: https://github.com/rjotelu/pdf-processor-cuda
- Binary releases: Download from GitHub Releases