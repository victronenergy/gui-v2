if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )

    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/wasm/index.html")
    add_custom_target(WasmFiles SOURCES wasm/index.html)
    add_custom_command(
       TARGET ${PROJECT_NAME} POST_BUILD
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/wasm/index.html"
            "${CMAKE_CURRENT_BINARY_DIR}/venus-gui-v2.html"
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/images/victronenergy.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/victronenergy.svg"
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/images/victronenergy-light.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/victronenergy-light.svg"
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/images/mockup.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/mockup.svg"
    )
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    list(APPEND venusCompileFlags  ${UNIX_COMPILE_FLAGS})
    qt_add_executable(${PROJECT_NAME}
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
else()
    list(APPEND venusCompileFlags ${UNIX_COMPILE_FLAGS})
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
endif()

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES ${GUIV2_QML_SOURCES}
    IMPORTS Victron.VenusOS
)

qt_add_resources(${PROJECT_NAME} "${PROJECT_NAME}_translations_resources"
    PREFIX "/i18n"
    BIG_RESOURCES
    FILES ${BUILD_DIR_QM_FILES}
)

if (${VENUS_GX_BUILD})
    qt_query_qml_module(${PROJECT_NAME} QML_FILES module_qml_files QMLDIR module_qmldir)
    install(TARGETS ${PROJECT_NAME}
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    install(FILES ${module_qml_files} ${module_qmldir} $<TARGET_FILE:${PROJECT_NAME}> DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(FILES $<TARGET_FILE:${PROJECT_NAME}> DESTINATION ${CMAKE_INSTALL_BINDIR} PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

add_link_options(
    $<$<CONFIG:RELEASE>:-s>     # strip the binary for Release builds
    $<$<CONFIG:MINSIZEREL>:-s>  # strip the binary for MinSizeRel builds
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::Xml
    Qt6::Mqtt
)

if(VENUS_WEBASSEMBLY_BUILD)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::WebSockets
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::DBus
    )
endif()
