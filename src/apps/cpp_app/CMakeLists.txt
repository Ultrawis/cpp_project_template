
set_source_group(
    run
    main.cpp
)

add_executable(app ${run})

target_link_libraries(app PRIVATE core)

set_target_properties(app PROPERTIES FOLDER apps)

target_link_libraries(
    app
    PRIVATE
    ultra_strict_compiler_flags
)