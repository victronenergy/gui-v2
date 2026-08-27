qt_add_library(VictronGauges STATIC)
qt_add_qml_module(VictronGauges
    URI Victron.Gauges
    OUTPUT_DIRECTORY Victron/Gauges
    QML_FILES ${VictronGauges_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

qt_query_qml_module(VictronGauges QML_FILES module_qml_files QMLDIR module_qmldir)
install(FILES ${module_qmldir}    DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/Gauges)
install(FILES ${module_qml_files} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/Gauges/components)

