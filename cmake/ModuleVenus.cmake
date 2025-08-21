qt_add_qml_module(VictronVenusOS
    ${QML_MODULE_OPTARGS}
    URI Victron.VenusOS
    VERSION 2.0
    STATIC
    IMPORTS QtQuick.Controls.Basic
    OUTPUT_DIRECTORY Victron/VenusOS
    QML_FILES ${VictronVenusOS_QML_MODULE_SOURCES}
    SOURCES ${VictronVenusOS_CPP_SOURCES}
)

qt_add_resources(VictronVenusOS "VictronVenusOS_large_resources"
    BIG_RESOURCES
    FILES ${VictronVenusOS_RESOURCES}
)

target_include_directories(VictronVenusOS PRIVATE src/veutil/inc/veutil/qt)

target_link_libraries(VictronVenusOS PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::QuickPrivate
    Qt6::Xml
    Qt6::Mqtt
)

if(VENUS_WEBASSEMBLY_BUILD)
    target_link_libraries(VictronVenusOS PRIVATE Qt6::WebSockets)
else()
    target_link_libraries(VictronVenusOS PRIVATE Qt6::DBus)
endif()

if (${VENUS_GX_BUILD})
    qt_query_qml_module(VictronVenusOS QML_FILES module_qml_files QMLDIR module_qmldir)
    install(
        FILES
            ${module_qmldir}
            ApplicationContent.qml
            FrameRateVisualizer.qml
            Global.qml
        DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/VenusOS)
    install(
        DIRECTORY
            components
            data
            pages
        DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/VenusOS)
endif()

