if ("${RUN_UNIT_TESTS}" STREQUAL "ON")
    add_custom_command(
         TARGET ${PROJECT_NAME}
         COMMENT "Run tests"
         POST_BUILD
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
         COMMAND ${CMAKE_CTEST_COMMAND} -V
                "$<$<BOOL:$<CONFIG>>:-C;$<CONFIG>>" # only pass -C when a config is set by the build tool
                --output-on-failure
    )

    if (VENUS_GUI_V2_TESTS_ENABLED)
        # Add dependency to each unit test, so that tests are not run
        # before all test targets are built.
        get_property(subdirs DIRECTORY "${CMAKE_SOURCE_DIR}/tests" PROPERTY SUBDIRECTORIES)
        foreach(subdir ${subdirs})
            if (EXISTS "${subdir}/CMakeLists.txt")
                cmake_path(GET subdir FILENAME dirName)
                add_dependencies(${PROJECT_NAME} "tst_${dirName}")
            endif()
        endforeach()
    endif()

endif()
