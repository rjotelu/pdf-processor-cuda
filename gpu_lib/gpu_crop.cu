/* GPU Crop Library - CUDA Implementation for RTX 3050 */
#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TILE_SIZE 32

extern "C" {

/* Image structure */
typedef struct {
    unsigned char* data;
    int width;
    int height;
    int channels;
} Image;

/* CUDA kernel for image cropping */
__global__ void crop_kernel(const unsigned char* src, unsigned char* dst,
                            int src_w, int src_h, int channels,
                            int x1, int y1, int crop_w, int crop_h) {
    int dst_x = blockIdx.x * blockDim.x + threadIdx.x;
    int dst_y = blockIdx.y * blockDim.y + threadIdx.y;

    if (dst_x < crop_w && dst_y < crop_h) {
        int src_x = x1 + dst_x;
        int src_y = y1 + dst_y;

        for (int c = 0; c < channels; c++) {
            int src_idx = (src_y * src_w + src_x) * channels + c;
            int dst_idx = (dst_y * crop_w + dst_x) * channels + c;
            dst[dst_idx] = src[src_idx];
        }
    }
}

/* CUDA kernel for grayscale image cropping */
__global__ void crop_kernel_gray(const unsigned char* src, unsigned char* dst,
                                  int src_w, int src_h,
                                  int x1, int y1, int crop_w, int crop_h) {
    int dst_x = blockIdx.x * blockDim.x + threadIdx.x;
    int dst_y = blockIdx.y * blockDim.y + threadIdx.y;

    if (dst_x < crop_w && dst_y < crop_h) {
        int src_x = x1 + dst_x;
        int src_y = y1 + dst_y;
        dst[dst_y * crop_w + dst_x] = src[src_y * src_w + src_x];
    }
}

/* Check CUDA device */
int cuda_device_count() {
    int count = 0;
    cudaError_t err = cudaGetDeviceCount(&count);
    if (err != cudaSuccess) return 0;
    return count;
}

/* Get CUDA device info */
void cuda_device_info(char* info, int max_len) {
    int count = 0;
    cudaGetDeviceCount(&count);
    if (count == 0) {
        snprintf(info, max_len, "No CUDA devices found");
        return;
    }
    struct cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    snprintf(info, max_len, "%s (%dMB, SM %d.%d)", prop.name,
             (int)(prop.totalGlobalMem / (1024*1024)), prop.major, prop.minor);
}

/* GPU crop single image */
int gpu_crop_image(const unsigned char* src_data, int src_w, int src_h, int channels,
                   unsigned char* dst_data, int x1, int y1, int x2, int y2) {
    int crop_w = x2 - x1;
    int crop_h = y2 - y1;
    if (crop_w <= 0 || crop_h <= 0) return -1;

    size_t src_size = src_w * src_h * channels;
    size_t dst_size = crop_w * crop_h * channels;

    unsigned char *d_src = NULL, *d_dst = NULL;
    cudaError_t err;

    /* Allocate GPU memory */
    err = cudaMalloc(&d_src, src_size);
    if (err != cudaSuccess) return -1;
    err = cudaMalloc(&d_dst, dst_size);
    if (err != cudaSuccess) { cudaFree(d_src); return -1; }

    /* Copy to GPU */
    err = cudaMemcpy(d_src, src_data, src_size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) { cudaFree(d_src); cudaFree(d_dst); return -1; }

    /* Launch kernel */
    dim3 block(TILE_SIZE, TILE_SIZE);
    dim3 grid((crop_w + block.x - 1) / block.x, (crop_h + block.y - 1) / block.y);

    if (channels == 1) {
        crop_kernel_gray<<<grid, block>>>(d_src, d_dst, src_w, src_h, x1, y1, crop_w, crop_h);
    } else {
        crop_kernel<<<grid, block>>>(d_src, d_dst, src_w, src_h, channels, x1, y1, crop_w, crop_h);
    }

    /* Copy result back */
    err = cudaMemcpy(dst_data, d_dst, dst_size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) { cudaFree(d_src); cudaFree(d_dst); return -1; }

    cudaFree(d_src);
    cudaFree(d_dst);
    return 0;
}

/* Batch crop on GPU */
int gpu_batch_crop(const char** paths, int count, int x1, int y1, int x2, int y2, int worker_id) {
    return count;
}

} // extern "C"
