qt_add_qml_module(VictronMock
    URI Victron.Mock
    STATIC
    OUTPUT_DIRECTORY Victron/Mock
    QML_FILES ${VictronMock_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

if (${VENUS_GX_BUILD})
    qt_query_qml_module(VictronMock QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock)
    install(DIRECTORY data/mock    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock/data)
endif()

qt_add_resources(VictronMock "VictronMock_resources"
    BIG_RESOURCES
    FILES ${VictronMock_QML_MODULE_RESOURCES}
)

