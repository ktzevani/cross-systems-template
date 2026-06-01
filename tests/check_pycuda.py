# src/check_pycuda.py

import pycuda.driver as cuda
import pycuda.autoinit  # sets up a context on the first GPU
from pycuda.compiler import SourceModule
import numpy as np


def check_pycuda():
    try:
        # 1) Check device info
        dev = cuda.Device(0)
        print("✔ PyCUDA Version:", ".".join(map(str, pycuda.VERSION)))
        print("✔ PyCUDA detected device:")
        print("   - GPU Model:", dev.name())
        print("   - Compute capability:", dev.compute_capability())
        print("   - Total memory: %.1f MB" % (dev.total_memory() / 1e6))

        # 2) Run a trivial kernel: double an array
        mod = SourceModule("""
        __global__ void doublify(float *a) {
            int idx = threadIdx.x + blockIdx.x * blockDim.x;
            a[idx] *= 2;
        }
        """)
        func = mod.get_function("doublify")

        # Prepare data
        n = 16
        host_array = np.arange(n, dtype=np.float32)
        device_array = cuda.mem_alloc(host_array.nbytes)
        cuda.memcpy_htod(device_array, host_array)

        # Launch kernel
        func(device_array, block=(n, 1, 1), grid=(1, 1, 1))

        # Copy result back
        result = np.empty_like(host_array)
        cuda.memcpy_dtoh(result, device_array)

        print("✔ Kernel ran, first 5 results:", result[:5])
        assert np.allclose(result, host_array * 2)
        print("✔ PyCUDA kernel execution OK")
        return True

    except Exception as e:
        print("✘ PyCUDA check failed:", e)
        return False


if __name__ == "__main__":
    ok = check_pycuda()
    exit(0 if ok else 1)
