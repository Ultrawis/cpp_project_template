
set_source_group(
    logging
    logger.hpp
    logger.cpp
)

add_library(
    cpp.core
    STATIC
    ${logging}
)