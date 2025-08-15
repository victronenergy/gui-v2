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

if (${LOAD_QML_FROM_FILESYSTEM})
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

    # Load all qml resources from the filesystem.
    # Qt6 cmake projects don't support this properly, see https://bugreports.qt.io/browse/QTBUG-120435
    # When a qml module is loaded, the associated qmldir file is read. By default, it looks like this:

        # module Victron.VenusOS
        # linktarget VictronVenusOSplugin
        # optional plugin VictronVenusOSplugin
        # classname Victron_VenusOSPlugin
        # typeinfo VictronVenusOS.qmltypes
        # prefer :/qt/qml/Victron/VenusOS/  <- this line tells the app to prefer the compiled qml sources, i.e. don't load from the file system
        # singleton CommonWords 2.0 components/CommonWords.qml
        # [lots more qml files]

    # The 'prefer' line can't be removed via 'qt_add_qml_module', we need to delete it after the build step, and before the install step.
    # That is what the calls to 'StripRegexFromFile.cmake' are for.
    add_custom_command(
        TARGET VictronVenusOS
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()

