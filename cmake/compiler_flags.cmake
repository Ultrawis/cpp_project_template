# set(ULTRA_NOT_DEBUG "$<OR:$<CONFIG:Release>, $<CONFIG:RelWithDebInfo>>")
set(ULTRA_NOT_DEBUG "$<NOT:$<CONFIG:Debug>>")
set(ULTRA_COMPILER_IS_GCC_LIKE "$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>")
set(ULTRA_COMPILER_IS_MSVC "$<COMPILE_LANG_AND_ID:CXX,MSVC>")
set(ULTRA_GCC_LIKE_STRICT_FLAGS "-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused")
set(ULTRA_MSVC_STRICT_FLAGS "/W4;/EHsc") # (/EHsc) is somehow not set on Ninja
set(ULTRA_WARNING_AS_ERROR_FLAG "$<IF:${ULTRA_COMPILER_IS_MSVC},/WX,-Werror>")
set(ULTRA_TREAT_WARNING_AS_ERROR "$<${ULTRA_NOT_DEBUG}:${ULTRA_WARNING_AS_ERROR_FLAG}>")

#[[ 
clang flags
https://clang.llvm.org/docs/ClangCommandLineReference.html
clang cpp status
https://clang.llvm.org/cxx_status.html

'-std=c++14' for 'ISO C++ 2014 with amendments' standard
'-std=gnu++14' for 'ISO C++ 2014 with amendments and GNU extensions' standard
'-std=c++17' for 'ISO C++ 2017 with amendments' standard
'-std=gnu++17' for 'ISO C++ 2017 with amendments and GNU extensions' standard
'-std=c++20' for 'ISO C++ 2020 DIS' standard
'-std=gnu++20' for 'ISO C++ 2020 DIS with GNU extensions' standard
'-std=c++2b' for 'Working draft for ISO C++ 2023 DIS' standard
'-std=gnu++2b' for 'Working draft for ISO C++ 2023 DIS with GNU extensions' standard

C++ standard library to use.
-stdlib=libc++ # llvm
-stdlib=libstdc++ # gnu

-fexperimental-library
]]
set(ULTRA_ALL_FLAGS
    $<${ULTRA_COMPILER_IS_GCC_LIKE}:${ULTRA_GCC_LIKE_STRICT_FLAGS}>
    $<${ULTRA_COMPILER_IS_MSVC}:${ULTRA_MSVC_STRICT_FLAGS}>
    ${ULTRA_TREAT_WARNING_AS_ERROR}
)

#set(ULTRA_ALL_DEFINITIONS
#    $<$<CONFIG:Profile>:ULTRA_PROFILING_ENABLED>
#    )

set(ULTRA_ALL_DEFINITIONS
    $<$<OR:$<CONFIG:Profile>,$<CONFIG:Debug>>:ULTRA_PROFILING_ENABLED>
)

set(ULTRA_ALL_FLAGS_23
    ${ULTRA_ALL_FLAGS}
    $<$<CXX_COMPILER_ID:Clang>:-std=c++2b> # https://discourse.llvm.org/t/linux-what-is-the-status-of-libc-in-llvm-15-apt-packages-ranges-format/65348/4
)

add_library(ultra_strict_compiler_flags INTERFACE)

target_compile_options(
    ultra_strict_compiler_flags
    INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:${ULTRA_ALL_FLAGS_23}>
)


target_compile_definitions(
    ultra_strict_compiler_flags
    INTERFACE
    ${ULTRA_ALL_DEFINITIONS}
)

# target_link_options(
# ultra_strict_compiler_flags
# INTERFACE
# $<$<CXX_COMPILER_ID:Clang>: -fexperimental-library -stdlib=libc++>
# )
target_compile_features(
    ultra_strict_compiler_flags
    INTERFACE
    cxx_std_23
)

add_library(ultra_strict_compiler_flags_17 INTERFACE)

target_compile_features(
    ultra_strict_compiler_flags_17
    INTERFACE
    cxx_std_17
)

target_compile_definitions(
    ultra_strict_compiler_flags_17
    INTERFACE
    ${ULTRA_ALL_DEFINITIONS}
)


function(set_no_warnings_compiler_flags target_name)
    target_compile_features(
        ${target_name}
        PRIVATE
        cxx_std_17
    )

    if(MSVC)
        target_compile_options(
            ${target_name}
            PRIVATE
            /W1
        )
    else()
        target_compile_options(
            ${target_name}
            PRIVATE
            -w
        )
    endif()
endfunction()
