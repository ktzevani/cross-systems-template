cmake_minimum_required(VERSION 3.23)

project(cross-systems-template LANGUAGES CXX)

include(CTest)

option(CST_ENABLE_CUDA "Build CUDA verification targets and tests" OFF)

add_executable(app
    src/cpp/main.cpp
)

target_compile_features(app PRIVATE cxx_std_20)

find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

target_link_libraries(app PRIVATE
    fmt::fmt
    spdlog::spdlog
)

if(CST_ENABLE_CUDA)
    enable_language(CUDA)
    find_package(CUDAToolkit REQUIRED)

    add_executable(check_cuda
        tests/cpp/check_cuda.cu
    )

    target_compile_features(check_cuda PRIVATE cuda_std_17)
    target_link_libraries(check_cuda PRIVATE CUDA::cudart)

    if(BUILD_TESTING)
        find_package(Python3 REQUIRED COMPONENTS Interpreter)

        add_test(NAME cuda.cpp.runtime COMMAND check_cuda)
        set_tests_properties(cuda.cpp.runtime PROPERTIES LABELS "cuda;cpp")

        add_test(
            NAME cuda.python.pycuda
            COMMAND ${Python3_EXECUTABLE} -m pytest -s ${CMAKE_SOURCE_DIR}/tests/python
        )
        set_tests_properties(cuda.python.pycuda PROPERTIES
            LABELS "cuda;python"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    endif()
endif()
