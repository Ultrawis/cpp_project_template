cmake_minimum_required(VERSION 3.25)

if(NOT DEFINED ENV{VCPKG_ROOT})
    message(FATAL_ERROR
        "VCPKG_ROOT envrionment variable is not defined.\n"
        "please install vcpkg and set the appropriate environment variable."
    )
endif()

message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================       PROJECT ULTRAWIS      ================================="
    "\n======================================================================================"
    "\n======================================================================================"
)

include(cmake/compiler_flags.cmake)
include(cmake/global_setup.cmake)
include(cmake/debugging_utils.cmake)
include(cmake/dynamic_library_link.cmake)
include(cmake/code_analysis.cmake)
include(cmake/target_helpers.cmake)
include(cmake/installation.cmake)

find_program(flutter_executable NAMES flutter)

if(flutter_executable)
    message("flutter_executable found = ${flutter_executable}")
endif()

if(WITH_ULTRA_API)
    message("WITH_ULTRA_API - ON")
    list(APPEND VCPKG_MANIFEST_FEATURES vcpkg-with-api)
endif()

project("ultrawis")

enable_testing()
include(CTest)

option(WITH_ULTRA_API "Build ultrawis api" ON)
option(WITH_ULTRA_CUDA "Build ultrawis cuda" OFF)

if(WITH_ULTRA_CUDA)
    message("ULTRAWIS - WITH CUDA")
    enable_language(CUDA)
else()
    message("ULTRAWIS - NO CUDA")
endif()

setup_target_for_find_package(ultra_strict_compiler_flags)
setup_target_compiled_artifacts_for_install(ultra_strict_compiler_flags)
setup_target_for_find_package(ultra_strict_compiler_flags_17)
setup_target_compiled_artifacts_for_install(ultra_strict_compiler_flags_17)

add_library(
    ultra.configuration
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

add_library(ultra.natvis INTERFACE)
target_sources(ultra.natvis PUBLIC natvis/eigen.natvis)

set_target_properties(ultra.configuration PROPERTIES FOLDER build_config)
set_target_properties(ultra.natvis PROPERTIES FOLDER build_config)

set(ULTRA_CLANG_TIDY_CONFIG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy")

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

if(WIN32)
    # TODO - look for better solution
    # I manually added the path to the windows SDK because ffmpeg find_packege
    # will look for windows sdk libraries using find_library
    set(ULTRA_ASSUMED_WINSDK_LIBRARIES_PATH "C:/Program Files (x86)/Windows Kits/10/Lib")
    file(GLOB WINSDK_VERSION_FOLDERS "${ULTRA_ASSUMED_WINSDK_LIBRARIES_PATH}/*")
    message("WINSDK_VERSION_FOLDERS = ${WINSDK_VERSION_FOLDERS}")
    list(SORT WINSDK_VERSION_FOLDERS)
    list(GET WINSDK_VERSION_FOLDERS -1 LAST_WINSDK_VERSION_FOLDER)
    message("LAST_WINSDK_VERSION_FOLDER = ${LAST_WINSDK_VERSION_FOLDER}")
    list(PREPEND CMAKE_LIBRARY_PATH

        # "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.22000.0/um/x64"
        ${LAST_WINSDK_VERSION_FOLDER}/um/x64

        # $ENV{ULTRAWIS_EXTERNALS}/dependencies/opencv
    )
    message("CMAKE_LIBRARY_PATH = ${CMAKE_LIBRARY_PATH}")
endif()

# brute force added libraries that don't behave well with vcpkg

# vcpkg based libraries
find_package(function2 CONFIG REQUIRED)
find_package(magic_enum CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(PalSigslot CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

if(WITH_ULTRA_API)
    find_package(unordered_dense CONFIG REQUIRED)
    message("dxc_executable = ${DIRECTX_DXC_TOOL}")

    # find_program(dxc_executable NAMES dxc HINTS directx-dxc::dxc CONFIG REQUIRED)
    # find_program(glslc_executable NAMES glslc HINTS unofficial-shaderc_util::glslc)
endif()

if(WITH_ULTRA_CUDA)
    find_package(CUDAToolkit)
endif()

# find_package(Vulkan CONFIG REQUIRED)
if(UNIX)
    # find_package(XCB REQUIRED)
endif()

message(STATUS
    "\n======================================================================================"
    "\n======================================================================================"
    "\n========================      ULTRAWIS TARGETS     ==================================="
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

set(ULTRA_ALLOWED_BUILD_TYPES Debug RelWithDebInfo)

get_property(isMultiConfig GLOBAL
    PROPERTY GENERATOR_IS_MULTI_CONFIG
)

if(isMultiConfig)
    list(REMOVE_ITEM CMAKE_CONFIGURATION_TYPES MinSizeRel;Release)
else()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${ULTRA_ALLOWED_BUILD_TYPES}")

    if(NOT CMAKE_BUILD_TYPE OR(NOT CMAKE_BUILD_TYPE IN_LIST ULTRA_ALLOWED_BUILD_TYPES))
        message(FATAL_ERROR
            "Missing or invalid build type: ${CMAKE_BUILD_TYPE}\n"
            "Set CMAKE_BUILD_TYPE to one of : ${ULTRA_ALLOWED_BUILD_TYPES}"
        )
    endif()
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
