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

    components/dialogs/DateSelectorDialog.qml
    components/dialogs/DialogShadow.qml
    components/dialogs/VrmInstanceSwapDialog.qml
    components/dialogs/ESSMinimumSOCDialog.qml
    components/dialogs/GeneratorDurationSelectorDialog.qml
    components/dialogs/InverterChargerModeDialog.qml
    components/dialogs/ModalDialog.qml
    components/dialogs/ModalWarningDialog.qml
    components/dialogs/NumberSelectorDialog.qml
    components/dialogs/SolarDailyHistoryDialog.qml
    components/dialogs/TimeSelectorDialog.qml

    components/listitems/ListButton.qml
    components/listitems/ListDateSelector.qml
    components/listitems/ListIpAddressField.qml
    components/listitems/ListItem.qml
    components/listitems/ListItemBackground.qml
    components/listitems/ListLabel.qml
    components/listitems/ListNavigationItem.qml
    components/listitems/ListPortField.qml
    components/listitems/ListRadioButton.qml
    components/listitems/ListRadioButtonGroup.qml
    components/listitems/ListQuantityGroup.qml
    components/listitems/ListSlider.qml
    components/listitems/ListSpinBox.qml
    components/listitems/ListSwitch.qml
    components/listitems/ListTextField.qml
    components/listitems/ListTextGroup.qml
    components/listitems/ListTextItem.qml
    components/listitems/ListTimeSelector.qml

    components/settings/FirmwareCheckListButton.qml
    components/settings/ListDvccSwitch.qml
    components/settings/MountStateListButton.qml
    components/settings/SettingsSlider.qml
    components/settings/TemperatureRelayNavigationItem.qml
    components/settings/TemperatureRelaySettings.qml

    components/widgets/AcGeneratorWidget.qml
    components/widgets/AcInputWidget.qml
    components/widgets/AcLoadsWidget.qml
    components/widgets/AlternatorWidget.qml
    components/widgets/BatteryWidget.qml
    components/widgets/DcGeneratorWidget.qml
    components/widgets/DcInputWidget.qml
    components/widgets/DcLoadsWidget.qml
    components/widgets/EvcsWidget.qml
    components/widgets/GridWidget.qml
    components/widgets/InverterWidget.qml
    components/widgets/OverviewWidget.qml
    components/widgets/ShoreWidget.qml
    components/widgets/SolarYieldWidget.qml
    components/widgets/WidgetConnector.qml
    components/widgets/WidgetConnectorAnchor.qml
    components/widgets/WidgetConnectorPath.qml
    components/widgets/WidgetHeader.qml
    components/widgets/WindWidget.qml

    data/AcInputs.qml
    data/Batteries.qml
    data/DataManager.qml
    data/DcInputs.qml
    data/EnvironmentInputs.qml
    data/Ess.qml
    data/EvChargers.qml
    data/Generators.qml
    data/Inverters.qml
    data/Notifications.qml
    data/PvInverters.qml
    data/Relays.qml
    data/SolarChargers.qml
    data/System.qml
    data/SystemAc.qml
    data/SystemDc.qml
    data/SystemSettings.qml
    data/Tanks.qml
    data/VenusPlatform.qml

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

    pages/BriefMonitorPanel.qml
    pages/BriefPage.qml
    pages/ControlCardsPage.qml
    pages/EnvironmentTab.qml
    pages/LevelsPage.qml
    pages/MainView.qml
    pages/NotificationLayer.qml
    pages/NotificationsPage.qml
    pages/OverviewPage.qml
    pages/PageManager.qml
    pages/SettingsPage.qml
    pages/TanksTab.qml
    pages/controlcards/ESSCard.qml
    pages/controlcards/GeneratorCard.qml
    pages/controlcards/InverterCard.qml
    pages/controlcards/SwitchesCard.qml
    pages/evcs/EvChargerListPage.qml
    pages/evcs/EvChargerPage.qml
    pages/evcs/EvChargerSetupPage.qml
    pages/settings/DvccCommonSettings.qml
    pages/settings/GeneratorCondition.qml
    pages/settings/IpAddressListView.qml
    pages/settings/PageCanbusStatus.qml
    pages/settings/PageChargeCurrentLimits.qml
    pages/settings/PageDeviceInfo.qml
    pages/settings/PageGenerator.qml
    pages/settings/PageGeneratorAcLoad.qml
    pages/settings/PageGeneratorConditions.qml
    pages/settings/PageGeneratorRuntimeService.qml
    pages/settings/PageGeneratorTestRun.qml
    pages/settings/PageGps.qml
    pages/settings/PageHub4Debug.qml
    pages/settings/PageRelayGenerator.qml
    pages/settings/PageSettingsBatteries.qml
    pages/settings/PageSettingsBleSensors.qml
    pages/settings/PageSettingsBluetooth.qml
    pages/settings/PageSettingsCGwacs.qml
    pages/settings/PageSettingsCGwacsOverview.qml
    pages/settings/PageSettingsCanbus.qml
    pages/settings/PageSettingsDisplay.qml
    pages/settings/PageSettingsDisplayBrief.qml
    pages/settings/PageSettingsDisplayUnits.qml
    pages/settings/PageSettingsDvcc.qml
    pages/settings/PageSettingsFirmware.qml
    pages/settings/PageSettingsFirmwareOffline.qml
    pages/settings/PageSettingsFirmwareOnline.qml
    pages/settings/PageSettingsFronius.qml
    pages/settings/PageSettingsFroniusInverter.qml
    pages/settings/PageSettingsFroniusInverters.qml
    pages/settings/PageSettingsFroniusSetIpAddresses.qml
    pages/settings/PageSettingsFroniusShowIpAddresses.qml
    pages/settings/PageSettingsGeneral.qml
    pages/settings/PageSettingsGenerator.qml
    pages/settings/PageSettingsGpsList.qml
    pages/settings/PageSettingsGsm.qml
    pages/settings/PageSettingsHub4.qml
    pages/settings/PageSettingsHub4Feedin.qml
    pages/settings/PageSettingsIo.qml
    pages/settings/PageSettingsLarge.qml
    pages/settings/PageSettingsLogger.qml
    pages/settings/PageSettingsModbusTcp.qml
    pages/settings/PageSettingsModbusTcpServices.qml
    pages/settings/PageSettingsRelay.qml
    pages/settings/PageSettingsRelayTempSensors.qml
    pages/settings/PageSettingsRemoteConsole.qml
    pages/settings/PageSettingsRootfsSelect.qml
    pages/settings/PageSettingsRvcDevice.qml
    pages/settings/PageSettingsRvcDeviceConfiguration.qml
    pages/settings/PageSettingsRvcDevices.qml
    pages/settings/PageSettingsServices.qml
    pages/settings/PageSettingsSystem.qml
    pages/settings/PageSettingsSystemStatus.qml
    pages/settings/PageSettingsTankPump.qml
    pages/settings/PageSettingsTcpIp.qml
    pages/settings/PageSettingsVecanDevice.qml
    pages/settings/PageSettingsVecanDevices.qml
    pages/settings/PageSettingsWifi.qml
    pages/settings/PageSettingsWifiWithAccessPoint.qml
    pages/settings/PageTzInfo.qml
    pages/settings/PageVrmDeviceInstances.qml
    pages/settings/debug/HubData.qml
    pages/settings/debug/ObjectAcConnection.qml
    pages/settings/debug/PageDebug.qml
    pages/settings/debug/PageDebugVeQItems.qml
    pages/settings/debug/PagePowerDebug.qml
    pages/settings/debug/PageSettingsDemo.qml
    pages/settings/debug/PageSystemData.qml
    pages/settings/tz/TzAfricaData.qml
    pages/settings/tz/TzAmericaData.qml
    pages/settings/tz/TzAntarcticaData.qml
    pages/settings/tz/TzArcticData.qml
    pages/settings/tz/TzAsiaData.qml
    pages/settings/tz/TzAtlanticData.qml
    pages/settings/tz/TzAustraliaData.qml
    pages/settings/tz/TzEtcData.qml
    pages/settings/tz/TzEuropeData.qml
    pages/settings/tz/TzIndianData.qml
    pages/settings/tz/TzPacificData.qml
    pages/solar/PvInverterPage.qml
    pages/solar/SolarChargerAlarmsAndErrorsPage.qml
    pages/solar/SolarChargerNetworkedOperationPage.qml
    pages/solar/SolarChargerPage.qml
    pages/solar/SolarChargerHistoryPage.qml
    pages/solar/SolarDeviceListPage.qml
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

qt_add_library(Dbus STATIC)
qt_add_qml_module(Dbus
    URI Dbus
    OUTPUT_DIRECTORY Dbus
    QML_FILES
        data/dbus/AcInputsImpl.qml
        data/dbus/BatteriesImpl.qml
        data/dbus/DBusDataManager.qml
        data/dbus/DcInputsImpl.qml
        data/dbus/EnvironmentInputsImpl.qml
        data/dbus/EssImpl.qml
        data/dbus/EvChargersImpl.qml
        data/dbus/GeneratorsImpl.qml
        data/dbus/InvertersImpl.qml
        data/dbus/NotificationsImpl.qml
        data/dbus/PvInvertersImpl.qml
        data/dbus/RelaysImpl.qml
        data/dbus/SolarChargersImpl.qml
        data/dbus/SystemImpl.qml
        data/dbus/SystemSettingsImpl.qml
        data/dbus/TanksImpl.qml
)

qt_add_library(Mock STATIC)
qt_add_qml_module(Mock
    URI Mock
    OUTPUT_DIRECTORY Mock
    QML_FILES
        data/mock/AcInputsImpl.qml
        data/mock/BatteriesImpl.qml
        data/mock/DcInputsImpl.qml
        data/mock/EnvironmentInputsImpl.qml
        data/mock/EssImpl.qml
        data/mock/EvChargersImpl.qml
        data/mock/GeneratorsImpl.qml
        data/mock/InvertersImpl.qml
        data/mock/MockDevice.qml
        data/mock/MockDataManager.qml
        data/mock/NotificationsImpl.qml
        data/mock/PvInvertersImpl.qml
        data/mock/RelaysImpl.qml
        data/mock/SolarChargersImpl.qml
        data/mock/SystemImpl.qml
        data/mock/SystemSettingsImpl.qml
        data/mock/TanksImpl.qml
        data/mock/config/BriefAndOverviewPageConfig.qml
        data/mock/config/LevelsPageConfig.qml
        data/mock/config/MockDataSimulator.qml
        data/mock/config/NotificationsPageConfig.qml
        data/mock/config/SettingsPageConfig.qml
)

qt_add_library(Mqtt STATIC)
qt_add_qml_module(Mqtt
    URI Mqtt
    OUTPUT_DIRECTORY Mqtt
    QML_FILES
        data/mqtt/AcInputsImpl.qml
        data/mqtt/BatteriesImpl.qml
        data/mqtt/DcInputsImpl.qml
        data/mqtt/EnvironmentInputsImpl.qml
        data/mqtt/EssImpl.qml
        data/mqtt/EvChargersImpl.qml
        data/mqtt/GeneratorsImpl.qml
        data/mqtt/InvertersImpl.qml
        data/mqtt/MqttDataManager.qml
        data/mqtt/NotificationsImpl.qml
        data/mqtt/PvInvertersImpl.qml
        data/mqtt/RelaysImpl.qml
        data/mqtt/SolarChargersImpl.qml
        data/mqtt/SystemImpl.qml
        data/mqtt/SystemSettingsImpl.qml
        data/mqtt/TanksImpl.qml
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
        Dbusplugin
        Mockplugin
        Mqttplugin
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
        Dbusplugin
        Mockplugin
        Mqttplugin
    )
endif()

# see if the dependency graph is correct, for translations support...
add_custom_target(graphviz
                 "${CMAKE_COMMAND}" "--graphviz=venus" .
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
# disable it for now, can re-enable for future analysis when required.
#add_dependencies(${PROJECT_NAME} graphviz)
