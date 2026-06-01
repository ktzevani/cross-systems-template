from conan import ConanFile
from conan.tools.cmake import cmake_layout


class MyProjectConan(ConanFile):
    name = "cross-systems-template"
    version = "0.1.0"

    settings = "os", "arch", "compiler", "build_type"

    # Example dependencies.
    requires = (
        "fmt/10.2.1",
        "spdlog/1.14.1",
    )

    generators = (
        "CMakeToolchain",
        "CMakeDeps",
    )

    def layout(self):
        cmake_layout(self)
