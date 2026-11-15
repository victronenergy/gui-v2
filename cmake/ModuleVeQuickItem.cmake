# Victron.VeQuickItem: the veutil sources, including the VeQuickItem type and
# the VeQItem type it uses. This module depends only on Qt. Do not import, include or link any other
# Victron module here: Victron.VenusOS depends on this module, not the reverse.

qt_add_library(VictronVeQuickItem STATIC)
qt_add_qml_module(VictronVeQuickItem
    ${QML_MODULE_OPTARGS}
    URI Victron.VeQuickItem
    VERSION 1.0
    OUTPUT_DIRECTORY Victron/VeQuickItem
    SOURCES ${VictronVeQuickItem_CPP_SOURCES}
)

# The generated QML type registrations include the headers by file name only.
target_include_directories(VictronVeQuickItem PRIVATE ${PROJECT_SOURCE_DIR}/src/veutil/inc/veutil/qt)
target_include_directories(VictronVeQuickItem PUBLIC ${PROJECT_SOURCE_DIR}/src/veutil/inc)

target_link_libraries(VictronVeQuickItem PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Mqtt
)

if(VENUS_WEBASSEMBLY_BUILD)
    target_link_libraries(VictronVeQuickItem PRIVATE Qt6::WebSockets)
else()
    target_link_libraries(VictronVeQuickItem PRIVATE Qt6::DBus Qt6::Xml)
endif()

# The qmldir and qmltypes are installed, so that the qmldir of Victron.VenusOS,
# which imports this module, can be resolved from the install directory.
qt_query_qml_module(VictronVeQuickItem QMLDIR module_qmldir TYPEINFO module_typeinfo)
install(FILES ${module_qmldir} ${module_typeinfo} DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/VeQuickItem)
