set(GUIV2_QML_SOURCES
    Main.qml
)

set(GUIV2_CPP_SOURCES
    src/main.cpp
    src/mqttaddress.cpp
)

set_source_files_properties(
    ${GUIV2_CPP_SOURCES}
    PROPERTIES
    COMPILE_OPTIONS "${venusCompileFlags}"
)

list(APPEND SOURCES ${GUIV2_CPP_SOURCES})
