import numpy as np
import pycuda
import pycuda.driver as cuda
import pytest
from pycuda.compiler import SourceModule


def test_pycuda_device_and_kernel():
    try:
        cuda.init()
    except Exception as exc:
        pytest.fail(f"CUDA driver initialization failed: {exc}")

    device_count = cuda.Device.count()
    assert device_count > 0, "No CUDA devices detected."

    dev = cuda.Device(0)
    context = dev.make_context()

    try:
        print("PyCUDA version:", ".".join(map(str, pycuda.VERSION)))
        print("PyCUDA detected device:")
        print("  GPU model:", dev.name())
        print("  Compute capability:", dev.compute_capability())
        print("  Total memory: %.1f MB" % (dev.total_memory() / 1e6))

        mod = SourceModule("""
        __global__ void doublify(float *a) {
            int idx = threadIdx.x + blockIdx.x * blockDim.x;
            a[idx] *= 2.0f;
        }
        """)
        func = mod.get_function("doublify")

        n = 16
        host_array = np.arange(n, dtype=np.float32)
        device_array = cuda.mem_alloc(host_array.nbytes)
        cuda.memcpy_htod(device_array, host_array)

        func(device_array, block=(n, 1, 1), grid=(1, 1, 1))

        result = np.empty_like(host_array)
        cuda.memcpy_dtoh(result, device_array)

        print("Kernel ran, first 5 results:", result[:5])
        assert np.allclose(result, host_array * 2)
    finally:
        context.pop()
