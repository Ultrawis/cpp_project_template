
set_source_group(
    logging
    core/logger.hpp
    logger.cpp
)

add_library(
    core
    STATIC
    ${logging}
)

target_include_directories(
    core
    INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(
    core
    PRIVATE
    ultra_strict_compiler_flags
)

set_target_properties(core PROPERTIES FOLDER libs)