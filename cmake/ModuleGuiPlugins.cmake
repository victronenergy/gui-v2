# Victron.GuiPlugins: the types that plugin pages use (PluginDataItem, the
# access levels, and the Plugin* UI types). See "Module dependencies" in
# .github/architecture.md.
#
# This module uses Victron.VenusOS: the Plugin* UI types are thin wrappers over
# the internal VenusOS types. So Victron.VenusOS must never use this module.
# Only the app and the tests link it, so that plugin QML can import it at run
# time. Its sources live in guiplugins/, apart from the VenusOS sources.

# The module version. tools/guipluginsapi.py reads these two lines, and records
# in tools/guiplugins-api.json the version that added each type and member. A
# new member gets the current version, so after a release, increase the minor
# version before adding to the API. See .github/gui-plugins.md.
set(VICTRON_GUIPLUGINS_VERSION_MAJOR 1)
set(VICTRON_GUIPLUGINS_VERSION_MINOR 0)

# The plugin loader in Victron.VenusOS checks each plugin's
# requiredGuiPluginsVersion against this version. Only the two numbers are
# passed: Victron.VenusOS still does not use this module.
target_compile_definitions(VictronVenusOS PRIVATE
    VICTRON_GUIPLUGINS_VERSION_MAJOR=${VICTRON_GUIPLUGINS_VERSION_MAJOR}
    VICTRON_GUIPLUGINS_VERSION_MINOR=${VICTRON_GUIPLUGINS_VERSION_MINOR}
)

# Keep the file names flat in the module, so that the qmldir lists
# PluginPage.qml rather than guiplugins/PluginPage.qml.
foreach(qml_file ${VictronGuiPlugins_QML_MODULE_SOURCES})
    get_filename_component(qml_file_name ${qml_file} NAME)
    set_source_files_properties(${qml_file} PROPERTIES QT_RESOURCE_ALIAS ${qml_file_name})
endforeach()

qt_add_library(VictronGuiPlugins STATIC)
qt_add_qml_module(VictronGuiPlugins
    ${QML_MODULE_OPTARGS}
    URI Victron.GuiPlugins
    VERSION ${VICTRON_GUIPLUGINS_VERSION_MAJOR}.${VICTRON_GUIPLUGINS_VERSION_MINOR}
    OUTPUT_DIRECTORY Victron/GuiPlugins
    QML_FILES ${VictronGuiPlugins_QML_MODULE_SOURCES}
    SOURCES ${VictronGuiPlugins_CPP_SOURCES}
    DEPENDENCIES QtQuick Victron.VenusOS
)

target_include_directories(VictronGuiPlugins PUBLIC ${PROJECT_SOURCE_DIR}/guiplugins)

target_link_libraries(VictronGuiPlugins PRIVATE
    VictronVenusOS
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    # PluginDataItem uses BackendConnection, whose header includes the Qt MQTT
    # headers, and in WebAssembly builds the Qt WebSockets headers.
    Qt6::Mqtt
)
if(VENUS_WEBASSEMBLY_BUILD)
    target_link_libraries(VictronGuiPlugins PRIVATE Qt6::WebSockets)
endif()

# The app loads Victron QML files from the install directory when that exists
# (see src/urlinterceptor.cpp), so the QML files are installed next to the
# qmldir. The qmltypes file lets tools check plugin QML against this module.
qt_query_qml_module(VictronGuiPlugins
    QML_FILES module_qml_files
    QMLDIR module_qmldir
    TYPEINFO module_typeinfo
)
install(
    FILES ${module_qmldir} ${module_typeinfo} ${module_qml_files}
    DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/GuiPlugins
)
