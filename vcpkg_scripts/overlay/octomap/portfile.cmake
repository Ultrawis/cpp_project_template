vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eladm-ultrawis/octomap
    REF ac81582cec209fa1da6ac53e9bc8b0d70e58b882 # set to commmit SHA1 you want
    SHA512 54853c5daa52045af592ec438e07e0f52a863e49fa3573b45e7e98068af792326755554191475282970dcc8c5a28effb7359a22a5684a3c9c9da0dacc9c8ae51 # set to 0, look at the error
    HEAD_REF master
    PATCHES
      "001-fix-exported-targets.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_OCTOVIS_SUBPROJECT=OFF
        -DBUILD_DYNAMICETD3D_SUBPROJECT=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_tools(
    TOOL_NAMES binvox2bt bt2vrml compare_octrees convert_octree edit_octree eval_octree_accuracy graph2tree log2graph
    AUTO_CLEAN)

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/octomap")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/octomap/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
