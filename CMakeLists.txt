cmake_minimum_required(VERSION 3.23)

project(cross-systems-template LANGUAGES CXX)

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
