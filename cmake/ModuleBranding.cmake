# Victron.Branding: the Branding type that branding plugins instantiate.
# This module depends only on Qt. Do not import, include or link any other
# Victron module here: Victron.VenusOS depends on this module, not the reverse.

# The module version, which a plugin's requiredBrandingVersion is checked against.
# tools/brandingproperties.py reads these two lines. When adding a Branding
# property, increase the minor version and tag the property with
# REVISION(major, minor). See .github/branding-plugins.md.
set(VICTRON_BRANDING_VERSION_MAJOR 1)
set(VICTRON_BRANDING_VERSION_MINOR 0)

qt_add_library(VictronBranding STATIC)
qt_add_qml_module(VictronBranding
    ${QML_MODULE_OPTARGS}
    URI Victron.Branding
    VERSION ${VICTRON_BRANDING_VERSION_MAJOR}.${VICTRON_BRANDING_VERSION_MINOR}
    OUTPUT_DIRECTORY Victron/Branding
    SOURCES ${VictronBranding_CPP_SOURCES}
    # QtQuick provides the QML "color" type used by the Branding properties;
    # without this, qmllint cannot check color assignments in Branding files.
    DEPENDENCIES QtQuick
)

target_include_directories(VictronBranding PUBLIC ${PROJECT_SOURCE_DIR}/src/branding)
target_compile_definitions(VictronBranding PUBLIC
    VICTRON_BRANDING_VERSION_MAJOR=${VICTRON_BRANDING_VERSION_MAJOR}
    VICTRON_BRANDING_VERSION_MINOR=${VICTRON_BRANDING_VERSION_MINOR})

target_link_libraries(VictronBranding PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
)

# The qmldir and qmltypes are installed next to the plugin compiler, so that it
# can run qmllint against this module.
qt_query_qml_module(VictronBranding QMLDIR module_qmldir TYPEINFO module_typeinfo)
install(FILES ${module_qmldir} ${module_typeinfo} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/Branding)
