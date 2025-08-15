list(APPEND TRANSLATION_SOURCES ${VictronVenusOS_QML_MODULE_SOURCES})
list(APPEND TRANSLATION_SOURCES ${VictronVenusOS_CPP_SOURCES})
list(APPEND TRANSLATION_SOURCES ${VictronMock_QML_MODULE_SOURCES})
list(APPEND TRANSLATION_SOURCES ${VictronGauges_QML_MODULE_SOURCES})
list(APPEND TRANSLATION_SOURCES ${VictronBoat_QML_MODULE_SOURCES})
list(APPEND TRANSLATION_SOURCES ${GUIV2_CPP_SOURCES})
list(APPEND TRANSLATION_SOURCES ${GUIV2_QML_SOURCES})

# Add targets to update the ts files from poeditor.
foreach(code IN LISTS ${TS_CODES})
    set(output_file ${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}_${code}.ts)
    set(new_target ${PROJECT_NAME}_${code})
    add_custom_target( ${new_target}
        COMMAND bash "-c" "${CMAKE_CURRENT_SOURCE_DIR}/.github/scripts/download_from_poeditor.sh ${code} ${output_file}"
    )
    list(APPEND TS_TARGETS ${new_target})
endforeach()

add_custom_target(download_translations
    DEPENDS ${TS_TARGETS}
)

add_custom_target(upload_translations
    COMMAND bash "-c" "${CMAKE_CURRENT_SOURCE_DIR}/.github/scripts/upload_new_terms.sh ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}.ts"
    DEPENDS ${PROJECT_NAME}
)

# Copy the input .ts files to the build directory before running lupdate on the copies.
# That way if new entries are added in code, the updates don't pollute the git diff.
# Then run lupdate manually and lrelease manually, and mark the generated files as GENERATED TRUE
# to force CMake to respect an appropriate dependency ordering.
SET(BUILD_DIR_TS_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
)
SET(BUILD_DIR_QM_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm"
)
foreach(TsCode IN ITEMS ${TS_CODES})
    message(STATUS "Generating expected translation catalogue filename for ts code: ${TsCode}...")
    list(APPEND BUILD_DIR_TS_FILES
        "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
    )
    list(APPEND BUILD_DIR_QM_FILES
        "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm"
    )
endforeach()

list(APPEND ABSOLUTE_PATH_TRANSLATION_SOURCES ${TRANSLATION_SOURCES})
list(TRANSFORM ABSOLUTE_PATH_TRANSLATION_SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/")
file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt"
    CONTENT "$<JOIN:${ABSOLUTE_PATH_TRANSLATION_SOURCES},\n>"
)
add_custom_target(generate_translation_sources_file ALL
    COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}.ts" "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
    DEPENDS ${TRANSLATION_SOURCES} "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
    COMMENT "copying: ${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}.ts to ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
)
set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts" PROPERTIES
    GENERATED TRUE
)
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm"
    COMMAND Qt6::lupdate -no-obsolete "@${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt" -ts "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts" -I "${CMAKE_CURRENT_SOURCE_DIR}/src/veutil/inc"
    COMMAND Qt6::lrelease -idbased "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts" -qm "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm"
    DEPENDS "${PROJECT_SOURCE_DIR}/src/themeobjects.h" "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
    COMMENT "Running lupdate and lrelease for ${PROJECT_NAME}_en.ts"
)
set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm" PROPERTIES
    QT_RESOURCE_ALIAS "${PROJECT_NAME}_en.qm"
    GENERATED TRUE
)
foreach(TsCode IN ITEMS ${TS_CODES})
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
        DEPENDS ${TRANSLATION_SOURCES} "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
        COMMENT "copying: ${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts to ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
    )
    set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" PROPERTIES
        GENERATED TRUE
    )
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm"
        COMMAND Qt6::lupdate -no-obsolete "@${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt" -ts "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" -I "${CMAKE_CURRENT_SOURCE_DIR}/src/veutil/inc"
        COMMAND Qt6::lrelease -idbased "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" -qm "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm"
        DEPENDS "${PROJECT_SOURCE_DIR}/src/themeobjects.h" "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
        COMMENT "Running lupdate and lrelease for ${PROJECT_NAME}_${TsCode}.ts"
    )
    message(STATUS "Setting translation catalogue properties and resource alias for: ${PROJECT_NAME}_${TsCode}.qm")
    set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm"
        PROPERTIES
        QT_RESOURCE_ALIAS "${PROJECT_NAME}_${TsCode}.qm"
        GENERATED TRUE
    )
endforeach()

add_custom_target(
    qm_files_exist
    DEPENDS ${BUILD_DIR_QM_FILES}
)

