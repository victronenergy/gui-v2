#
# Copyright (C) 2023 Victron Energy B.V.
# See LICENSE.txt for license information.
#
cmake_minimum_required(VERSION 3.24) # earlier versions of cmake don't handle 'qt_add_qml_module' properly, you get errors at runtime like: "qrc:/main.qml:164 ApplicationContent is not a type\n"

# CMAKE HINTS
#
# Different build types:
#   cmake -DCMAKE_BUILD_TYPE=[Debug|Release|RelWithDebInfo|MinSizeRelease]
#
# Faster builds, for use in development. This stops qml code from being compiled into C++ at build time. Will run slower on the target.
#   cmake -DNO_CACHEGEN=true

cmake_policy(SET CMP0071 NEW) # process GENERATED source files in AUTOMOC and AUTOUIC. Added to silence a cmake warning.
cmake_policy(SET CMP0079 NEW)

project(venus-gui-v2 LANGUAGES CXX VERSION 0.02.03)
add_definitions(-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR} -DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR} -DPROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH} )

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")
message("CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message("CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

option(VENUS_DESKTOP_BUILD "enable desktop build via cmake -DVENUS_DESKTOP_BUILD=ON" OFF) # Disabled by default
option(VENUS_WEBASSEMBLY_BUILD "enable webassembly build via cmake -DVENUS_WEBASSEMBLY_BUILD=ON" OFF) # Disabled by default
option(MQTT_WEBSOCKETS_ENABLED "enable websockets build via cmake -DMQTT_WEBSOCKETS_ENABLED=ON" OFF) # Disabled by default

# If we want a release build, remove the '-g' debug compiler flag set by the environment setup script.
# Otherwise, our executable size ballons from ~10MB to ~220MB.
if(("${CMAKE_BUILD_TYPE}" STREQUAL "Release" OR "${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel"))
    message("Removing '-g' debug flag set by /opt/venus/dunfell-arm-cortexa7hf-neon-vfpv4/environment-setup-cortexa7hf-neon-vfpv4-ve-linux-gnueabi")
    # Match all instances of " -g " in the input "${CMAKE_CXX_FLAGS}" and replace it with a single space " " and store the result into the output variable CMAKE_CXX_FLAGS
    string(REPLACE " -g " " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    message("new CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS} ")
endif()

if ("${NO_CACHEGEN}")
    message("Disabling cache generation for faster builds")
    set (QML_MODULE_OPTARGS ${QML_MODULE_OPTARGS} "NO_CACHEGEN")
endif()

set(REQUIRED_QT_VERSION 6.5.2) # require at least qt 6.5.2 for qt_add_qml_module to work properly
find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS Core Gui Qml Quick Svg Xml Mqtt LinguistTools REQUIRED)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    add_compile_definitions(VENUS_WEBASSEMBLY_BUILD)
    add_compile_definitions(MQTT_WEBSOCKETS_ENABLED)
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS WebSockets REQUIRED)
else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS DBus REQUIRED)
endif()

# This has to go after 'find_package(Qt6 COMPONENTS Core)', and before 'qt_add_qml_module(... QML_FILES ${VENUS_QML_MODULE_SOURCES})'
if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 NEW) # >Qt6.5 only. Enabling this policy ensures that your QML module is placed under a default import path, and its types can be found without manual calls to QQmlEngine::addImportPath.
endif()

# Not actually a subproject, but we need to build it somehow...
# Eventually, we should implement the code generator as a python script
# and invoke it directly via add_custom_command() + add_custom_target().
# For now, we require the developer to run the code generator manually.
#add_subdirectory("tools/themeparser")

include_directories(src/veutil/inc src .)

set (VENUS_QML_MODULE_SINGLETON_SOURCES # All qml singletons have to be added here
    components/CommonWords.qml
    components/VenusFont.qml
    Global.qml
)
set_source_files_properties( ${VENUS_QML_MODULE_SINGLETON_SOURCES} PROPERTIES QT_QML_SINGLETON_TYPE TRUE )

# Connman module
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    list(APPEND CONNMAN_SOURCES
        src/connman-api.h # mock sources
    )
else()
    list(APPEND CONNMAN_SOURCES
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
endif()

qt_add_qml_module(Connman
    URI net.connman
    VERSION 1.0
    STATIC
    OUTPUT_DIRECTORY net/connman
    SOURCES ${CONNMAN_SOURCES}
    ${QML_MODULE_OPTARGS}
)

if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    target_include_directories(Connman PRIVATE src/connman)
    target_link_libraries(Connman PRIVATE Qt6::DBus)
endif()

# end Connman module

# VENUS_QML_MODULE
set (VENUS_QML_MODULE_SOURCES
    ${VENUS_QML_MODULE_SINGLETON_SOURCES}

    ApplicationContent.qml
    FrameRateVisualizer.qml

    components/AcceptButtonBackground.qml
    components/AcInputsCurrentLimits.qml
    components/AcOutput.qml
    components/AcPhase.qml
    components/Arc.qml
    components/ArcGauge.qml
    components/ArcGaugeQuantityLabel.qml
    components/AsymmetricRoundedRectangle.qml
    components/ButtonControlValue.qml
    components/CircularMultiGauge.qml
    components/CircularSingleGauge.qml
    components/ControlCard.qml
    components/ControlValue.qml
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
    components/QuantityRepeater.qml
    components/QuantityTableSummary.qml
    components/QuantityTable.qml
    components/RadioButtonControlValue.qml
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
    components/ThreePhaseQuantityTable.qml
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
    components/controls/RangeSlider.qml
    components/controls/ScrollBar.qml
    components/controls/Slider.qml
    components/controls/SpinBox.qml
    components/controls/Switch.qml
    components/controls/TextField.qml

    components/dialogs/CurrentLimitDialog.qml
    components/dialogs/DateSelectorDialog.qml
    components/dialogs/DialogShadow.qml
    components/dialogs/VrmInstanceSwapDialog.qml
    components/dialogs/ESSMinimumSOCDialog.qml
    components/dialogs/GeneratorDialog.qml
    components/dialogs/GeneratorStartDialog.qml
    components/dialogs/GeneratorStopDialog.qml
    components/dialogs/InverterChargerModeDialog.qml
    components/dialogs/ModalDialog.qml
    components/dialogs/ModalWarningDialog.qml
    components/dialogs/NumberSelectorDialog.qml
    components/dialogs/SolarDailyHistoryDialog.qml
    components/dialogs/TimeSelectorDialog.qml

    components/listitems/ListAlarm.qml
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
    components/listitems/ListRadioButtonGroupNoYes.qml
    components/listitems/ListQuantityGroup.qml
    components/listitems/ListQuantityItem.qml
    components/listitems/ListRangeSlider.qml
    components/listitems/ListSlider.qml
    components/listitems/ListSpinBox.qml
    components/listitems/ListSwitch.qml
    components/listitems/ListTemperatureItem.qml
    components/listitems/ListTextField.qml
    components/listitems/ListTextGroup.qml
    components/listitems/ListTextItem.qml
    components/listitems/ListTimeSelector.qml

    components/settings/CGwacsBatteryScheduleNavigationItem.qml
    components/settings/FirmwareCheckListButton.qml
    components/settings/Led.qml
    components/settings/ListAlarmState.qml
    components/settings/ListClearHistoryButton.qml
    components/settings/ListDvccSwitch.qml
    components/settings/ListFirmwareVersionItem.qml
    components/settings/ListRelayState.qml
    components/settings/ListResetHistoryLabel.qml
    components/settings/MountStateListButton.qml
    components/settings/PvInverterPositionRadioButtonGroup.qml
    components/settings/SettingsRangeSlider.qml
    components/settings/SettingsSlider.qml
    components/settings/TemperatureRelayNavigationItem.qml
    components/settings/TemperatureRelaySettings.qml
    components/settings/VolumeUnitRadioButtonGroup.qml

    components/widgets/AcInputWidget.qml
    components/widgets/AcLoadsWidget.qml
    components/widgets/AlternatorWidget.qml
    components/widgets/BatteryWidget.qml
    components/widgets/DcGeneratorWidget.qml
    components/widgets/DcInputWidget.qml
    components/widgets/DcLoadsWidget.qml
    components/widgets/EvcsWidget.qml
    components/widgets/OverviewWidget.qml
    components/widgets/SolarYieldWidget.qml
    components/widgets/VeBusDeviceWidget.qml
    components/widgets/WidgetConnector.qml
    components/widgets/WidgetConnectorAnchor.qml
    components/widgets/WidgetConnectorPath.qml
    components/widgets/WidgetHeader.qml
    components/widgets/WindWidget.qml

    data/AcInputs.qml
    data/Chargers.qml
    data/Batteries.qml
    data/DataManager.qml
    data/DcInputs.qml
    data/DcLoads.qml
    data/DcSystems.qml
    data/DigitalInputs.qml
    data/EnvironmentInputs.qml
    data/Ess.qml
    data/EvChargers.qml
    data/Generators.qml
    data/Inverters.qml
    data/MeteoDevices.qml
    data/MotorDrives.qml
    data/MultiRsDevices.qml
    data/Notifications.qml
    data/PulseMeters.qml
    data/PvInverters.qml
    data/Relays.qml
    data/SolarChargers.qml
    data/System.qml
    data/SystemAc.qml
    data/SystemDc.qml
    data/SystemSettings.qml
    data/Tanks.qml
    data/UnsupportedDevices.qml
    data/VeBusDevices.qml
    data/VenusPlatform.qml

    data/common/AcData.qml
    data/common/AcInputPhaseModel.qml
    data/common/AcInputServiceLoader.qml
    data/common/AcInputSettings.qml
    data/common/AcInputSystemInfo.qml
    data/common/ActiveAcInput.qml
    data/common/Battery.qml
    data/common/Charger.qml
    data/common/DcDevice.qml
    data/common/DcInput.qml
    data/common/DcLoad.qml
    data/common/DcSystem.qml
    data/common/DigitalInput.qml
    data/common/DeviceModel.qml
    data/common/EnvironmentInput.qml
    data/common/EssData.qml
    data/common/EvCharger.qml
    data/common/Generator.qml
    data/common/Inverter.qml
    data/common/MeteoDevice.qml
    data/common/MotorDrive.qml
    data/common/MultiRsDevice.qml
    data/common/PulseMeter.qml
    data/common/PvInverter.qml
    data/common/PvMonitor.qml
    data/common/Relay.qml
    data/common/SolarCharger.qml
    data/common/SolarDailyHistory.qml
    data/common/SolarHistoryErrorModel.qml
    data/common/SystemBattery.qml
    data/common/SystemData.qml
    data/common/Tank.qml
    data/common/UnsupportedDevice.qml
    data/common/VeBusDevice.qml

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
    pages/controlcards/SwitchesCard.qml
    pages/controlcards/VeBusDeviceCard.qml
    pages/evcs/EvChargerListPage.qml
    pages/evcs/EvChargerPage.qml
    pages/evcs/EvChargerSetupPage.qml
    pages/settings/CanbusServiceFinder.qml
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
    pages/settings/devicelist/DeviceListPage.qml
    pages/settings/devicelist/AcInDeviceModel.qml
    pages/settings/devicelist/PageMeteo.qml
    pages/settings/devicelist/PageMeteoSettings.qml
    pages/settings/devicelist/PageNotYetImplemented.qml
    pages/settings/devicelist/PageUnsupportedDevice.qml
    pages/settings/devicelist/battery/BatteryDetails.qml
    pages/settings/devicelist/battery/BatterySettingsAlarmModel.qml
    pages/settings/devicelist/battery/BatterySettingsRelayModel.qml
    pages/settings/devicelist/battery/FuseInfo.qml
    pages/settings/devicelist/battery/Page48TlDiagnostics.qml
    pages/settings/devicelist/battery/PageBattery.qml
    pages/settings/devicelist/battery/PageBatteryAlarms.qml
    pages/settings/devicelist/battery/PageBatteryDetails.qml
    pages/settings/devicelist/battery/PageBatteryHistory.qml
    pages/settings/devicelist/battery/PageBatteryModuleAlarms.qml
    pages/settings/devicelist/battery/PageBatteryParameters.qml
    pages/settings/devicelist/battery/PageBatterySettings.qml
    pages/settings/devicelist/battery/PageBatterySettingsBattery.qml
    pages/settings/devicelist/battery/PageLynxDistributorList.qml
    pages/settings/devicelist/battery/PageLynxIonDiagnostics.qml
    pages/settings/devicelist/battery/PageLynxIonIo.qml
    pages/settings/devicelist/battery/PageLynxIonSystem.qml
    pages/settings/devicelist/dc-in/PageAlternator.qml
    pages/settings/devicelist/dc-in/PageAlternatorModelWakespeed.qml
    pages/settings/devicelist/dc-in/PageDcMeter.qml
    pages/settings/devicelist/dc-in/PageDcMeterModel.qml
    pages/settings/devicelist/dc-in/PageDcMeterAlarms.qml
    pages/settings/devicelist/dc-in/PageDcMeterHistory.qml
    pages/settings/devicelist/tank/PageTankAlarm.qml
    pages/settings/devicelist/tank/PageTankSensor.qml
    pages/settings/devicelist/tank/PageTankSetup.qml
    pages/settings/devicelist/tank/PageTankShape.qml
    pages/settings/devicelist/ac-in/ListFpGensetErrorItem.qml
    pages/settings/devicelist/ac-in/PageAcIn.qml
    pages/settings/devicelist/ac-in/PageAcInSetup.qml
    pages/settings/devicelist/ac-in/PageAcInModelGenset.qml
    pages/settings/devicelist/ac-in/PageAcInModelDefault.qml
    pages/settings/devicelist/ac-in/PageSmappeeCTList.qml
    pages/settings/devicelist/ac-in/PageSmappeeCTSetup.qml
    pages/settings/devicelist/ac-in/PageSmappeeDeviceList.qml
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
    pages/battery/BatteryListPage.qml
    pages/solar/PvInverterPage.qml
    pages/solar/SolarChargerAlarmsAndErrorsPage.qml
    pages/solar/SolarChargerNetworkedOperationPage.qml
    pages/solar/SolarChargerPage.qml
    pages/solar/SolarChargerHistoryPage.qml
    pages/solar/SolarDeviceListPage.qml
    pages/solar/SolarDeviceNavigationItem.qml

    pages/vebusdevice/OverviewVeBusDevicePage.qml
    pages/vebusdevice/PageAcSensor.qml
    pages/vebusdevice/PageAcSensors.qml
    pages/vebusdevice/PageVeBusAdvanced.qml
    pages/vebusdevice/PageVeBusAlarms.qml
    pages/vebusdevice/PageVeBusAlarmSettings.qml
    pages/vebusdevice/PageVeBusBms.qml
    pages/vebusdevice/PageVeBusDebug.qml
    pages/vebusdevice/PageVeBusDeviceInfo.qml
    pages/vebusdevice/PageVeBusError11Device.qml
    pages/vebusdevice/PageVeBusError11Menu.qml
    pages/vebusdevice/PageVeBusError11View.qml
    pages/vebusdevice/PageVeBusKwhCounters.qml
    pages/vebusdevice/PageVeBusSerialNumbers.qml
    pages/vebusdevice/PVCFListQuantityGroup.qml
    pages/vebusdevice/ThreePhaseIOTable.qml
    pages/vebusdevice/VeBusAcSensorModel.qml
    pages/vebusdevice/PageVeBus.qml
    pages/vebusdevice/VeBusAlarm.qml
    pages/vebusdevice/VeBusDeviceActiveAcInputTextItem.qml
    pages/vebusdevice/VeBusDeviceAlarmGroup.qml
    pages/vebusdevice/VeBusDeviceAlarmSettingsModel.qml
    pages/vebusdevice/VeBusDeviceAlarmStatusModel.qml
    pages/vebusdevice/VeBusDeviceInfoModel.qml
    pages/vebusdevice/VeBusDeviceKwhCountersModel.qml
    pages/vebusdevice/VeBusDeviceModeButton.qml
)

list(APPEND QML_MODULE_SOURCES ${VENUS_QML_MODULE_SOURCES})

set(VenusQMLModule_CPP_SOURCES
    src/aggregatedevicemodel.h
    src/aggregatedevicemodel.cpp
    src/basedevicemodel.h
    src/basedevicemodel.cpp
    src/theme.h
    src/theme.cpp
    src/themeobjects.h
    src/backendconnection.h
    src/backendconnection.cpp
    src/language.h
    src/language.cpp
    src/enums.h
    src/enums.cpp
    src/notificationsmodel.h
    src/notificationsmodel.cpp
    src/clocktime.h
    src/clocktime.cpp
    src/frameratemodel.h
    src/frameratemodel.cpp
)

qt_add_qml_module(VenusQMLModule
    ${QML_MODULE_OPTARGS}
    URI Victron.VenusOS
    VERSION 2.0
    STATIC
    OUTPUT_DIRECTORY Victron/VenusOS
    QML_FILES ${VENUS_QML_MODULE_SOURCES}
    SOURCES ${VenusQMLModule_CPP_SOURCES}
    IMPORTS net.connman
)
target_link_libraries(VenusQMLModule PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::Xml
    Qt6::Mqtt
    Connman
)
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    target_link_libraries(VenusQMLModule PRIVATE Qt6::WebSockets)
else()
    target_include_directories(VenusQMLModule PRIVATE src/connman)
    target_link_libraries(VenusQMLModule PRIVATE Qt6::DBus)
endif()
# end VENUS_QML_MODULE

# Dbus_QML_MODULE
set(Dbus_QML_MODULE_SOURCES
    data/dbus/BatteriesImpl.qml
    data/dbus/ChargersImpl.qml
    data/dbus/DBusDataManager.qml
    data/dbus/DcInputsImpl.qml
    data/dbus/DcLoadsImpl.qml
    data/dbus/DcSystemsImpl.qml
    data/dbus/DigitalInputsImpl.qml
    data/dbus/EnvironmentInputsImpl.qml
    data/dbus/EssImpl.qml
    data/dbus/EvChargersImpl.qml
    data/dbus/GeneratorsImpl.qml
    data/dbus/InvertersImpl.qml
    data/dbus/MeteoDevicesImpl.qml
    data/dbus/MotorDrivesImpl.qml
    data/dbus/MultiRsDevicesImpl.qml
    data/dbus/NotificationsImpl.qml
    data/dbus/PulseMetersImpl.qml
    data/dbus/PvInvertersImpl.qml
    data/dbus/RelaysImpl.qml
    data/dbus/SolarChargersImpl.qml
    data/dbus/SystemImpl.qml
    data/dbus/SystemSettingsImpl.qml
    data/dbus/TanksImpl.qml
    data/dbus/UnsupportedDevicesImpl.qml
    data/dbus/VeBusDevicesImpl.qml
)

list(APPEND QML_MODULE_SOURCES ${Dbus_QML_MODULE_SOURCES})

qt_add_qml_module(Dbus
    URI Victron.Dbus
    STATIC
    OUTPUT_DIRECTORY Victron/Dbus
    QML_FILES ${Dbus_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
# end Dbus_QML_MODULE

# Mock_QML_MODULE
set(Mock_QML_MODULE_SOURCES
    data/mock/AcInputsImpl.qml
    data/mock/BatteriesImpl.qml
    data/mock/ChargersImpl.qml
    data/mock/DcInputsImpl.qml
    data/mock/DcLoadsImpl.qml
    data/mock/DcSystemsImpl.qml
    data/mock/DigitalInputsImpl.qml
    data/mock/EnvironmentInputsImpl.qml
    data/mock/EssImpl.qml
    data/mock/EvChargersImpl.qml
    data/mock/GeneratorsImpl.qml
    data/mock/InvertersImpl.qml
    data/mock/MeteoDevicesImpl.qml
    data/mock/MockDevice.qml
    data/mock/MockDataManager.qml
    data/mock/MotorDrivesImpl.qml
    data/mock/MultiRsDevicesImpl.qml
    data/mock/NotificationsImpl.qml
    data/mock/PulseMetersImpl.qml
    data/mock/PvInvertersImpl.qml
    data/mock/RelaysImpl.qml
    data/mock/SolarChargersImpl.qml
    data/mock/SystemImpl.qml
    data/mock/SystemSettingsImpl.qml
    data/mock/TanksImpl.qml
    data/mock/UnsupportedDevicesImpl.qml
    data/mock/VeBusDevicesImpl.qml
    data/mock/config/BriefAndOverviewPageConfig.qml
    data/mock/config/LevelsPageConfig.qml
    data/mock/config/MockDataSimulator.qml
    data/mock/config/NotificationsPageConfig.qml
    data/mock/config/SettingsPageConfig.qml
)

list(APPEND QML_MODULE_SOURCES ${Mock_QML_MODULE_SOURCES})

qt_add_qml_module(Mock
    URI Victron.Mock
    STATIC
    OUTPUT_DIRECTORY Victron/Mock
    QML_FILES ${Mock_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
# end Mock_QML_MODULE

# Units_QML_MODULE
set(Units_QML_MODULE_SOURCES
    src/units.h
    src/units.cpp
)
list(APPEND QML_MODULE_SOURCES ${Units_QML_MODULE_SOURCES})
qt_add_qml_module(Units
    URI Victron.Units
    STATIC
    OUTPUT_DIRECTORY Victron/Units
    SOURCES ${Units_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
# end Units_QML_MODULE

# Utils_QML_MODULE
set(Utils_QML_MODULE_SOURCES
    components/Utils.js
)

list(APPEND QML_MODULE_SOURCES ${Utils_QML_MODULE_SOURCES})

qt_add_qml_module(Utils
    URI Victron.Utils
    STATIC
    OUTPUT_DIRECTORY Victron/Utils
    QML_FILES ${Utils_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
# end Utils_QML_MODULE

# Gauges_QML_MODULE
set(Gauges_QML_MODULE_SOURCES
    components/Gauges.js
)

list(APPEND QML_MODULE_SOURCES ${Gauges_QML_MODULE_SOURCES})

qt_add_qml_module(Gauges
    URI Victron.Gauges
    STATIC
    OUTPUT_DIRECTORY Victron/Gauges
    QML_FILES ${Gauges_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
# end Gauges_QML_MODULE

# Mqtt_QML_MODULE
set(Mqtt_QML_MODULE_SOURCES
    data/mqtt/BatteriesImpl.qml
    data/mqtt/ChargersImpl.qml
    data/mqtt/DcInputsImpl.qml
    data/mqtt/DcLoadsImpl.qml
    data/mqtt/DcSystemsImpl.qml
    data/mqtt/DigitalInputsImpl.qml
    data/mqtt/EnvironmentInputsImpl.qml
    data/mqtt/EssImpl.qml
    data/mqtt/EvChargersImpl.qml
    data/mqtt/GeneratorsImpl.qml
    data/mqtt/InvertersImpl.qml
    data/mqtt/MeteoDevicesImpl.qml
    data/mqtt/MotorDrivesImpl.qml
    data/mqtt/MqttDataManager.qml
    data/mqtt/MultiRsDevicesImpl.qml
    data/mqtt/NotificationsImpl.qml
    data/mqtt/PulseMetersImpl.qml
    data/mqtt/PvInvertersImpl.qml
    data/mqtt/RelaysImpl.qml
    data/mqtt/SolarChargersImpl.qml
    data/mqtt/SystemImpl.qml
    data/mqtt/SystemSettingsImpl.qml
    data/mqtt/TanksImpl.qml
    data/mqtt/UnsupportedDevicesImpl.qml
    data/mqtt/VeBusDevicesImpl.qml
)

list(APPEND QML_MODULE_SOURCES ${Mqtt_QML_MODULE_SOURCES} )

qt_add_qml_module(Mqtt
    URI Victron.Mqtt
    STATIC
    OUTPUT_DIRECTORY Victron/Mqtt
    QML_FILES ${Mqtt_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
# end Mqtt_QML_MODULE

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
list(APPEND SOURCES ${VEUTIL_CORE_SOURCES})

SET(VEUTIL_DBUS_SOURCES
    src/veutil/inc/veutil/qt/ve_dbus_connection.hpp
    src/veutil/inc/veutil/qt/ve_qitems_dbus.hpp
    src/veutil/inc/veutil/qt/vebus_error.hpp

    src/veutil/src/qt/ve_dbus_connection.cpp
    src/veutil/src/qt/ve_qitems_dbus.cpp
    src/veutil/src/qt/vebus_error.cpp
)
if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    list(APPEND SOURCES ${VEUTIL_DBUS_SOURCES} )
endif()

set(VEUTIL_MQTT_SOURCES
    src/veutil/inc/veutil/qt/ve_qitems_mqtt.hpp
    src/veutil/src/qt/ve_qitems_mqtt.cpp
)
list(APPEND SOURCES
    ${VEUTIL_MQTT_SOURCES}
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
if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    list(APPEND SOURCES ${GUIv1_DBUS_SOURCES})
endif()

set(VENUS_CPP_SOURCES
    src/main.cpp
    src/logging.h
    src/veqitemmockproducer.h
    src/veqitemmockproducer.cpp
)

set_source_files_properties(
    ${VENUS_CPP_SOURCES}
    PROPERTIES
    COMPILE_OPTIONS "${venusCompileFlags}"
)

list(APPEND SOURCES
    ${VENUS_CPP_SOURCES}
)

list(APPEND TRANSLATION_SOURCES
    ${SOURCES}
    ${QML_MODULE_SOURCES}
)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    list(APPEND venusCompileFlags  ${UNIX_COMPILE_FLAGS})
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
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
    list(APPEND venusCompileFlags ${UNIX_COMPILE_FLAGS})
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
endif()

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES Main.qml
    IMPORTS Victron.VenusOS
)

qt_add_resources(${PROJECT_NAME} "${PROJECT_NAME}_large_resources"
    BIG_RESOURCES
    FILES
        fonts/MuseoSans-500.otf
        images/acloads.svg
        images/alternator.svg
        images/battery.svg
        images/battery_charging.svg
        images/battery_discharging.svg
        images/blackWater.svg
        images/brief.svg
        images/cloud.svg
        images/consumption.svg
        images/dcloads.svg
        images/dropdown.svg
        images/electron.svg
        images/ess.svg
        images/freshWater.svg
        images/freshWater20x27.svg
        images/fuel.svg
        images/fueltank.svg
        images/gauge_intro_5_matte_black.gif
        images/gauge_intro_5_matte_white.gif
        images/gauge_intro_7_matte_black.gif
        images/gauge_intro_7_matte_white.gif
        images/generator.svg
        images/grid.svg
        images/icon_simlocked_32.svg
        images/icon_alarm_48.svg
        images/icon_alarm_snooze_24
        images/icon_autostart_24.svg
        images/icon_back_32.svg
        images/icon_charging_station_24.svg
        images/icon_checkmark_32.svg
        images/icon_checkmark_48.svg
        images/icon_controls_off_32.svg
        images/icon_controls_on_32.svg
        images/icon_dc_24.svg
        images/icon_humidity_32.svg
        images/icon_hydraulic_oil_32.svg
        images/icon_input_24.svg
        images/icon_lng_32.svg
        images/icon_lpg_32.svg
        images/icon_manualstart_24.svg
        images/icon_manualstart_timer_24.svg
        images/icon_minus.svg
        images/icon_plus.svg
        images/icon_raw_water_32.svg
        images/icon_refresh_32.svg
        images/icon_sidepanel_off_32.svg
        images/icon_sidepanel_on_32.svg
        images/icon_temp_32.svg
        images/information.svg
        images/inverter.svg
        images/inverter_charger.svg
        images/levels.svg
        images/liveWell.svg
        images/notifications.svg
        images/oil.svg
        images/overview.svg
        images/rain.svg
        images/scatteredcloud.svg
        images/settings.png
        images/settings.svg
        images/shore.svg
        images/solaryield.svg
        images/splash-logo-icon-5inch.svg
        images/splash-logo-icon-7inch.svg
        images/splash-logo-text-5inch.svg
        images/splash-logo-text-7inch.svg
        images/sunny.svg
        images/switch_indicator.png
        images/switches.svg
        images/tank.svg
        images/toast_icon_alarm.svg
        images/toast_icon_checkmark.svg
        images/toast_icon_close.svg
        images/toast_icon_info.svg
        images/wasteWater.svg
        images/widget_connector_nub_horizontal.svg
        images/widget_connector_nub_vertical.svg
        images/wind.svg
        themes/animation/Animation.json
        themes/color/ColorDesign.json
        themes/color/Dark.json
        themes/color/Light.json
        themes/geometry/FiveInch.json
        themes/geometry/SevenInch.json
        themes/typography/FiveInch.json
        themes/typography/SevenInch.json
        themes/typography/TypographyDesign.json
)

# Copy the input .ts files to the build directory before running lupdate on the copies.
# That way if new entries are added in code, the updates don't pollute the git diff.
file(COPY
      "i18n/${PROJECT_NAME}.ts"
      "i18n/${PROJECT_NAME}_en.ts"
      "i18n/${PROJECT_NAME}_fr.ts"
    DESTINATION "i18n") # build directory

# This adds 2 new targets, venus-gui-v2_lupdate and venus-gui-v2_lrelease. Parallel builds (eg. 'make -j') do not rebuild venus-gui-v2_lrelease correctly without further 'add_dependencies' hackery
qt_add_translations( ${PROJECT_NAME}
    TS_FILES
      "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}.ts"
      "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
      "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_fr.ts"
    SOURCES "${TRANSLATION_SOURCES}"
    LUPDATE_OPTIONS -no-obsolete
    LRELEASE_OPTIONS -idbased
)

add_dependencies(${PROJECT_NAME}_lrelease ${PROJECT_NAME}_lupdate) # We shouldn't need this line, but without it, parallel builds (eg. 'make -j') do not generate translations correctly

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)


add_link_options(
    $<$<CONFIG:RELEASE>:-s>     # strip the binary for Release builds
    $<$<CONFIG:MINSIZEREL>:-s>  # strip the binary for MinSizeRel builds
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::Xml
    Qt6::Mqtt
    VenusQMLModuleplugin
    Gaugesplugin
    Unitsplugin
    Utilsplugin
    Dbusplugin
    Mockplugin
    Mqttplugin
)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::WebSockets
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::DBus
    )
endif()

# see if the dependency graph is correct, for translations support...
add_custom_target(graphviz
                 "${CMAKE_COMMAND}" "--graphviz=${PROJECT_NAME}.dot" .
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
# disable it for now, can re-enable for future analysis when required.
#add_dependencies(${PROJECT_NAME} graphviz)
