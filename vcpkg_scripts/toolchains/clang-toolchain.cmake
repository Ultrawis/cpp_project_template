macro(append_flag_if_not_found var flag)
    string(FIND "${${var}}" "${flag}" position)

    if(position EQUAL -1)
        # The string was not found; append it
        message(STATUS "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ append ${flag} to ${var}")
        message(STATUS "flags before: ${${var}}")
        string(APPEND ${var} " ${flag} ")
        message(STATUS "flags after: ${${var}}")
    endif()
endmacro()

set(CMAKE_C_COMPILER clang-17)
set(CMAKE_CXX_COMPILER clang++17)

# append_flag_if_not_found(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")
append_flag_if_not_found(CMAKE_CXX_FLAGS_INIT "-fPIC")

set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")

get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)

if(NOT _CMAKE_IN_TRY_COMPILE)
    string(APPEND CMAKE_C_FLAGS_INIT " ${VCPKG_C_FLAGS} ")
    string(APPEND CMAKE_CXX_FLAGS_INIT " ${VCPKG_CXX_FLAGS} ")
    string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${VCPKG_C_FLAGS_DEBUG} ")
    string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${VCPKG_CXX_FLAGS_DEBUG} ")
    string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${VCPKG_C_FLAGS_RELEASE} ")
    string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${VCPKG_CXX_FLAGS_RELEASE} ")

    string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT "-static ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT "-static ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT "-static ")
    endif()

    string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
endif()

# set(CMAKE_C_FLAGS "-fuse-ld=lld")
# set(CMAKE_CXX_FLAGS "-fuse-ld=lld")
# set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
