qt_add_qml_module(VictronUiTest
    URI Victron.UiTest
    STATIC
    OUTPUT_DIRECTORY Victron/UiTest
    QML_FILES ${VictronUiTest_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

if (${VENUS_GX_BUILD})
    qt_query_qml_module(VictronUiTest QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/UiTest)
    install(DIRECTORY tests/ui    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/UiTest)
endif()

qt_add_resources(VictronUiTest "VictronUiTest_resources"
    BIG_RESOURCES
    FILES ${VictronUiTest_QML_MODULE_RESOURCES}
)

