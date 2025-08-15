qt_add_qml_module(VictronMock
    URI Victron.Mock
    STATIC
    OUTPUT_DIRECTORY Victron/Mock
    QML_FILES ${VictronMock_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

if (${LOAD_QML_FROM_FILESYSTEM})
    qt_query_qml_module(VictronMock QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock)
    install(DIRECTORY data/mock    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock/data)
    add_custom_command(
        TARGET VictronMock
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()

qt_add_resources(VictronMock "VictronMock_resources"
    BIG_RESOURCES
    FILES ${VictronMock_QML_MODULE_RESOURCES}
)

