qt_add_library(VictronUiTest STATIC)
qt_add_qml_module(VictronUiTest
    URI Victron.UiTest
    OUTPUT_DIRECTORY Victron/UiTest
    QML_FILES ${VictronUiTest_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

qt_query_qml_module(VictronUiTest QML_FILES module_qml_files QMLDIR module_qmldir)
install(FILES ${module_qmldir} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/UiTest)
install(DIRECTORY tests/ui    DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/UiTest/tests)

qt_add_resources(VictronUiTest "VictronUiTest_resources"
    BIG_RESOURCES
    FILES ${VictronUiTest_QML_MODULE_RESOURCES}
)

