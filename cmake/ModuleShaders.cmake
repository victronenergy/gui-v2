qt_add_library(VictronVenusOSShaders STATIC)
qt_add_qml_module(VictronVenusOSShaders
    ${QML_MODULE_OPTARGS}
    URI Victron.VenusOS.Shaders
    VERSION 2.0
    OUTPUT_DIRECTORY Victron/VenusOS/Shaders
    QML_FILES ${VictronVenusOSShaders_QML_MODULE_SOURCES}
)

qt6_add_shaders(VictronVenusOSShaders "venus-shaders"
    BATCHABLE
    PRECOMPILE
    OPTIMIZED
    PREFIX "/"
    FILES ${VictronVenusOSShaders_QML_MODULE_SHADERS}
)

qt_query_qml_module(VictronVenusOSShaders QML_FILES module_qml_files QMLDIR module_qmldir)
install(DIRECTORY components/shaders  DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/VenusOS/Shaders/components)
install(FILES ${module_qmldir} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/VenusOS/Shaders)
