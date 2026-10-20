qt_add_library(VictronVenusOS STATIC)
qt_add_qml_module(VictronVenusOS
    ${QML_MODULE_OPTARGS}
    URI Victron.VenusOS
    VERSION 2.0
    IMPORTS QtQuick.Controls.Basic
    OUTPUT_DIRECTORY Victron/VenusOS
    QML_FILES ${VictronVenusOS_QML_MODULE_SOURCES}
    SOURCES ${VictronVenusOS_CPP_SOURCES}
)

# The color computations must round identically on every platform, so that the tests which compare
# exact expected colors pass on GX devices too: do not let the compiler combine a multiply and an
# add into one fused multiply-add instruction. (MSVC, from Visual Studio 2022, does not do this
# under its default /fp:precise.)
set_source_files_properties(src/colorderivation.cpp PROPERTIES
    COMPILE_OPTIONS "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-ffp-contract=off>")

qt_add_resources(VictronVenusOS "VictronVenusOS_large_resources"
    BIG_RESOURCES
    FILES ${VictronVenusOS_RESOURCES}
)

target_include_directories(VictronVenusOS PRIVATE src/veutil/inc/veutil/qt)
target_include_directories(VictronVenusOS PUBLIC ${PROJECT_SOURCE_DIR}/src
                                                 ${PROJECT_SOURCE_DIR}/src/veutil/inc
                                                 ${PROJECT_SOURCE_DIR}/src/veutil/inc/veutil/qt)

# VenusOS uses Victron.Branding from C++ only (GuiPluginLoader and Theme).
target_link_libraries(VictronVenusOS PUBLIC VictronBranding)

target_link_libraries(VictronVenusOS PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::QuickPrivate
    Qt6::QuickTemplates2Private
    Qt6::Xml
    Qt6::Mqtt
)

if(VENUS_WEBASSEMBLY_BUILD)
    target_link_libraries(VictronVenusOS PRIVATE Qt6::WebSockets)
else()
    target_link_libraries(VictronVenusOS PRIVATE Qt6::DBus)
endif()

qt_query_qml_module(VictronVenusOS QML_FILES module_qml_files QMLDIR module_qmldir)
install(
    FILES
        ${module_qmldir}
        ApplicationContent.qml
        FrameRateVisualizer.qml
        Global.qml
    DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/VenusOS)
install(
    DIRECTORY
        components
        data
        pages
    DESTINATION ${VENUS_QML_INSTALL_DIR}/Victron/VenusOS)
install(
    FILES
        ${PROJECT_SOURCE_DIR}/tools/gui-v2-plugin-compiler.py
        ${PROJECT_SOURCE_DIR}/tools/branding-properties.json
    DESTINATION ${VENUS_QML_INSTALL_DIR})

