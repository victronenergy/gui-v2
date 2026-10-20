# Victron.Branding: the Branding type that branding plugins instantiate.
# This module depends only on Qt. Do not import, include or link any other
# Victron module here: Victron.VenusOS depends on this module, not the reverse.

qt_add_library(VictronBranding STATIC)
qt_add_qml_module(VictronBranding
    ${QML_MODULE_OPTARGS}
    URI Victron.Branding
    VERSION 1.0
    OUTPUT_DIRECTORY Victron/Branding
    SOURCES ${VictronBranding_CPP_SOURCES}
    # QtQuick provides the QML "color" type used by the Branding properties.
    # Importing it (not just declaring it as a dependency) loads it whenever a
    # Branding file is loaded: the app loads branding plugins before anything
    # else has imported QtQuick, and without it the color strings in a Branding
    # file are silently ignored. It also lets qmllint check color assignments.
    IMPORTS QtQuick
)

target_include_directories(VictronBranding PUBLIC ${PROJECT_SOURCE_DIR}/src/branding)

target_link_libraries(VictronBranding PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
)
