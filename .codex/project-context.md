# Project Context For Future Work

This repository is named `cross-systems-template`. It is a cross-platform
systems project template for Windows and Linux. It currently supports CMake,
Conan 2, Ninja, Visual Studio/MSBuild, VS Code debugging, and a CUDA-capable
Linux dev container. The root README is the canonical public documentation.
The project is licensed under the MIT License.

Current profile/preset lanes:

- `linux-gcc-ninja-debug`
- `linux-gcc-ninja-release`
- `linux-gcc-ninja-cuda-debug`
- `linux-gcc-ninja-cuda-release`
- `windows-msvc-ninja-debug`
- `windows-msvc-ninja-release`
- `windows-msvc-ninja-cuda-debug`
- `windows-msvc-ninja-cuda-release`
- `windows-msvc-msbuild` multi-config Visual Studio lane
- `windows-msvc-msbuild-cuda` multi-config Visual Studio CUDA lane

Current debug lanes:

- Linux: VS Code `cppdbg` with `/usr/bin/gdb`.
- Windows: VS Code `cppvsdbg`, the Visual Studio Windows debugger adapter.
- Visual Studio: generated `.sln` from `windows-msvc-msbuild`.
- Linux CUDA: VS Code NVIDIA Nsight Visual Studio Code Edition with `cuda-gdb`
  in the Linux dev container.
- Windows CUDA: Visual Studio with NVIDIA Nsight Visual Studio Edition from the
  `windows-msvc-msbuild-cuda` solution. Windows VS Code remains useful for
  build/test and host-side `cppvsdbg` debugging, not native CUDA kernel
  debugging.

Important design decisions:

- Project-owned `CMakePresets.json` is the source of truth.
- Conan root `CMakeUserPresets.json` generation is disabled with
  `tools.cmake.cmaketoolchain:user_presets=` in profiles.
- `out/` is generated state.
- ABI families must remain explicit and isolated.
- CUDA is an explicit capability lane. CMake owns CUDA language/toolkit
  discovery, while Conan continues to own the C++ dependency ABI graph.
- CUDA Debug builds add NVCC device debug information for `check_cuda`;
  RelWithDebInfo CUDA builds add line information for source correlation.
- README documents the Linux CUDA dev image, WSL/remote/container development
  intent, VS Code tasks, debug adapters, current ABI lanes, and CUDA
  verification workflows.
- User said the current files under `docs/` are not intended to be committed.

Recent helper scripts:

- `scripts/startup-windows.ps1` initializes the Windows uv environment when VS
  Code opens in a Windows Developer environment.
- `scripts/install-conan-windows-msvc-msbuild.ps1` installs Conan dependency
  metadata for `Debug`, `Release`, `RelWithDebInfo`, and `MinSizeRel` into
  `out/conan/windows-msvc-msbuild`.
- `scripts/install-conan-windows-msvc-msbuild-cuda.ps1` installs Conan
  dependency metadata for `Debug`, `Release`, `RelWithDebInfo`, and
  `MinSizeRel` into `out/conan/windows-msvc-msbuild-cuda`.

Current CUDA verification suite:

- Native CUDA executable source: `tests/cpp/check_cuda.cu`.
- PyCUDA pytest source: `tests/python/test_pycuda.py`.
- CTest names: `cuda.cpp.runtime` and `cuda.python.pycuda`.
- Docker Compose startup runs `/venv/bin/python -m pytest -s
  tests/python/test_pycuda.py`.

Planned future work:

- Add CUDA debugging support.
- Add Linux Clang.
- Add Windows clang-cl.
- Add Windows GCC/Clang through MSYS2/MinGW ABI families.
- Add profiler and sanitizer guidance/profiles.
- Add static/shared library profile or option support.
- Add packaging support for native, Python, and hybrid native/Python artifacts.
