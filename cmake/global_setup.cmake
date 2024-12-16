macro(configure_default_output_directories)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    set(ULTRA_COMPILED_SHADERS_DIRECTORY ${CMAKE_BINARY_DIR}/compiled_shaders)
    set(ULTRA_AUTOGENERATED_DIRECTORY ${CMAKE_BINARY_DIR}/autogenerated)
    file(MAKE_DIRECTORY ${ULTRA_AUTOGENERATED_DIRECTORY})
    set(ULTRA_COMPILED_SHADERS_DIRECTORY_PER_CONFIG ${ULTRA_COMPILED_SHADERS_DIRECTORY}/$<IF:$<CONFIG:Debug>,Debug,Release>)

    # message("===================================================================")
    # message("CMAKE_ARCHIVE_OUTPUT_DIRECTORY = ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
    # message("CMAKE_LIBRARY_OUTPUT_DIRECTORY = ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
    # message("CMAKE_RUNTIME_OUTPUT_DIRECTORY = ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    # message("===================================================================")
endmacro()

macro(configure_default_output_directories_relative base_dir)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${base_dir}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${base_dir}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${base_dir}/bin)
    set(ULTRA_COMPILED_SHADERS_DIRECTORY ${base_dir}/compiled_shaders)
    set(ULTRA_COMPILED_SHADERS_DIRECTORY_PER_CONFIG ${ULTRA_COMPILED_SHADERS_DIRECTORY}/$<IF:$<CONFIG:Debug>,Debug,Release>)
    set(ULTRA_AUTOGENERATED_DIRECTORY ${base_dir}/autogenerated)
    file(MAKE_DIRECTORY ${ULTRA_AUTOGENERATED_DIRECTORY})
endmacro()