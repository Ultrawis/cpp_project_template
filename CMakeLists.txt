cmake_minimum_required(VERSION 3.25)

if(NOT DEFINED ENV{VCPKG_ROOT})
    message(FATAL_ERROR
        "VCPKG_ROOT envrionment variable is not defined.\n"
        "please install vcpkg and set the appropriate environment variable."
    )
endif()

include(cmake/version_details.cmake)
include(cmake/compiler_flags.cmake)
include(cmake/global_setup.cmake)
include(cmake/debugging_utils.cmake)
include(cmake/dynamic_library_link.cmake)
include(cmake/code_analysis.cmake)
include(cmake/target_helpers.cmake)
include(cmake/installation.cmake)

message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================     BEFORE PROJECT CPP      ================================="
    "\n======================================================================================"
    "\n======================================================================================"
)

project(cpp VERSION ${PROJECT_VERSION})

message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================      AFTER PROJECT CPP      ================================="
    "\n======================================================================================"
    "\n======================================================================================"
)

enable_testing()
include(CTest)

# setup_target_for_find_package(ultra_strict_compiler_flags)
# setup_target_compiled_artifacts_for_install(ultra_strict_compiler_flags)
# setup_target_for_find_package(ultra_strict_compiler_flags_17)
# setup_target_compiled_artifacts_for_install(ultra_strict_compiler_flags_17)
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY true)

add_library(
    cpp.configuration
    INTERFACE
    cmake/compiler_flags.cmake
    cmake/global_setup.cmake
    cmake/debugging_utils.cmake
    cmake/dynamic_library_link.cmake
    cmake/code_analysis.cmake
    cmake/target_helpers.cmake
    cmake/installation.cmake
    CMakePresetsBase.json
    CMakePresets.json
    vcpkg.json
    .clang-tidy
    .clang-format
)

add_library(cpp.natvis INTERFACE)
target_sources(cpp.natvis PUBLIC natvis/eigen.natvis)

set_target_properties(cpp.configuration PROPERTIES FOLDER build_config)
set_target_properties(cpp.natvis PROPERTIES FOLDER build_config)

set(ULTRA_ALLOWED_BUILD_TYPES Debug RelWithDebInfo Profile)

# ######################################################################################################
# # define build types for Profile, RelWithDebInfo and Debug
# ######################################################################################################
# Copy flags from RelWithDebInfo
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS_PROFILE "${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
set(CMAKE_STATIC_LINKER_FLAGS_PROFILE "${CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
set(CMAKE_MAP_IMPORTED_CONFIG_PROFILE "Release") # see https://github.com/microsoft/vcpkg/discussions/19327 for why we need to do this

get_property(isMultiConfig GLOBAL
    PROPERTY GENERATOR_IS_MULTI_CONFIG
)

if(MSVC)
    # Append /Zi to enable debug information for MSVC compiler
    # https://stackoverflow.com/questions/77943000/how-can-i-copy-debug-symbols-flags-from-one-build-configuration-to-another
    set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_PROFILE} /Zi" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_PROFILE} /Zi" CACHE STRING "" FORCE)
endif()

# For multi-configuration generators, use generator expressions
if(isMultiConfig)
    set(CMAKE_CONFIGURATION_TYPES ${ULTRA_ALLOWED_BUILD_TYPES} CACHE STRING "" FORCE)

# add_compile_definitions($<CONFIG:Profile>:ULTRA_PROFILING_ENABLED)
else()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${ULTRA_ALLOWED_BUILD_TYPES}")

    if(NOT CMAKE_BUILD_TYPE OR(NOT CMAKE_BUILD_TYPE IN_LIST ULTRA_ALLOWED_BUILD_TYPES))
        message(FATAL_ERROR
            "Missing or invalid build type: ${CMAKE_BUILD_TYPE}\n"
            "Set CMAKE_BUILD_TYPE to one of : ${ULTRA_ALLOWED_BUILD_TYPES}"
        )
    endif()
endif()

# ###########################################################################
# PACKAGES
# ###########################################################################
message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================           PACKAGES        ==================================="
    "\n======================================================================================"
    "\n======================================================================================"
)

# vcpkg based libraries
find_package(Catch2 CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

# see https://github.com/microsoft/vcpkg/discussions/19327 for why we need to do this
unset(CMAKE_MAP_IMPORTED_CONFIG_PROFILE)

message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================        CPP TARGETS        ==================================="
    "\n======================================================================================"
    "\n======================================================================================"
)

# ############################################################################
# #                        GLOBAL VARIABLES
# ############################################################################
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

configure_default_output_directories()

if(CMAKE_GENERATOR MATCHES "Visual Studio")
    # Do Visual Studio specific stuff
    message(DEBUG "ZZZZ adding include path ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")

    # it seems that vcpkg based cmake solutions don't add the vcpkg generated include directories to vcproj files'
    include_directories("${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
endif()

# HACK
if(MSVC)
    # https://stackoverflow.com/questions/58708772/cmake-project-in-visual-studio-gives-flag-override-warnings-command-line-warnin
    string(REGEX REPLACE "/W[3|4]" "/w" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

if(WIN32)
    add_compile_definitions(
        WIN32_LEAN_AND_MEAN
        NOMINMAX # WINDOWS: to avoid defining min/max macros

        # _WINSOCKAPI_ # WINDOWS: to avoid re-definition in WinSock2.h
    )

    add_definitions(-D_WIN32_WINNT=0x0A00)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# ###########################################################################
# SUBDIRECTORIES
# ###########################################################################
add_subdirectory(src)

# #######################################################################################################
#
# CTest Integration
# https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md#automatic-test-registration
#
# #######################################################################################################
message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================            END            ==================================="
    "\n======================================================================================"
    "\n======================================================================================"
)
