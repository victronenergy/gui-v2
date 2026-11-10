# Victron.VeUtil: VeQuickItem, the VeQItem producers (MQTT, and D-Bus outside
# WebAssembly) and the other QML types of the veutil submodule.
#
# This module depends only on Qt. Do not import, include or link any other
# Victron module here: Victron.VenusOS depends on this module, not the reverse.
# That lets a small app, such as a standalone illustration, use VeQuickItem and
# an MQTT backend without pulling in Victron.VenusOS. See "Module dependencies"
# in .github/architecture.md.

qt_add_library(VictronVeUtil STATIC)
qt_add_qml_module(VictronVeUtil
    ${QML_MODULE_OPTARGS}
    URI Victron.VeUtil
    VERSION 1.0
    OUTPUT_DIRECTORY Victron/VeUtil
    SOURCES ${VictronVeUtil_CPP_SOURCES}
    DEPENDENCIES QtQuick
)

target_include_directories(VictronVeUtil PUBLIC
    ${PROJECT_SOURCE_DIR}/src/veutil/inc
    ${PROJECT_SOURCE_DIR}/src/veutil/inc/veutil/qt)

# The public headers include the Qt Quick, Qt MQTT and (outside WebAssembly)
# Qt D-Bus headers, so whoever links this module needs them too.
target_link_libraries(VictronVeUtil PUBLIC
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Mqtt
)

if(VENUS_WEBASSEMBLY_BUILD)
    # ve_qitems_mqtt.hpp declares different members when this is defined, so
    # every file that includes it, in this module or in an app that links it,
    # must see the same definition.
    target_compile_definitions(VictronVeUtil PUBLIC MQTT_WEBSOCKETS_ENABLED)
    target_link_libraries(VictronVeUtil PUBLIC Qt6::WebSockets)
else()
    # ve_qitems_dbus.cpp reads the D-Bus introspection XML.
    target_link_libraries(VictronVeUtil PUBLIC Qt6::DBus PRIVATE Qt6::Xml)
endif()

# The qmldir and qmltypes are installed next to the plugin compiler, so that
# qmllint can resolve the types that Victron.VenusOS imports from this module.
qt_query_qml_module(VictronVeUtil QMLDIR module_qmldir TYPEINFO module_typeinfo)
install(FILES ${module_qmldir} ${module_typeinfo} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/VeUtil)
