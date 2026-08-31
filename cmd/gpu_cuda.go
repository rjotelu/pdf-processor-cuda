//go:build cuda
// +build cuda

package main

/*
#cgo LDFLAGS: -ldl

#include <stdlib.h>
#include <dlfcn.h>
#include <stdio.h>

static void* gpu_lib = NULL;
static int (*cuda_dev_count_fn)() = NULL;
static int (*batch_crop_fn)(const char**, int, int, int, int, int, int) = NULL;

static int init_lib() {
    if (gpu_lib) return 1;
    gpu_lib = dlopen("./gpu_lib/libgpu_crop.so", RTLD_NOW);
    if (!gpu_lib) gpu_lib = dlopen("gpu_lib/libgpu_crop.so", RTLD_NOW);
    if (!gpu_lib) return 0;
    cuda_dev_count_fn = (int(*)())dlsym(gpu_lib, "cuda_device_count");
    batch_crop_fn = (int(*)(const char**,int,int,int,int,int,int))dlsym(gpu_lib, "gpu_batch_crop");
    return cuda_dev_count_fn && batch_crop_fn;
}

int check_cuda() {
    return init_lib() && cuda_dev_count_fn() > 0;
}
*/
import "C"
import "fmt"

type GPUProcessor struct {
	available bool
}

func NewGPUProcessor() *GPUProcessor {
	available := C.check_cuda() == 1
	if available {
		fmt.Println("[✓] CUDA GPU detected")
	} else {
		fmt.Println("[!] CUDA GPU not available")
	}
	return &GPUProcessor{available: available}
}

func (p *GPUProcessor) Available() bool { return p.available }