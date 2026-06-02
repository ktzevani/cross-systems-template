# cross-systems-template

![C++](https://img.shields.io/badge/C%2B%2B-20-00599C?logo=cplusplus)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?logo=python&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Linux-4E8CCF)
![CUDA](https://img.shields.io/badge/CUDA-enabled-76B900?logo=nvidia&logoColor=white)
![CMake](https://img.shields.io/badge/CMake-presets-064F8C?logo=cmake)
![Conan](https://img.shields.io/badge/Conan-2.x-6699CB)
![Ninja](https://img.shields.io/badge/Ninja-supported-222222)
![MSBuild](https://img.shields.io/badge/MSBuild-supported-5C2D91?logo=visualstudio)
![VS Code](https://img.shields.io/badge/VS%20Code-Dev%20Ready-007ACC?logo=visualstudiocode&logoColor=white)
![Visual Studio](https://img.shields.io/badge/Visual%20Studio-Dev%20Ready-5C2D91?logo=visualstudio&logoColor=white)
![NVIDIA Nsight](https://img.shields.io/badge/NVIDIA%20Nsight-supported-76B900?logo=nvidia&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

This repository is a template for developing cross-platform systems software on
Windows and Linux with a shared CMake and Conan foundation.

The goal is to provide a common starting point for applications, utilities, and
libraries that need to build across different native toolchains while keeping
the differences explicit. The project emits a single small C++ executable that
links `fmt` and `spdlog` as a showcase, plus the build profiles, presets,
scripts, and IDE configuration needed to exercise the supported workflows.

The template can be used for:

- Native C, C++, CUDA, or mixed systems projects.
- Python projects that call optimized native code.
- C++ libraries with Python bindings.
- Hybrid native/Python applications where Python handles orchestration and
  native code handles performance-sensitive work.

## 🧭 Core Model

The project separates build concerns into a few axes:

- Compiler and ABI: which compiler family and runtime ABI produces the binary.
- Build generator and executor: which build files CMake generates and which
  tool executes them.
- Build configuration: `Debug`, `Release`, or multi-configuration.
- Linkage model: static or shared libraries.

Current tools:

- **CMake:** project configuration and build-system generation.
- **Conan 2:** dependency graph resolution and generated CMake dependency files.
- **Ninja:** fast single-configuration build executor.
- **MSBuild:** Windows-native multi-configuration solution builds.
- **uv:** Python environment and tooling bootstrap.
- **VS Code:** cross-platform editor/debugger frontend.
- **Visual Studio:** Windows-native IDE workflow.

Generated build output lives under `out/`.

## 🧬 ABI Boundaries

ABI compatibility is one of the main reasons this template keeps profiles
explicit.

An ABI is the binary contract between compiled objects and libraries. It covers
details such as calling conventions, object format, exception handling, standard
library implementation, runtime libraries, name mangling, debug information, and
the C/C++ runtime.

Do not casually mix C++ libraries across ABI families. C libraries can sometimes
cross boundaries when the C ABI is stable and ownership is controlled, but C++
libraries should be treated as incompatible unless proven otherwise.

Current ABI categories supported by this template:

| Profile | Platform | Compiler | ABI/runtime family | Build executor |
|---|---|---|---|---|
| `linux-gcc-ninja-debug` | Linux | GCC 13.3 | ELF, libstdc++ `libstdc++11` ABI | Ninja |
| `linux-gcc-ninja-release` | Linux | GCC 13.3 | ELF, libstdc++ `libstdc++11` ABI | Ninja |
| `linux-gcc-ninja-cuda-debug` | Linux | GCC 13.3 + CUDA Toolkit | ELF, libstdc++ `libstdc++11` ABI | Ninja |
| `linux-gcc-ninja-cuda-release` | Linux | GCC 13.3 + CUDA Toolkit | ELF, libstdc++ `libstdc++11` ABI | Ninja |
| `windows-msvc-ninja-debug` | Windows | MSVC `cl` | MSVC ABI, MSVC STL, UCRT, dynamic runtime debug | Ninja |
| `windows-msvc-ninja-release` | Windows | MSVC `cl` | MSVC ABI, MSVC STL, UCRT, dynamic runtime release | Ninja |
| `windows-msvc-ninja-cuda-debug` | Windows | MSVC `cl` + CUDA Toolkit | MSVC ABI, MSVC STL, UCRT, dynamic runtime debug | Ninja |
| `windows-msvc-ninja-cuda-release` | Windows | MSVC `cl` + CUDA Toolkit | MSVC ABI, MSVC STL, UCRT, dynamic runtime release | Ninja |
| `windows-msvc-msbuild` | Windows | MSVC `cl` | MSVC ABI, MSVC STL, UCRT, dynamic runtime per config | MSBuild / Visual Studio |
| `windows-msvc-msbuild-cuda` | Windows | MSVC `cl` + CUDA Toolkit | MSVC ABI, MSVC STL, UCRT, dynamic runtime per config | MSBuild / Visual Studio |

Planned future ABI families may include Linux Clang, Windows `clang-cl`, and
Windows MinGW/MSYS2 GCC or Clang. These are not interchangeable just because
some of them use LLVM internally or target Windows. For example, `clang-cl`
targets the MSVC ABI, while MSYS2 Clang targets a MinGW-w64 ABI.

## 🧱 Build Matrix

Current supported workflows:

| Workflow | Preset/profile family | Configurations |
|---|---|---|
| VS Code + Linux + GCC + Ninja | `linux-gcc-ninja-*` | `Debug`, `Release` |
| VS Code + Linux + GCC + Ninja + CUDA | `linux-gcc-ninja-cuda-*` | `Debug`, `Release` |
| VS Code + Windows + MSVC + Ninja | `windows-msvc-ninja-*` | `Debug`, `Release` |
| VS Code + Windows + MSVC + Ninja + CUDA | `windows-msvc-ninja-cuda-*` | `Debug`, `Release` |
| Visual Studio + Windows + MSVC + MSBuild | `windows-msvc-msbuild` | `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` |
| Visual Studio + Windows + MSVC + MSBuild + CUDA | `windows-msvc-msbuild-cuda` | `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` |

Single-config generators such as Ninja use one build directory per build type.
Multi-config generators such as Visual Studio generate one solution that can
build multiple configurations.

## 🗂️ Repository Layout

```text
CMakeLists.txt                      C++ target definition
CMakePresets.json                   Project-owned CMake configure/build/test presets
conanfile.py                        Conan dependency recipe
profiles/                           Conan profiles for supported toolchain lanes
scripts/                            Cross-platform and Windows helper scripts
.vscode/                            VS Code tasks and debug configurations
.devcontainer/                      Linux dev container entrypoint for VS Code
image/                              Dev container Docker image
src/cpp/main.cpp                    Example native executable
tests/cpp/check_cuda.cu             Native CUDA verification executable
tests/python/test_pycuda.py         Pytest CUDA/PyCUDA verification test
out/                                Generated Conan/CMake/build output
```

## 🧰 Linux Development Image

The repository includes a Linux development image for Windows WSL, VS Code Dev
Containers, and remote/containerized development.

The image is defined by:

- `image/Dockerfile`
- `image/docker-entrypoint.sh`
- `docker-compose.yml`
- `.devcontainer/devcontainer.json`

The container is based on:

```text
nvidia/cuda:13.1.1-cudnn-devel-ubuntu24.04
```

It provides a CUDA-ready Ubuntu environment with CMake, Ninja, GCC, Clang,
GDB, LLDB, clangd, clang-format, clang-tidy, ccache, Valgrind, lcov, gcovr,
Doxygen, Vulkan tooling, uv, Python 3.13, PyCUDA, PyTorch CUDA wheels, and a
larger Python/AI tooling layer.

The Docker Compose service:

- Mounts the repository at `/opt/project`.
- Exposes ports `9080` and `9001`.
- Requests NVIDIA GPU capabilities.
- Runs `/venv/bin/python -m pytest -s tests/python/test_pycuda.py` at startup
  as a CUDA/PyCUDA smoke test.
- Keeps the container alive for interactive development.

VS Code Dev Containers use the `dev` service and install editor support for
Python, CMake, C/C++ debugging, NVIDIA Nsight VS Code CUDA debugging, Jupyter,
Ruff, TOML, and Markdown tooling.

This image is the recommended Linux development path when the host is Windows
and Linux builds should happen in WSL or a remote/container environment.

## 📋 Prerequisites

Linux dev container:

- Docker with NVIDIA container support if GPU/CUDA smoke tests are required.
- VS Code Dev Containers extension.
- NVIDIA Nsight Visual Studio Code Edition, installed automatically in the dev
  container.
- WSL 2 is recommended when running Docker Desktop on Windows.

Windows native development:

- Visual Studio 2022 with the C++ desktop workload.
- NVIDIA Nsight Visual Studio Edition for native Windows CUDA kernel debugging
  in Visual Studio.
- CMake.
- Ninja, for the Windows Ninja workflow.
- uv.
- Conan installed through the project Python tooling.
- Run Windows-native workflows from a Visual Studio Developer PowerShell, or
  open VS Code from a Visual Studio Developer environment.

## 🧩 VS Code Tasks

VS Code task definitions live in `.vscode/tasks.json`.

Current tasks:

| Task | Purpose |
|---|---|
| `00. Startup: Windows native setup check` | On Windows folder open, checks for a Visual Studio Developer environment and creates `.venv` with uv if needed. |
| `01 Conan: Install linux-gcc-ninja-debug` | Generates Conan dependency/toolchain files for Linux GCC Debug. |
| `02 Conan: Install linux-gcc-ninja-release` | Generates Conan dependency/toolchain files for Linux GCC Release. |
| `03. Conan: Install windows-msvc-ninja-debug` | Generates Conan dependency/toolchain files for Windows MSVC Ninja Debug. |
| `04. Conan: Install windows-msvc-ninja-release` | Generates Conan dependency/toolchain files for Windows MSVC Ninja Release. |
| `05. Conan: Install windows-msvc-msbuild all configs` | On Windows, runs the multi-config Conan install script for Visual Studio/MSBuild. |
| `06 Conan: Install linux-gcc-ninja-cuda-debug` | Generates Conan dependency/toolchain files for Linux GCC CUDA Debug. |
| `07 Conan: Install linux-gcc-ninja-cuda-release` | Generates Conan dependency/toolchain files for Linux GCC CUDA Release. |
| `08 Conan: Install windows-msvc-ninja-cuda-debug` | Generates Conan dependency/toolchain files for Windows MSVC Ninja CUDA Debug. |
| `09 Conan: Install windows-msvc-ninja-cuda-release` | Generates Conan dependency/toolchain files for Windows MSVC Ninja CUDA Release. |
| `10. Conan: Install windows-msvc-msbuild-cuda all configs` | On Windows, runs the multi-config Conan install script for Visual Studio/MSBuild CUDA. |
| `11 Debug: Prepare linux-gcc-ninja-debug` | Runs Conan install, CMake configure, and CMake build before Linux debugging. |
| `12 Debug: Prepare windows-msvc-ninja-debug` | Runs Conan install, CMake configure, and CMake build before Windows debugging. |
| `13 Debug CUDA: Prepare linux-gcc-ninja-cuda-debug` | Runs Conan install, CMake configure, and CMake build before Linux CUDA debugging. |
| `14 Debug CUDA: Prepare windows-msvc-ninja-cuda-debug` | Runs Conan install, CMake configure, and CMake build before Windows CUDA host debugging in VS Code. |
| `21 Verify CUDA: linux-gcc-ninja-cuda-debug` | Runs Conan install, CMake configure/build, and CTest for Linux CUDA Debug. |
| `22 Verify CUDA: windows-msvc-ninja-cuda-debug` | Runs Conan install, CMake configure/build, and CTest for Windows Ninja CUDA Debug. |
| `23 Verify CUDA: windows-msvc-msbuild-cuda-debug` | Runs Conan install, CMake configure/build, and CTest for Windows MSBuild CUDA Debug. |

The startup task calls:

```text
scripts/startup-windows.ps1
```

The Visual Studio/MSBuild Conan task calls:

```text
scripts/install-conan-windows-msvc-msbuild.ps1
```

The Visual Studio/MSBuild CUDA Conan task calls:

```text
scripts/install-conan-windows-msvc-msbuild-cuda.ps1
```

## 🐧 VS Code + Linux + Ninja

This is the primary workflow inside the Linux dev container.

Install Conan dependencies for Debug:

```sh
uv run --active conan install . \
  --profile:host=profiles/linux-gcc-ninja-debug \
  --profile:build=profiles/linux-gcc-ninja-debug \
  --build=missing \
  -of out/conan/linux-gcc-ninja-debug
```

Configure and build Debug:

```sh
cmake --preset linux-gcc-ninja-debug
cmake --build --preset linux-gcc-ninja-debug
```

Install Conan dependencies for Release:

```sh
uv run --active conan install . \
  --profile:host=profiles/linux-gcc-ninja-release \
  --profile:build=profiles/linux-gcc-ninja-release \
  --build=missing \
  -of out/conan/linux-gcc-ninja-release
```

Configure and build Release:

```sh
cmake --preset linux-gcc-ninja-release
cmake --build --preset linux-gcc-ninja-release
```

VS Code task shortcuts are available for the Conan install and debug prepare
steps.

## 🖥️ VS Code + Windows + Ninja

This workflow uses MSVC with Ninja from a Windows-native developer environment.
It is useful when you want VS Code as the editor and debugger, but still want
MSVC binaries.

Start VS Code from a Visual Studio Developer PowerShell or equivalent developer
environment so that `cl`, the Windows SDK, `INCLUDE`, and `LIB` are available.

Install Conan dependencies for Debug:

```powershell
uv run --active conan install . `
  --profile:host=profiles/windows-msvc-ninja-debug `
  --profile:build=profiles/windows-msvc-ninja-debug `
  --build=missing `
  -of out/conan/windows-msvc-ninja-debug
```

Configure and build Debug:

```powershell
cmake --preset windows-msvc-ninja-debug
cmake --build --preset windows-msvc-ninja-debug
```

Install Conan dependencies for Release:

```powershell
uv run --active conan install . `
  --profile:host=profiles/windows-msvc-ninja-release `
  --profile:build=profiles/windows-msvc-ninja-release `
  --build=missing `
  -of out/conan/windows-msvc-ninja-release
```

Configure and build Release:

```powershell
cmake --preset windows-msvc-ninja-release
cmake --build --preset windows-msvc-ninja-release
```

## 🏗️ Visual Studio + Windows + MSBuild

This workflow is for Windows-native development in Visual Studio. Conan
dependency metadata is generated for all supported Visual Studio configurations,
then CMake generates a `.sln`.

Run from a Visual Studio Developer PowerShell:

```powershell
.\scripts\install-conan-windows-msvc-msbuild.ps1
cmake --preset windows-msvc-msbuild
```

Open the generated solution:

```text
out\build\windows-msvc-msbuild\cross-systems-template.sln
```

Visual Studio can then build any supported configuration:

- `Debug`
- `Release`
- `RelWithDebInfo`
- `MinSizeRel`

Command-line builds are also available:

```powershell
cmake --build --preset windows-msvc-msbuild-debug
cmake --build --preset windows-msvc-msbuild-release
cmake --build --preset windows-msvc-msbuild-relwithdebinfo
cmake --build --preset windows-msvc-msbuild-minsizerel
```

## 🧪 CUDA Verification

CUDA verification is opt-in through CUDA-specific profiles and CMake presets.
Those presets set `CST_ENABLE_CUDA=ON`, which builds the native CUDA smoke test
and registers the CUDA CTest suite.

The suite contains:

- `cuda.cpp.runtime`: builds and runs `tests/cpp/check_cuda.cu`.
- `cuda.python.pycuda`: runs pytest through the project Python environment
  (`/venv` in the Linux container, `.venv` for Windows native).

Linux CUDA Debug:

```sh
uv run --active conan install . \
  --profile:host=profiles/linux-gcc-ninja-cuda-debug \
  --profile:build=profiles/linux-gcc-ninja-cuda-debug \
  --build=missing \
  -of out/conan/linux-gcc-ninja-cuda-debug

cmake --preset linux-gcc-ninja-cuda-debug
cmake --build --preset linux-gcc-ninja-cuda-debug
ctest --preset linux-gcc-ninja-cuda-debug
```

Windows MSVC/Ninja CUDA Debug:

```powershell
uv run --active conan install . `
  --profile:host=profiles/windows-msvc-ninja-cuda-debug `
  --profile:build=profiles/windows-msvc-ninja-cuda-debug `
  --build=missing `
  -of out/conan/windows-msvc-ninja-cuda-debug

cmake --preset windows-msvc-ninja-cuda-debug
cmake --build --preset windows-msvc-ninja-cuda-debug
ctest --preset windows-msvc-ninja-cuda-debug
```

Windows MSVC/MSBuild CUDA keeps the existing multi-config model:

```powershell
.\scripts\install-conan-windows-msvc-msbuild-cuda.ps1
cmake --preset windows-msvc-msbuild-cuda
cmake --build --preset windows-msvc-msbuild-cuda-debug
ctest --preset windows-msvc-msbuild-cuda-debug
```

CUDA lanes require a CUDA Toolkit at build time, an NVIDIA driver/GPU at runtime,
and a host compiler supported by the installed CUDA Toolkit.

## 🐞 CPU Debugging

VS Code debug configurations live in `.vscode/launch.json`.

Linux uses GDB through the Microsoft C/C++ extension:

- Launch: `Debug app: Linux GCC + GDB`
- Attach: `Attach app: Linux GCC + GDB`
- Adapter type: `cppdbg`
- Debugger: `/usr/bin/gdb`

Windows uses the Visual Studio Windows debugger:

- Launch: `Debug app: Windows MSVC + Visual Studio Debugger`
- Attach: `Attach app: Windows MSVC + Visual Studio Debugger`
- Adapter type: `cppvsdbg`

`cppvsdbg` is the VS Code debug adapter for the Visual Studio debugger. It is
only available on Windows with the Microsoft C/C++ extension.

## 🧵 CUDA Debugging

CUDA Debug builds compile CUDA sources with device debug information. CUDA
`Debug` builds use NVCC device-debug flags, while CUDA `RelWithDebInfo` builds
use line information for source correlation.

CUDA breakpoints should be placed on executable device statements inside a
kernel. Breakpoints on a `__global__` function declaration may bind to generated
host launch/stub code instead of device code.

Linux CUDA kernel debugging is supported through NVIDIA Nsight Visual Studio Code
Edition in the Linux dev container:

- Launch: `Debug CUDA check: Linux Nsight VS Code`
- Attach: `Attach CUDA: Linux Nsight VS Code`
- Adapter type: `cuda-gdb`
- Debugger: `/usr/local/cuda/bin/cuda-gdb`
- Target: `out/build/linux-gcc-ninja-cuda-debug/check_cuda`

The launch configuration builds the CUDA Debug lane first. Set breakpoints in
`tests/cpp/check_cuda.cu`, then start the Nsight VS Code launch configuration.

Windows VS Code supports configuring, building, testing, and host-side debugging
of the CUDA executable:

- Launch: `Debug CUDA check host: Windows MSVC + Visual Studio Debugger`
- Adapter type: `cppvsdbg`
- Target: `out\build\windows-msvc-ninja-cuda-debug\check_cuda.exe`

Native Windows CUDA kernel debugging is supported through Visual Studio with
NVIDIA Nsight Visual Studio Edition. Generate the CUDA MSBuild solution, open it
in Visual Studio, build the `Debug` configuration, set breakpoints in
`tests/cpp/check_cuda.cu`, and start CUDA debugging from the Visual Studio
Nsight menu:

```powershell
.\scripts\install-conan-windows-msvc-msbuild-cuda.ps1
cmake --preset windows-msvc-msbuild-cuda
cmake --build --preset windows-msvc-msbuild-cuda-debug
```

Open:

```text
out\build\windows-msvc-msbuild-cuda\cross-systems-template.sln
```

Windows VS Code is not the native CUDA kernel debugger lane. NVIDIA Nsight VS
Code Edition uses `cuda-gdb`, whose CUDA debugging target is Linux; use Visual
Studio + Nsight Visual Studio Edition for Windows-native CUDA kernel debugging.

## 🐍 Python And Native Code

The project uses `uv` for Python tooling. The current Python package metadata is
minimal on purpose, but the template is prepared for several directions:

- A native-first project with Python used only for tools and tests.
- A Python application that calls native libraries.
- A C++ library that exposes Python bindings.
- A mixed CUDA/C++/Python project where Python drives high-level workflows and
  native code handles performance-sensitive kernels or system integration.

The dev container currently includes Python CUDA/PyCUDA verification. CUDA C++
verification is available through the CUDA CMake presets and CTest suite.

## 🚧 Future Extension Points

Expected additions:

- Linux Clang profiles.
- Windows `clang-cl` profiles targeting the MSVC ABI.
- Windows MSYS2 GCC/Clang profiles targeting MinGW-w64 ABI families.
- Static/shared library options.
- Sanitizer profiles for supported compiler families.
- Profiling workflows and metrics collection guidance.
- Packaging support for native artifacts, Python artifacts, and hybrid
  native/Python deliverables.

When adding new profiles, keep the axes separate:

- Name the compiler and ABI family explicitly.
- Name the generator/executor explicitly.
- Keep single-config and multi-config workflows distinct.
- Do not reuse Conan/CMake output folders across incompatible ABI families.
- Keep project-owned CMake presets stable and avoid relying on generated Conan
  preset names.
- Treat packaging as another explicit matrix axis when outputs differ by ABI,
  runtime, build configuration, or Python/native boundary.

## 🧹 Generated Files

Conan and CMake generate files under `out/`. The repository-owned presets point
to generated Conan toolchain files, but the generated files themselves are not
source.

`CMakeUserPresets.json` is intentionally not used as the source of truth. Conan
profile configuration disables root user-preset generation so CMake sees the
project-owned preset names instead of duplicate generated names such as
`conan-debug` or `conan-release`.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
