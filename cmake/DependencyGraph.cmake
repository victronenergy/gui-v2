# see if the dependency graph is correct, for translations support...
add_custom_target(dependency_graph
    "${CMAKE_COMMAND}" "--graphviz=${PROJECT_NAME}.dot" ${PROJECT_SOURCE_DIR}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)
