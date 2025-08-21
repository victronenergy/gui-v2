qt_add_qml_module(VictronGauges
    URI Victron.Gauges
    STATIC
    OUTPUT_DIRECTORY Victron/Gauges
    QML_FILES ${VictronGauges_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

if (${VENUS_GX_BUILD})
    qt_query_qml_module(VictronGauges QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir}    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Gauges)
    install(FILES ${module_qml_files} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Gauges/components)
endif()

