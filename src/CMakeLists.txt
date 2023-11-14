

add_executable(app main.cpp)
target_link_libraries(app
    PRIVATE
    spdlog::spdlog
    ultra_strict_compiler_flags
)