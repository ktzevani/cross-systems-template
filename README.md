# systems-ref-project

![C++](https://img.shields.io/badge/C%2B%2B-20-00599C?logo=cplusplus)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?logo=python&logoColor=white)
![CUDA](https://img.shields.io/badge/CUDA-ready-76B900?logo=nvidia&logoColor=white)
![CMake](https://img.shields.io/badge/CMake-presets-064F8C?logo=cmake)
![Conan](https://img.shields.io/badge/Conan-2.x-6699CB)
![Ninja](https://img.shields.io/badge/Ninja-build-222222)
![MSBuild](https://img.shields.io/badge/MSBuild-Visual%20Studio-5C2D91?logo=visualstudio)

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
| `windows-msvc-ninja-debug` | Windows | MSVC `cl` | MSVC ABI, MSVC STL, UCRT, dynamic runtime debug | Ninja |
| `windows-msvc-ninja-release` | Windows | MSVC `cl` | MSVC ABI, MSVC STL, UCRT, dynamic runtime release | Ninja |
| `windows-msvc-msbuild` | Windows | MSVC `cl` | MSVC ABI, MSVC STL, UCRT, dynamic runtime per config | MSBuild / Visual Studio |

Planned future ABI families may include Linux Clang, Windows `clang-cl`, and
Windows MinGW/MSYS2 GCC or Clang. These are not interchangeable just because
some of them use LLVM internally or target Windows. For example, `clang-cl`
targets the MSVC ABI, while MSYS2 Clang targets a MinGW-w64 ABI.

## 🧱 Build Matrix

Current supported workflows:

| Workflow | Preset/profile family | Configurations |
|---|---|---|
| VS Code + Linux + GCC + Ninja | `linux-gcc-ninja-*` | `Debug`, `Release` |
| VS Code + Windows + MSVC + Ninja | `windows-msvc-ninja-*` | `Debug`, `Release` |
| Visual Studio + Windows + MSVC + MSBuild | `windows-msvc-msbuild` | `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` |

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
tests/check_pycuda.py               Container CUDA/PyCUDA smoke test
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
- Runs `tests/check_pycuda.py` at startup as a CUDA/PyCUDA smoke test.
- Keeps the container alive for interactive development.

VS Code Dev Containers use the `dev` service and install editor support for
Python, CMake, C/C++ debugging, Jupyter, Ruff, TOML, and Markdown tooling.

This image is the recommended Linux development path when the host is Windows
and Linux builds should happen in WSL or a remote/container environment.

## 📋 Prerequisites

Linux dev container:

- Docker with NVIDIA container support if GPU/CUDA smoke tests are required.
- VS Code Dev Containers extension.
- WSL 2 is recommended when running Docker Desktop on Windows.

Windows native development:

- Visual Studio 2022 with the C++ desktop workload.
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
| `00. Startup: Windows native setup check` | On Windows folder open, checks for a Visual Studio Developer environment and creates `.venv/win64` with uv if needed. |
| `01 Conan: Install linux-gcc-ninja-debug` | Generates Conan dependency/toolchain files for Linux GCC Debug. |
| `02 Conan: Install linux-gcc-ninja-release` | Generates Conan dependency/toolchain files for Linux GCC Release. |
| `03. Conan: Install windows-msvc-ninja-debug` | Generates Conan dependency/toolchain files for Windows MSVC Ninja Debug. |
| `04. Conan: Install windows-msvc-ninja-release` | Generates Conan dependency/toolchain files for Windows MSVC Ninja Release. |
| `05. Conan: Install windows-msvc-msbuild all configs` | On Windows, runs the multi-config Conan install script for Visual Studio/MSBuild. |
| `11 Debug: Prepare linux-gcc-ninja-debug` | Runs Conan install, CMake configure, and CMake build before Linux debugging. |
| `12 Debug: Prepare windows-msvc-ninja-debug` | Runs Conan install, CMake configure, and CMake build before Windows debugging. |

The startup task calls:

```text
scripts/startup-windows.ps1
```

The Visual Studio/MSBuild Conan task calls:

```text
scripts/install-conan-windows-msvc-msbuild.ps1
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
out\build\windows-msvc-msbuild\systems-ref-project.sln
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

## 🐞 Debugging

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

Visual Studio users can debug from the generated solution using the normal
Visual Studio debugger.

CUDA debugging is planned. The current image is CUDA-ready, but CUDA build
targets, CUDA debug launch profiles, and host/compiler compatibility rules will
be added as a separate step.

## 🐍 Python And Native Code

The project uses `uv` for Python tooling. The current Python package metadata is
minimal on purpose, but the template is prepared for several directions:

- A native-first project with Python used only for tools and tests.
- A Python application that calls native libraries.
- A C++ library that exposes Python bindings.
- A mixed CUDA/C++/Python project where Python drives high-level workflows and
  native code handles performance-sensitive kernels or system integration.

The dev container currently includes a CUDA/PyCUDA smoke test. Full CUDA build
profiles and CUDA debugging support are planned future work.

## 🚧 Future Extension Points

Expected additions:

- Linux Clang profiles.
- Windows `clang-cl` profiles targeting the MSVC ABI.
- Windows MSYS2 GCC/Clang profiles targeting MinGW-w64 ABI families.
- CUDA-enabled profiles across supported host compiler lanes.
- CUDA debugging workflows.
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
