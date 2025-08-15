set(GUIV2_QML_SOURCES
    Main.qml
)

set(GUIV2_CPP_SOURCES
    src/main.cpp
    src/logging.h
    src/veqitemmockproducer.h
    src/veqitemmockproducer.cpp
)

set_source_files_properties(
    ${GUIV2_CPP_SOURCES}
    PROPERTIES
    COMPILE_OPTIONS "${venusCompileFlags}"
)

list(APPEND SOURCES ${GUIV2_CPP_SOURCES})
