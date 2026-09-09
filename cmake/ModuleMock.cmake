qt_add_library(VictronMock STATIC)
qt_add_qml_module(VictronMock
    URI Victron.Mock
    OUTPUT_DIRECTORY Victron/Mock
    QML_FILES ${VictronMock_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

qt_query_qml_module(VictronMock QML_FILES module_qml_files QMLDIR module_qmldir)
install(FILES ${module_qmldir} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/Mock)
install(DIRECTORY data/mock    DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/Mock/data)

qt_add_resources(VictronMock "VictronMock_resources"
    BIG_RESOURCES
    FILES ${VictronMock_QML_MODULE_RESOURCES}
)

