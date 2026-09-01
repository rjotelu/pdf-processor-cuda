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
# Basic usage
./bin/pdf-processor-cuda -dir /path/to/pdfs -workers 8

# Concurrent PDF processing
./bin/pdf-processor-cuda -dir /path/to/pdfs -pdf-workers 4 -workers 8

# Resume interrupted processing
./bin/pdf-processor-cuda -dir /path/to/pdfs -checkpoint progress.json

# Pretty text formatting
./bin/pdf-processor-cuda -dir /path/to/pdfs -pretty

# Skip empty pages
./bin/pdf-processor-cuda -dir /path/to/pdfs -skip-empty

# JSON output
./bin/pdf-processor-cuda -dir /path/to/pdfs -format json

# Strip headers from individual pages
./bin/pdf-processor-cuda -dir /path/to/pdfs -strip-header
```

## Command Line Options

```
  -dir string        Directory to scan for PDF files (default: ".")
  -pdf-workers int   Number of PDF files to process concurrently (default: 2)
  -workers int       Number of parallel crop/ocr workers per PDF (default: CPU cores)
  -dpi int           PDF render DPI (default: 300)
  -x1 int            Crop box X1 (default: 154)
  -y1 int            Crop box Y1 (default: 236)
  -x2 int            Crop box X2 (default: 2392)
  -y2 int            Crop box Y2 (default: 3007)
  -lang string       Tesseract OCR language (default: "eng")
  -format string     Output format: md, txt, json (default: "md")
  -checkpoint string Path to checkpoint file for resume support
  -skip-empty        Skip pages with no extracted text
  -strip-header      Remove header and image from individual page files
  -pretty            Format text for better readability
  -no-cleanup        Keep intermediate image files
  -v                 Enable verbose logging
```

## Performance

| Feature | Improvement |
|---------|-------------|
| Concurrent PDFs | Multiple PDFs processed simultaneously |
| Resume support | Skip already processed pages on restart |
| OCR retry | Auto-retry failed OCR (3 attempts) |
| Buffered I/O | Faster file writes |

## GitHub

- Repository: https://github.com/rjotelu/pdf-processor-cuda
- Binary releases: Download from GitHub Releases
