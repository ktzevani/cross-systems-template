# Project Context For Future Work

This repository is a cross-platform systems project template for Windows and
Linux. It currently supports CMake, Conan 2, Ninja, Visual Studio/MSBuild, VS
Code debugging, and a CUDA-capable Linux dev container. The root README is the
canonical public documentation.

Current profile/preset lanes:

- `linux-gcc-ninja-debug`
- `linux-gcc-ninja-release`
- `windows-msvc-ninja-debug`
- `windows-msvc-ninja-release`
- `windows-msvc-msbuild` multi-config Visual Studio lane

Current debug lanes:

- Linux: VS Code `cppdbg` with `/usr/bin/gdb`.
- Windows: VS Code `cppvsdbg`, the Visual Studio Windows debugger adapter.
- Visual Studio: generated `.sln` from `windows-msvc-msbuild`.

Important design decisions:

- Project-owned `CMakePresets.json` is the source of truth.
- Conan root `CMakeUserPresets.json` generation is disabled with
  `tools.cmake.cmaketoolchain:user_presets=` in profiles.
- `out/` is generated state.
- ABI families must remain explicit and isolated.
- README documents the Linux CUDA dev image, WSL/remote/container development
  intent, VS Code tasks, debug adapters, current ABI lanes, and future CUDA
  extension plan.
- User said the current files under `docs/` are not intended to be committed.

Recent helper scripts:

- `scripts/startup-windows.ps1` initializes the Windows uv environment when VS
  Code opens in a Windows Developer environment.
- `scripts/install-conan-windows-msvc-msbuild.ps1` installs Conan dependency
  metadata for `Debug`, `Release`, `RelWithDebInfo`, and `MinSizeRel` into
  `out/conan/windows-msvc-msbuild`.

Planned future work:

- Add CUDA build support across all active profiles.
- Add CUDA debugging support.
- Add Linux Clang.
- Add Windows clang-cl.
- Add Windows GCC/Clang through MSYS2/MinGW ABI families.
- Add profiler and sanitizer guidance/profiles.
- Add static/shared library profile or option support.
- Add packaging support for native, Python, and hybrid native/Python artifacts.
