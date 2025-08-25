# TODO - Remove the following block once aqtinstall supports 'qt6_add_shaders(...)'.
# CI wasm builds use aqtinstall, which doesn't support qt6_add_shaders.
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten" AND NOT COMMAND qt6_add_shaders)
    function(qt6_add_shaders target name)
        set(options BATCHABLE PRECOMPILE OPTIMIZED)
        set(oneValueArgs PREFIX)
        set(multiValueArgs FILES)
        cmake_parse_arguments(SHADER "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

        # Find qsb tool
        if("${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "aarch64" OR "${CMAKE_HOST_SYSTEM_PROCESSOR}" STREQUAL "arm64")
            find_program(QSB_TOOL qsb
                PATHS
                    /opt/venus/build-gx-hostedtoolcache/Qt/6.8.3/gcc_arm64/bin
                NO_DEFAULT_PATH
            )
        else()
            find_program(QSB_TOOL qsb
                PATHS /opt/venus/build-gx-hostedtoolcache/Qt/6.8.3/gcc_64/bin
                NO_DEFAULT_PATH
            )
        endif()

        if(NOT QSB_TOOL)
            message(FATAL_ERROR "qsb tool not found")
        endif()

        # Process each shader file
        foreach(shader_file ${SHADER_FILES})
            get_filename_component(shader_name ${shader_file} NAME)
            get_filename_component(shader_dir ${shader_file} DIRECTORY)

            # Output file
            set(output_file "${CMAKE_CURRENT_BINARY_DIR}/${shader_dir}/${shader_name}.qsb")

            # Create directory if needed
            get_filename_component(output_dir ${output_file} DIRECTORY)
            file(MAKE_DIRECTORY ${output_dir})

            # Add custom command to compile shader
            add_custom_command(
                OUTPUT ${output_file}
                COMMAND ${QSB_TOOL} --glsl "100 es,120,150" --hlsl 50 --msl 12 -o ${output_file} ${CMAKE_CURRENT_SOURCE_DIR}/${shader_file}
                DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${shader_file}
                COMMENT "Compiling shader ${shader_file}"
            )

            # Add to target
            target_sources(${target} PRIVATE ${output_file})
            set_source_files_properties(${output_file} PROPERTIES QT_RESOURCE_ALIAS "${shader_file}.qsb")

            # Add to resource files
            list(APPEND qsb_files "${output_file}")
        endforeach()

        # Add resource file containing the qsb files
        qt6_add_resources(${target} "${target}_resources"
            FILES "${qsb_files}"
        )
    endfunction()

    message(STATUS "Created custom qt6_add_shaders function")
endif()

