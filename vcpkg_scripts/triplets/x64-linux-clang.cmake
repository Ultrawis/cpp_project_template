set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Linux)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/../toolchains/clang-toolchain.cmake)
#set(VCPKG_C_FLAGS "-stdlib=libc++")
#set(VCPKG_C_FLAGS "-fPIC") # this is not used when using VCPKG_CHAINLOAD_TOOLCHAIN_FILE !!!
#set(VCPKG_CXX_FLAGS "-fPIC") # this is not used when using VCPKG_CHAINLOAD_TOOLCHAIN_FILE !!!

if(PORT MATCHES "ffmpeg")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
#string(APPEND CMAKE_C_FLAGS_INIT " -fPIC ${VCPKG_C_FLAGS} ") 
#string(APPEND CMAKE_CXX_FLAGS_INIT " -fPIC ${VCPKG_CXX_FLAGS} ") 

#message("clang triplet CMAKE_C_COMPILER = ${CMAKE_C_COMPILER}")
#message("clang triplet CMAKE_CXX_COMPILER = ${CMAKE_CXX_COMPILER}") 
