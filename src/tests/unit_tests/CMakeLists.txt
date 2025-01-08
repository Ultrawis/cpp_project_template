set_source_group(
    run
    unit_tests_main.cpp
)
set_source_group(
    tests
    core_tests.cpp
)
add_executable(
    unit_tests
    ${run}
    ${tests}
)

target_compile_definitions(
    unit_tests
    PRIVATE
    CATCH_CONFIG_ENABLE_BENCHMARKING
)

target_link_libraries(
    unit_tests
    PRIVATE
    ultra_strict_compiler_flags
    core
    Catch2::Catch2
)

set_target_properties(unit_tests PROPERTIES FOLDER tests)