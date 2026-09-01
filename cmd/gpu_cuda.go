//go:build cuda
// +build cuda

package main

/*
#cgo LDFLAGS: -ldl

#include <stdlib.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

static void* gpu_lib = NULL;
static int (*cuda_dev_count_fn)() = NULL;
static void (*cuda_info_fn)(char*, int) = NULL;

static int init_lib() {
    if (gpu_lib) return 1;
    gpu_lib = dlopen("./gpu_lib/libgpu_crop.so", RTLD_NOW);
    if (!gpu_lib) gpu_lib = dlopen("gpu_lib/libgpu_crop.so", RTLD_NOW);
    if (!gpu_lib) return 0;
    cuda_dev_count_fn = (int(*)())dlsym(gpu_lib, "cuda_device_count");
    cuda_info_fn = (void(*)(char*,int))dlsym(gpu_lib, "cuda_device_info");
    return cuda_dev_count_fn != NULL;
}

int check_cuda() {
    return init_lib() && cuda_dev_count_fn() > 0;
}

int get_cuda_count() {
    if (!init_lib()) return 0;
    return cuda_dev_count_fn();
}

void get_cuda_info(char* buf, int len) {
    if (!init_lib() || !cuda_info_fn) {
        snprintf(buf, len, "CUDA not available");
        return;
    }
    cuda_info_fn(buf, len);
}
*/
import "C"
import (
	"fmt"
	"unsafe"
)

type GPUProcessor struct {
	available bool
	info      string
}

func NewGPUProcessor() *GPUProcessor {
	available := C.check_cuda() == 1
	var info string
	if available {
		buf := make([]byte, 256)
		C.get_cuda_info((*C.char)(unsafe.Pointer(&buf[0])), C.int(len(buf)))
		info = string(buf)
		fmt.Printf("[✓] CUDA GPU: %s\n", info)
	} else {
		fmt.Println("[!] CUDA GPU not available, using CPU")
	}
	return &GPUProcessor{available: available, info: info}
}

func (p *GPUProcessor) Available() bool { return p.available }
func (p *GPUProcessor) Info() string   { return p.info }
