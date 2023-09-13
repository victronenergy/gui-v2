cmake_minimum_required(VERSION 3.5)

cmake_policy(SET CMP0071 NEW) # process GENERATED source files in AUTOMOC and AUTOUIC. Added to silence a cmake warning.
cmake_policy(SET CMP0079 NEW)

project(venus-gui-v2 LANGUAGES CXX VERSION 0.01.13)
add_definitions(-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR} -DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR} -DPROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH} )
set(TRANSLATIONS_TS_TARGET venus-gui-v2-translations-ts)
set(TRANSLATIONS_QM_TARGET venus-gui-v2-translations-qm)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")

option(VENUS_DESKTOP_BUILD "enable desktop build via cmake -DVENUS_DESKTOP_BUILD=ON" OFF) # Disabled by default
option(VENUS_WEBASSEMBLY_BUILD "enable webassembly build via cmake -DVENUS_WEBASSEMBLY_BUILD=ON" OFF) # Disabled by default
option(MQTT_WEBSOCKETS_ENABLED "enable websockets build via cmake -DMQTT_WEBSOCKETS_ENABLED=ON" OFF) # Disabled by default

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    add_compile_definitions(VENUS_WEBASSEMBLY_BUILD)
    add_compile_definitions(MQTT_WEBSOCKETS_ENABLED)
    find_package(Qt6 6.5.2 COMPONENTS Core Qml Quick Svg Xml LinguistTools Mqtt WebSockets REQUIRED) # require at least qt 6.5.2 for qt_add_qml_module to work properly
else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    find_package(Qt6 6.5.2 COMPONENTS Core Qml Quick Svg Xml DBus LinguistTools Mqtt REQUIRED) # require at least qt 6.5.2 for qt_add_qml_module to work properly
endif()

################ policies
# This has to go after 'find_package(Qt6 COMPONENTS Core)', and before 'qt_add_qml_module(... QML_FILES ${VENUS_QML_FILES})'
if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 NEW) # >Qt6.5 only. Enabling this policy ensures that your QML module is placed under a default import path, and its types can be found without manual calls to QQmlEngine::addImportPath.
endif()
################ end policies

qt_add_resources(QML_RESOURCES
    qml.qrc)


include_directories(src/veutil/inc src .)

set (VENUS_QML_SINGLETONS # All qml singletons have to be added here
    components/CommonWords.qml
    components/VenusFont.qml
    Global.qml
)

set_source_files_properties( ${VENUS_QML_SINGLETONS} PROPERTIES QT_QML_SINGLETON_TYPE TRUE )

set (VENUS_QML_FILES
    ${VENUS_QML_SINGLETONS}
    ApplicationContent.qml
    FrameRateVisualizer.qml

    components/ActionButton.qml
    components/Arc.qml
    components/ArcGauge.qml
    components/ArcGaugeQuantityLabel.qml
    components/AsymmetricRoundedRectangle.qml
    components/ButtonControlValue.qml
    components/CircularMultiGauge.qml
    components/CircularSingleGauge.qml
    components/ControlCard.qml
    components/ControlValue.qml
    components/DataPoint.qml
    components/Device.qml
    components/ElectricalQuantityLabel.qml
    components/EnvironmentGauge.qml
    components/EnvironmentGaugePanel.qml
    components/ExpandedTanksView.qml
    components/FirmwareUpdate.qml
    components/FixedWidthLabel.qml
    components/GaugeModel.qml
    components/EvChargerStatusModel.qml
    components/GeneratorIconLabel.qml
    components/GradientListView.qml
    components/GsmStatusIcon.qml
    components/IconButton.qml
    components/InputPanel.qml
    components/LoadGraph.qml
    components/LoadGraphShapePath.qml
    components/NavBar.qml
    components/NavButton.qml
    components/NotificationDelegate.qml
    components/NotificationsView.qml
    components/Page.qml
    components/PageStack.qml
    components/ProgressArc.qml
    components/QuantityLabel.qml
    components/QuantityTableSummary.qml
    components/QuantityTable.qml
    components/RadioButtonControlValue.qml
    components/ScaledArc.qml
    components/ScaledArcGauge.qml
    components/SegmentedButtonRow.qml
    components/SeparatorBar.qml
    components/ShinyProgressArc.qml
    components/SideGauge.qml
    components/SolarDetailBox.qml
    components/SolarHistoryChart.qml
    components/SolarHistoryErrorView.qml
    components/SolarHistoryTableView.qml
    components/SolarYieldGauge.qml
    components/SolarYieldGraph.qml
    components/SolarYieldModel.qml
    components/SplashView.qml
    components/StatusBar.qml
    components/SwitchControlValue.qml
    components/TabBar.qml
    components/TankGauge.qml
    components/TankGaugeGroup.qml
    components/ThreePhaseDisplay.qml
    components/TimeSelector.qml
    components/ToastNotification.qml
    components/ValueRange.qml
    components/VerticalGauge.qml
    components/ViewGradient.qml
    components/ClassAndVrmInstance.qml
    components/WeatherDetails.qml

    components/controls/Button.qml
    components/controls/ComboBox.qml
    components/controls/Label.qml
    components/controls/ListItemButton.qml
    components/controls/ProgressBar.qml
    components/controls/RadioButton.qml
    components/controls/ScrollBar.qml
    components/controls/Slider.qml
    components/controls/SpinBox.qml
    components/controls/Switch.qml
    components/controls/TextField.qml

    data/common/AcInput.qml
    data/common/AcInputServiceLoader.qml
    data/common/AcInputSettings.qml
    data/common/Battery.qml
    data/common/DcInput.qml
    data/common/DeviceModel.qml
    data/common/EnvironmentInput.qml
    data/common/EssData.qml
    data/common/EvCharger.qml
    data/common/Generator.qml
    data/common/Inverter.qml
    data/common/PvInverter.qml
    data/common/PvMonitor.qml
    data/common/Relay.qml
    data/common/SolarCharger.qml
    data/common/SolarDailyHistory.qml
    data/common/SolarHistoryErrorModel.qml
    data/common/SystemBattery.qml
    data/common/SystemData.qml
    data/common/Tank.qml
)

set(CONNMAN_SOURCES_MOCK
    src/connman-api.h
)

set(CONNMAN_SOURCES
    src/connman/cmmanager.h 
    src/connman/cmmananger_interface.h 
    src/connman/cmtechnology.h 
    src/connman/cmtechnology_interface.h 
    src/connman/cmservice_interface.h 
    src/connman/cmservice.h 
    src/connman/cmagent.h 
    src/connman/cmagent_adaptor.h 
    src/connman/clockmodel.h 
    src/connman/clockproxy.h
    src/connman/connmandbustypes.cpp 
    src/connman/cmmanager.cpp 
    src/connman/cmmananger_interface.cpp 
    src/connman/cmtechnology.cpp 
    src/connman/cmtechnology_interface.cpp 
    src/connman/cmservice_interface.cpp 
    src/connman/cmservice.cpp 
    src/connman/cmagent.cpp 
    src/connman/cmagent_adaptor.cpp 
    src/connman/clockmodel.cpp 
    src/connman/clockproxy.cpp
    src/connman/connmandbustypes.h 
)

set(VEUTIL_CORE_SOURCES
    src/veutil/inc/veutil/qt/firmware_updater_data.hpp
    src/veutil/inc/veutil/qt/unit_conversion.hpp
    src/veutil/inc/veutil/qt/ve_qitem.hpp
    src/veutil/inc/veutil/qt/ve_qitem_child_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_loader.hpp
    src/veutil/inc/veutil/qt/ve_qitem_sort_table_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_table_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_tree_model.hpp
    src/veutil/inc/veutil/qt/ve_quick_item.hpp

    src/veutil/src/qt/unit_conversion.cpp
    src/veutil/src/qt/ve_qitem.cpp
    src/veutil/src/qt/ve_qitem_child_model.cpp
    src/veutil/src/qt/ve_qitem_loader.cpp
    src/veutil/src/qt/ve_qitem_sort_table_model.cpp
    src/veutil/src/qt/ve_qitem_table_model.cpp
    src/veutil/src/qt/ve_qitem_tree_model.cpp
    src/veutil/src/qt/ve_quick_item.cpp
)

SET(VEUTIL_DBUS_SOURCES
    src/veutil/inc/veutil/qt/ve_dbus_connection.hpp
    src/veutil/inc/veutil/qt/ve_qitems_dbus.hpp
    src/veutil/inc/veutil/qt/vebus_error.hpp

    src/veutil/src/qt/ve_dbus_connection.cpp
    src/veutil/src/qt/ve_qitems_dbus.cpp
    src/veutil/src/qt/vebus_error.cpp
)

set(VEUTIL_MQTT_SOURCES
    src/veutil/inc/veutil/qt/ve_qitems_mqtt.hpp
    src/veutil/src/qt/ve_qitems_mqtt.cpp
)

set(GUIv1_DBUS_SOURCES
    src/gui-v1/alarmbusitem.h
    src/gui-v1/alarmbusitem.cpp
    src/gui-v1/alarmmonitor.h
    src/gui-v1/alarmmonitor.cpp
    src/gui-v1/dbus_service.h
    src/gui-v1/dbus_service.cpp
    src/gui-v1/dbus_services.h
    src/gui-v1/dbus_services.cpp
    src/gui-v1/wakespeed_error.cpp
)

set(VENUS_SOURCES
    src/main.cpp
    src/backendconnection.h
    src/backendconnection.cpp
    src/clocktime.h
    src/clocktime.cpp
    src/theme.h
    src/theme.cpp
    src/language.h
    src/language.cpp
    src/logging.h
    src/enums.h
    src/enums.cpp
    src/notificationsmodel.h
    src/notificationsmodel.cpp
    src/uidhelper.h
    src/uidhelper.cpp
    src/frameratemodel.h
    src/frameratemodel.cpp
)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    list(APPEND SOURCES
        ${CONNMAN_SOURCES_MOCK}
        ${VEUTIL_CORE_SOURCES}
        ${VEUTIL_MQTT_SOURCES}
        ${VENUS_SOURCES}
        ${QML_RESOURCES}
    )
else()
    list(APPEND SOURCES
        ${CONNMAN_SOURCES}
        ${GUIv1_DBUS_SOURCES}
        ${VEUTIL_CORE_SOURCES}
        ${VEUTIL_DBUS_SOURCES}
        ${VEUTIL_MQTT_SOURCES}
        ${VENUS_SOURCES}
        ${QML_RESOURCES}
    )
endif()

# translations support.
# note: the base venus-gui-v2.ts was generated with:
# lupdate.exe qml.qrc -ts i18n/venus-gui-v2.ts)
set(TRANSLATIONS_TS_FILES
        "i18n/venus-gui-v2.ts"
	"i18n/venus-gui-v2_en.ts"
	"i18n/venus-gui-v2_fr.ts")
set(TRANSLATIONS_QM_FILES
        "i18n/venus-gui-v2.qm"
	"i18n/venus-gui-v2_en.qm"
	"i18n/venus-gui-v2_fr.qm")
# manually generate .ts files via a custom command.
# it would be good if we could do this via qt6_add_lupdate
# instead, but that macro is broken, so do it ourselves.
add_custom_target(${TRANSLATIONS_TS_TARGET}
    SOURCES ${QML_RESOURCES} ${SOURCES})
add_custom_command(
    TARGET ${TRANSLATIONS_TS_TARGET}
    BYPRODUCTS ${TRANSLATIONS_TS_FILES}
    COMMENT "Manually updating translations files"
    COMMAND ${QT_CMAKE_EXPORT_NAMESPACE}::lupdate
        ARGS "${CMAKE_CURRENT_SOURCE_DIR}/qml.qrc" src
	     -ts ${TRANSLATIONS_TS_FILES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
# add a custom target to generate the .qm files via qt6_add_lrelease().
# force the .qm generation step to depend on the .ts generation step.
set_source_files_properties(${TRANSLATIONS_TS_FILES}
    PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/i18n")
add_custom_target(${TRANSLATIONS_QM_TARGET}
    SOURCES ${TRANSLATIONS_TS_FILES})
add_dependencies(${TRANSLATIONS_QM_TARGET} ${TRANSLATIONS_TS_TARGET})
# generate .qm files
add_custom_command(
    TARGET ${TRANSLATIONS_QM_TARGET}
    COMMENT "Manually releasing translations files"
    COMMAND ${QT_CMAKE_EXPORT_NAMESPACE}::lrelease
        ARGS ${TRANSLATIONS_TS_FILES} -idbased
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    list(APPEND venusCompileFlags "-Wall" "-Wextra" "-Werror" "-Wconversion" "-Wno-exceptions" "-Wextra-semi" "-Wno-inaccessible-base" "-Wcast-align" "-Wcast-qual" "-Wctor-dtor-privacy" "-Wformat=2" "-Winit-self" "-Wmissing-declarations" "-Wmissing-include-dirs" "-Wold-style-cast" "-Woverloaded-virtual" "-Wredundant-decls" "-Wshadow" "-Wsign-conversion" "-Wstrict-overflow=5" "-Wswitch-default" "-Wundef")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(VENUS_DESKTOP_BUILD)
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
else()
    list(APPEND venusCompileFlags "-Wall" "-Wextra" "-Werror" "-Wconversion" "-Wno-exceptions" "-Wextra-semi" "-Wno-inaccessible-base" "-Wcast-align" "-Wcast-qual" "-Wctor-dtor-privacy" "-Wformat=2" "-Winit-self" "-Wmissing-declarations" "-Wmissing-include-dirs" "-Wold-style-cast" "-Woverloaded-virtual" "-Wredundant-decls" "-Wshadow" "-Wsign-conversion" "-Wstrict-overflow=5" "-Wswitch-default" "-Wundef")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
endif()

qt_add_library(VenusQMLModule STATIC)

qt_add_qml_module(VenusQMLModule
    URI Victron.VenusOS
    VERSION 2.0
    QML_FILES ${VENUS_QML_FILES}
)

qt_add_library(Gauges STATIC)
qt_add_qml_module(Gauges
    URI Gauges
    OUTPUT_DIRECTORY Gauges
    QML_FILES components/Gauges.js
)

qt_add_library(Units STATIC)
qt_add_qml_module(Units
    URI Units
    OUTPUT_DIRECTORY Units
    QML_FILES components/Units.js
)

qt_add_library(Utils STATIC)
qt_add_qml_module(Utils
    URI Utils
    OUTPUT_DIRECTORY Utils
    QML_FILES components/Utils.js
)

add_dependencies(${PROJECT_NAME} ${TRANSLATIONS_QM_TARGET})
qt_add_resources(${PROJECT_NAME} "i18n"
    PREFIX "/i18n"
    BASE "i18n"
    FILES ${TRANSLATIONS_QM_FILES})

set_source_files_properties(
    ${VENUS_SOURCES}
    PROPERTIES
    COMPILE_OPTIONS "${venusCompileFlags}"
)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::Svg
        Qt6::Xml
        Qt6::Mqtt
        Qt6::WebSockets
        VenusQMLModuleplugin
        Gaugesplugin
        Unitsplugin
        Utilsplugin
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::Svg
        Qt6::Xml
        Qt6::DBus
        Qt6::Mqtt
        VenusQMLModuleplugin
        Gaugesplugin
        Unitsplugin
        Utilsplugin
    )
endif()

# see if the dependency graph is correct, for translations support...
add_custom_target(graphviz
                 "${CMAKE_COMMAND}" "--graphviz=venus" .
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
# disable it for now, can re-enable for future analysis when required.
#add_dependencies(${PROJECT_NAME} graphviz)
