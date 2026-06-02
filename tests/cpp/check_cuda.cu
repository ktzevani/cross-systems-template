#include <cuda_runtime.h>

#include <cmath>
#include <iostream>
#include <vector>

namespace {

__global__ void doublify(float* values, int count) {
    const int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < count) {
        values[index] *= 2.0F;
    }
}

bool check_cuda(cudaError_t result, const char* action) {
    if (result == cudaSuccess) {
        return true;
    }

    std::cerr << action << " failed: " << cudaGetErrorString(result) << '\n';
    return false;
}

}  // namespace

int main() {
    int device_count = 0;
    if (!check_cuda(cudaGetDeviceCount(&device_count), "cudaGetDeviceCount")) {
        return 1;
    }

    if (device_count <= 0) {
        std::cerr << "No CUDA devices detected.\n";
        return 1;
    }

    int device = 0;
    cudaDeviceProp properties{};
    if (!check_cuda(cudaGetDeviceProperties(&properties, device), "cudaGetDeviceProperties")) {
        return 1;
    }

    int driver_version = 0;
    int runtime_version = 0;
    if (!check_cuda(cudaDriverGetVersion(&driver_version), "cudaDriverGetVersion")) {
        return 1;
    }
    if (!check_cuda(cudaRuntimeGetVersion(&runtime_version), "cudaRuntimeGetVersion")) {
        return 1;
    }

    std::cout << "CUDA detected device:\n";
    std::cout << "  GPU model: " << properties.name << '\n';
    std::cout << "  Compute capability: " << properties.major << "." << properties.minor << '\n';
    std::cout << "  Total memory: " << static_cast<double>(properties.totalGlobalMem) / 1.0e6
              << " MB\n";
    std::cout << "  Driver version: " << driver_version << '\n';
    std::cout << "  Runtime version: " << runtime_version << '\n';

    constexpr int count = 16;
    std::vector<float> host_values(count);
    for (int i = 0; i < count; ++i) {
        host_values[i] = static_cast<float>(i);
    }

    float* device_values = nullptr;
    const auto byte_count = host_values.size() * sizeof(float);
    if (!check_cuda(cudaMalloc(&device_values, byte_count), "cudaMalloc")) {
        return 1;
    }

    if (!check_cuda(cudaMemcpy(device_values, host_values.data(), byte_count, cudaMemcpyHostToDevice),
                    "cudaMemcpy host-to-device")) {
        cudaFree(device_values);
        return 1;
    }

    doublify<<<1, count>>>(device_values, count);

    if (!check_cuda(cudaGetLastError(), "kernel launch")) {
        cudaFree(device_values);
        return 1;
    }
    if (!check_cuda(cudaDeviceSynchronize(), "cudaDeviceSynchronize")) {
        cudaFree(device_values);
        return 1;
    }

    std::vector<float> result(count);
    if (!check_cuda(cudaMemcpy(result.data(), device_values, byte_count, cudaMemcpyDeviceToHost),
                    "cudaMemcpy device-to-host")) {
        cudaFree(device_values);
        return 1;
    }

    if (!check_cuda(cudaFree(device_values), "cudaFree")) {
        return 1;
    }

    std::cout << "Kernel ran, first 5 results:";
    for (int i = 0; i < 5; ++i) {
        std::cout << ' ' << result[i];
    }
    std::cout << '\n';

    for (int i = 0; i < count; ++i) {
        const float expected = static_cast<float>(i * 2);
        if (std::fabs(result[i] - expected) > 1.0e-5F) {
            std::cerr << "Unexpected result at index " << i << ": got " << result[i]
                      << ", expected " << expected << '\n';
            return 1;
        }
    }

    std::cout << "CUDA kernel execution OK\n";
    return 0;
}
