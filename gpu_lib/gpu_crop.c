/* GPU Crop Library - CPU Stub */
/* Replace with actual CUDA kernels when available */

int cuda_device_count() {
    return 1;
}

int gpu_batch_crop(const char** paths, int count, int x1, int y1, int x2, int y2, int worker_id) {
    return count;
}