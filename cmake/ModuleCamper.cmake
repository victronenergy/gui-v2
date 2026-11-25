# The RV illustration. It uses only Qt Quick, so that hosts without gui-v2, such as
# tools/camperview, can build it. tools/moduledependencies.py and CheckModuleLinks.cmake enforce that.

# The source lists are relative to the gui-v2 source directory, which a standalone host sets here.
if(NOT DEFINED VictronCamper_ROOT_DIR)
    set(VictronCamper_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()

# Flat QML aliases put every type at the module root, and the images keep their qrc:/images/... paths.
set(_victron_camper_qml_files "")
foreach(qml_file IN LISTS VictronCamper_QML_MODULE_SOURCES)
    get_filename_component(qml_name "${qml_file}" NAME)
    set_source_files_properties("${VictronCamper_ROOT_DIR}/${qml_file}" PROPERTIES QT_RESOURCE_ALIAS "${qml_name}")
    list(APPEND _victron_camper_qml_files "${VictronCamper_ROOT_DIR}/${qml_file}")
endforeach()
set(_victron_camper_resource_files "")
foreach(resource_file IN LISTS VictronCamper_QML_MODULE_RESOURCES)
    set_source_files_properties("${VictronCamper_ROOT_DIR}/${resource_file}" PROPERTIES QT_RESOURCE_ALIAS "${resource_file}")
    list(APPEND _victron_camper_resource_files "${VictronCamper_ROOT_DIR}/${resource_file}")
endforeach()

qt_add_library(VictronCamper STATIC)
qt_add_qml_module(VictronCamper
    URI Victron.Camper
    OUTPUT_DIRECTORY Victron/Camper
    DEPENDENCIES QtQuick QtQuick.Controls.impl
    QML_FILES ${_victron_camper_qml_files}
    ${QML_MODULE_OPTARGS}
)

# Links the QtQuick.Controls.impl plugin (for ColorImage) into a static build, as a host's
# qt_import_qml_plugins() scans only the host's own QML files and would leave it out.
get_target_property(_victron_camper_qt_type Qt6::Core TYPE)
if(_victron_camper_qt_type STREQUAL "STATIC_LIBRARY")
    target_link_libraries(VictronCamper PUBLIC Qt6::qtquickcontrols2implplugin)
endif()

qt_add_resources(VictronCamper "VictronCamper_large_resources"
    PREFIX "/"
    BIG_RESOURCES
    FILES ${_victron_camper_resource_files}
)

# Installed beside the other modules, as Victron.Boat is. A standalone host installs nothing.
if(DEFINED VENUS_QML_INSTALL_DIR)
    qt_query_qml_module(VictronCamper QMLDIR module_qmldir)
    install(FILES ${_victron_camper_qml_files} ${module_qmldir} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/Camper)
endif()
