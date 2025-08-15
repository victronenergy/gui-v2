qt_add_qml_module(VictronVenusOSShaders
    ${QML_MODULE_OPTARGS}
    URI Victron.VenusOS.Shaders
    VERSION 2.0
    STATIC
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
