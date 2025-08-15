if ("${RUN_UNIT_TESTS}" STREQUAL "ON")
    add_custom_command(
         TARGET ${PROJECT_NAME}
         COMMENT "Run tests"
         POST_BUILD
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
         COMMAND ${CMAKE_CTEST_COMMAND} -V -C $<CONFIGURATION> --output-on-failures
    )
endif()
