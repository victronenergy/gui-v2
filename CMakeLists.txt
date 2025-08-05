#
# Copyright (C) 2023 Victron Energy B.V.
# See LICENSE.txt for license information.
#

if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds are not allowed. Build artifacts such as CMakeCache.txt created in ${CMAKE_SOURCE_DIR} will cause problems for future builds. Run 'git clean -fd' in ${CMAKE_SOURCE_DIR} to continue.")
endif()

cmake_minimum_required(VERSION 3.24) # earlier versions of cmake don't handle 'qt_add_qml_module' properly, you get errors at runtime like: "qrc:/main.qml:164 ApplicationContent is not a type\n"

# CMAKE HINTS
# see: https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2
#
# Different build types:
#   cmake -DCMAKE_BUILD_TYPE=[Debug|Release|RelWithDebInfo|MinSizeRelease] /path/to/CMakeLists.txt
#
# Translations
#   You can download the latest translations from poeditor if you have a token.
#       cmake /path/to/CMakeLists.txt
#       POEDITOR_TOKEN='....' make download_translations  # this downloads all translations
#       POEDITOR_TOKEN='....' make venus-gui-v2_uk        # this downloads a single translation file
#
#   You can upload new terms to poeditor if you have a token.
#       cmake /path/to/CMakeLists.txt
#       POEDITOR_TOKEN='....' make upload_translations  # this uploads /path/to/build/i18n/venus-gui-v2.ts to poeditor

cmake_policy(SET CMP0071 NEW) # process GENERATED source files in AUTOMOC and AUTOUIC. Added to silence a cmake warning.
cmake_policy(SET CMP0079 NEW)

project(venus-gui-v2 LANGUAGES CXX VERSION 1.2.8)
add_definitions(-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR} -DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR} -DPROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH} )

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/install CACHE PATH "..." FORCE)
else()
    include(GNUInstallDirs)
endif()

option(LOAD_QML_FROM_FILESYSTEM "disable filesystem loading via cmake -DLOAD_QML_FROM_FILESYSTEM=OFF" ON) # Enabled by default
option(NO_CACHEGEN "Enable bytecode compilation and lint processing for all qml files via cmake -NO_CACHEGEN=OFF" ON) # Enabled by default
option(RUN_UNIT_TESTS "only affects desktop builds. Enable via cmake -DRUN_UNIT_TESTS=ON" OFF) # Disabled by default

if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
    set(VENUS_DESKTOP_BUILD ON)
endif()
if (${VENUS_DESKTOP_BUILD})
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    enable_testing()
    add_subdirectory(tests)
endif()

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")
message("CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message("CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

# If we want a release build, remove the '-g' debug compiler flag set by the environment setup script.
# Otherwise, our executable size ballons from ~10MB to ~220MB.
if(("${CMAKE_BUILD_TYPE}" STREQUAL "Release" OR "${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel"))
    message("Removing '-g' debug flag set by /opt/venus/dunfell-arm-cortexa7hf-neon-vfpv4/environment-setup-cortexa7hf-neon-vfpv4-ve-linux-gnueabi")
    # Match all instances of " -g " in the input "${CMAKE_CXX_FLAGS}" and replace it with a single space " " and store the result into the output variable CMAKE_CXX_FLAGS
    string(REPLACE " -g " " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    message("new CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS} ")
endif()

if (${NO_CACHEGEN})
    message("Disabling cache generation for faster builds")
    set (QML_MODULE_OPTARGS ${QML_MODULE_OPTARGS} "NO_CACHEGEN")
endif()

if (${LOAD_QML_FROM_FILESYSTEM})
    message("This application will load qml sources from the filesystem, not from the compiled resources")
endif()

set(REQUIRED_QT_VERSION 6.8.3) # qt 6.8.3 required for 'qt_standard_project_setup(...)' to work

# Common Qt components for all platforms
find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS Core Gui Qml Quick QuickControls2 Svg Xml Mqtt LinguistTools REQUIRED)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    add_compile_definitions(VENUS_WEBASSEMBLY_BUILD)
    add_compile_definitions(MQTT_WEBSOCKETS_ENABLED)
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS WebSockets ShaderTools REQUIRED)
else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS DBus REQUIRED)
endif()

# TODO - Remove the following block once aqtinstall supports 'qt6_add_shaders(...)'.
# CI wasm builds use aqtinstall, which doesn't support qt6_add_shaders.
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten" AND NOT COMMAND qt6_add_shaders)
    function(qt6_add_shaders target name)
        set(options BATCHABLE PRECOMPILE OPTIMIZED)
        set(oneValueArgs PREFIX)
        set(multiValueArgs FILES)
        cmake_parse_arguments(SHADER "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

        # Find qsb tool
        find_program(QSB_TOOL qsb PATHS /opt/venus/build-gx-hostedtoolcache/Qt/6.8.3/gcc_64/bin NO_DEFAULT_PATH)

        if(NOT QSB_TOOL)
            message(FATAL_ERROR "qsb tool not found")
        endif()

        # Process each shader file
        foreach(shader_file ${SHADER_FILES})
            get_filename_component(shader_name ${shader_file} NAME_WE)
            get_filename_component(shader_dir ${shader_file} DIRECTORY)

            # Output file
            set(output_file "${CMAKE_CURRENT_BINARY_DIR}/${shader_dir}/${shader_name}.qsb")

            # Create directory if needed
            get_filename_component(output_dir ${output_file} DIRECTORY)
            file(MAKE_DIRECTORY ${output_dir})

            # Add custom command to compile shader
            add_custom_command(
                OUTPUT ${output_file}
                COMMAND ${QSB_TOOL} --glsl "100 es,120,150" --hlsl 50 --msl 12 -o ${output_file} ${CMAKE_CURRENT_SOURCE_DIR}/${shader_file}
                DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${shader_file}
                COMMENT "Compiling shader ${shader_file}"
            )

            # Add to target
            target_sources(${target} PRIVATE ${output_file})
            set_source_files_properties(${output_file} PROPERTIES QT_RESOURCE_ALIAS "${shader_name}.qsb")
        endforeach()
    endfunction()

    message(STATUS "Created custom qt6_add_shaders function")
endif()
# end TODO

list(APPEND TS_CODES "af" "ar" "cs" "da" "de" "es" "fr" "it" "nl" "pl" "ro" "ru" "sv" "th" "tr" "uk" "zh_CN")
qt_standard_project_setup(REQUIRES ${REQUIRED_QT_VERSION}
    I18N_SOURCE_LANGUAGE en # optional - this is the default
    I18N_TRANSLATED_LANGUAGES ${TS_CODES}
)

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

set(QZXING_USE_QML ON)
set(QZXING_USE_ENCODER ON)
add_subdirectory(src/qzxing/src)

include_directories(src/veutil/inc src .)

set (VENUS_QML_MODULE_SINGLETON_SOURCES # All qml singletons have to be added here
    components/CommonWords.qml
    components/FirmwareVersion.qml
    Global.qml
)
set_source_files_properties( ${VENUS_QML_MODULE_SINGLETON_SOURCES} PROPERTIES QT_QML_SINGLETON_TYPE TRUE )

set(VEUTIL_CORE_SOURCES
    src/veutil/inc/veutil/qt/alternator_error.hpp
    src/veutil/inc/veutil/qt/bms_error.hpp
    src/veutil/inc/veutil/qt/charger_error.hpp
    src/veutil/inc/veutil/qt/firmware_updater_data.hpp
    src/veutil/inc/veutil/qt/genset_error.hpp
    src/veutil/inc/veutil/qt/unit_conversion.hpp
    src/veutil/inc/veutil/qt/ve_qitem.hpp
    src/veutil/inc/veutil/qt/ve_qitem_child_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_loader.hpp
    src/veutil/inc/veutil/qt/ve_qitem_sort_table_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_table_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_tree_model.hpp
    src/veutil/inc/veutil/qt/ve_quick_item.hpp

    src/veutil/src/qt/alternator_error.cpp
    src/veutil/src/qt/bms_error.cpp
    src/veutil/src/qt/charger_error.cpp
    src/veutil/src/qt/genset_error.cpp
    src/veutil/src/qt/unit_conversion.cpp
    src/veutil/src/qt/ve_qitem.cpp
    src/veutil/src/qt/ve_qitem_child_model.cpp
    src/veutil/src/qt/ve_qitem_loader.cpp
    src/veutil/src/qt/ve_qitem_sort_table_model.cpp
    src/veutil/src/qt/ve_qitem_table_model.cpp
    src/veutil/src/qt/ve_qitem_tree_model.cpp
    src/veutil/src/qt/ve_quick_item.cpp
)
list(APPEND VenusQMLModule_CPP_SOURCES ${VEUTIL_CORE_SOURCES})

SET(VEUTIL_DBUS_SOURCES
    src/veutil/inc/veutil/qt/ve_dbus_connection.hpp
    src/veutil/inc/veutil/qt/ve_qitems_dbus.hpp
    src/veutil/inc/veutil/qt/vebus_error.hpp

    src/veutil/src/qt/ve_dbus_connection.cpp
    src/veutil/src/qt/ve_qitems_dbus.cpp
    src/veutil/src/qt/vebus_error.cpp
)
if(NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    list(APPEND VenusQMLModule_CPP_SOURCES ${VEUTIL_DBUS_SOURCES} )
endif()

set(VEUTIL_MQTT_SOURCES
    src/veutil/inc/veutil/qt/ve_qitems_mqtt.hpp
    src/veutil/src/qt/ve_qitems_mqtt.cpp
)
list(APPEND VenusQMLModule_CPP_SOURCES
    ${VEUTIL_MQTT_SOURCES}
)


# VENUS_QML_MODULE
set (VENUS_QML_MODULE_SOURCES
    ${VENUS_QML_MODULE_SINGLETON_SOURCES}

    ApplicationContent.qml
    FrameRateVisualizer.qml

    components/AcceptButtonBackground.qml
    components/AcPhasesCurrentRange.qml
    components/AcInputDirectionIcon.qml
    components/AcMeterModel.qml
    components/AllDevicesModel.qml
    components/AcOutput.qml
    components/AcPhase.qml
    components/Arc.qml
    components/ArcGauge.qml
    components/ArcGaugeQuantityRow.qml
    components/AsymmetricRoundedRectangle.qml
    components/BarGauge.qml
    components/BarGaugeBase.qml
    components/BaseListView.qml
    components/Breadcrumbs.qml
    components/BriefSidePanelWidget.qml
    components/BriefCenterDisplay.qml
    components/CardViewLoader.qml
    components/CircularMultiGauge.qml
    components/CircularSingleGauge.qml
    components/CheapBarGauge.qml
    components/ClippingBarGauge.qml
    components/ControlCard.qml
    components/CpuMonitor.qml
    components/DateSelector.qml
    components/Device.qml
    components/DeviceListDelegate.qml
    components/DevicePage.qml
    components/DynamicValueRange.qml
    components/ElectricalQuantityLabel.qml
    components/EnvironmentGauge.qml
    components/EnvironmentGaugePanel.qml
    components/ExpandedTanksView.qml
    components/FirmwareUpdate.qml
    components/FittedQuantityLabel.qml
    components/FixedWidthLabel.qml
    components/GaugeModel.qml
    components/GaugeHeader.qml
    components/GeneratorManualControlButton.qml
    components/GensetStartStop1Finder.qml
    components/EvChargerStatusModel.qml
    components/FlatListItemSeparator.qml
    components/GeneratorIconLabel.qml
    components/GradientListView.qml
    components/GsmStatusIcon.qml
    components/IconButton.qml
    components/InputPanel.qml
    components/InverterAcOutSettings.qml
    components/Led.qml
    components/LoadGraph.qml
    components/LoadGraphShapePath.qml
    components/KeyNavigationListHelper.qml
    components/NavBar.qml
    components/NavButton.qml
    components/NetworkServices.qml
    components/NotificationCounter.qml
    components/NotificationDelegate.qml
    components/ObjectAcConnection.qml
    components/ObjectModelMonitor.qml
    components/Page.qml
    components/PageGensetModel.qml
    components/PageStack.qml
    components/VeQuickItemsQuotient.qml
    components/ProgressArc.qml
    components/QuantityGroupListHeader.qml
    components/QuantityLabel.qml
    components/QuantityRow.qml
    components/QuantityTable.qml
    components/QuantityTableMetrics.qml
    components/QuantityTableSummary.qml
    components/RadioButtonListPage.qml
    components/RsSystemAcIODisplay.qml
    components/SolarDeviceModel.qml
    components/SegmentedButtonRow.qml
    components/SeparatorBar.qml
    components/ServiceDeviceModel.qml
    components/ServiceModel.qml
    components/SettingsColumn.qml
    components/SettingsRangeSlider.qml
    components/SettingsSlider.qml
    components/SettingSync.qml
    components/ShinyProgressArc.qml
    components/SideGauge.qml
    components/SideMultiGauge.qml
    components/SolarDetailBox.qml
    components/SolarHistoryChart.qml
    components/SolarHistoryErrorView.qml
    components/SolarHistoryTableView.qml
    components/SolarYieldGauge.qml
    components/SolarYieldGraph.qml
    components/SolarYieldModel.qml
    components/SplashView.qml
    components/StatusBar.qml
    components/SwipePageModel.qml
    components/SwipeViewPage.qml
    components/SwitchableOutputDelegate.qml
    components/SwitchableOutputGroupCard.qml
    components/SystemBatteryDelegate.qml
    components/SystemBatteryDeviceModel.qml
    components/SystemReason.qml
    components/TabBar.qml
    components/TankItem.qml
    components/TankGauge.qml
    components/TemperatureRelaySettings.qml
    components/ThreePhaseBarGauge.qml
    components/ThreePhaseDisplay.qml
    components/ThreePhaseIOTable.qml
    components/ThreePhaseQuantityTable.qml
    components/TimeSelector.qml
    components/ToastNotification.qml
    components/Utils.js
    components/ValueRange.qml
    components/VeBusAcIODisplay.qml
    components/ViewGradient.qml
    components/WasmVirtualKeyboardHandler.qml
    components/WifiModel.qml
    components/ClassAndVrmInstance.qml
    components/controls/Button.qml
    components/controls/ComboBox.qml
    components/controls/DimmingSlider.qml
    components/controls/EditFrame.qml
    components/controls/GlobalKeyNavigationHighlight.qml
    components/controls/Label.qml
    components/controls/ListItemButton.qml
    components/controls/ListPressArea.qml
    components/controls/PressArea.qml
    components/controls/ProgressBar.qml
    components/controls/RadioButton.qml
    components/controls/RangeSlider.qml
    components/controls/RemoveButton.qml
    components/controls/ScrollBar.qml
    components/controls/Slider.qml
    components/controls/SpinBox.qml
    components/controls/SwipeView.qml
    components/controls/Switch.qml
    components/controls/TextField.qml

    components/dialogs/CurrentLimitDialog.qml
    components/dialogs/DateSelectorDialog.qml
    components/dialogs/DialogShadow.qml
    components/dialogs/VrmInstanceSwapDialog.qml
    components/dialogs/ESSMinimumSOCDialog.qml
    components/dialogs/EvcsChargerModeDialog.qml
    components/dialogs/GeneratorDialog.qml
    components/dialogs/GeneratorStartDialog.qml
    components/dialogs/GeneratorStopDialog.qml
    components/dialogs/GeneratorDisableAutoStartDialog.qml
    components/dialogs/InverterChargerModeDialog.qml
    components/dialogs/InverterChargerEssModeDialog.qml
    components/dialogs/ModalDialog.qml
    components/dialogs/ModalRebootingDialog.qml
    components/dialogs/ModalWarningDialog.qml
    components/dialogs/NumberSelectorDialog.qml
    components/dialogs/SecurityProfilePasswordDialog.qml
    components/dialogs/SolarDailyHistoryDialog.qml
    components/dialogs/TimeSelectorDialog.qml

    components/listitems/ListAcInError.qml
    components/listitems/ListActiveAcInput.qml
    components/listitems/ListAlarmLevelRadioButtonGroup.qml
    components/listitems/ListAlarmState.qml
    components/listitems/ListBriefCenterDetails.qml
    components/listitems/ListChargeSchedule.qml
    components/listitems/ListClearHistoryButton.qml
    components/listitems/ListCurrentLimitButton.qml
    components/listitems/ListDcInputQuantityGroup.qml
    components/listitems/ListDcOutputQuantityGroup.qml
    components/listitems/ListFirmwareCheckButton.qml
    components/listitems/ListFirmwareImageTypeInstalled.qml
    components/listitems/ListFirmwareVersion.qml
    components/listitems/ListGeneratorError.qml
    components/listitems/ListInverterChargerModeButton.qml
    components/listitems/ListLink.qml
    components/listitems/ListMqttAccessSwitch.qml
    components/listitems/ListMountStateButton.qml
    components/listitems/ListAcInPositionRadioButtonGroup.qml
    components/listitems/ListOutputBatteryRadioButtonGroup.qml
    components/listitems/ListPvInverterPositionRadioButtonGroup.qml
    components/listitems/ListRebootButton.qml
    components/listitems/ListRelayState.qml
    components/listitems/ListResetHistory.qml
    components/listitems/ListTemperatureRelay.qml
    components/listitems/ListVolumeUnitRadioButtonGroup.qml

    components/listitems/core/BaseListItem.qml
    components/listitems/core/BaseListLoader.qml
    components/listitems/core/ListAlarm.qml
    components/listitems/core/ListButton.qml
    components/listitems/core/ListDateSelector.qml
    components/listitems/core/ListIntField.qml
    components/listitems/core/ListIpAddressField.qml
    components/listitems/core/ListItem.qml
    components/listitems/core/ListItemBackground.qml
    components/listitems/core/ListNavigation.qml
    components/listitems/core/ListPortField.qml
    components/listitems/core/ListQuantityField.qml
    components/listitems/core/ListQuantityGroup.qml
    components/listitems/core/ListQuantityGroupNavigation.qml
    components/listitems/core/ListQuantity.qml
    components/listitems/core/ListRadioButton.qml
    components/listitems/core/ListRadioButtonGroup.qml
    components/listitems/core/ListRangeSlider.qml
    components/listitems/core/ListSlider.qml
    components/listitems/core/ListSpinBox.qml
    components/listitems/core/ListSwitch.qml
    components/listitems/core/ListSwitchForced.qml
    components/listitems/core/ListTemperature.qml
    components/listitems/core/ListText.qml
    components/listitems/core/ListTextField.qml
    components/listitems/core/ListTimeSelector.qml
    components/listitems/core/PrimaryListLabel.qml
    components/listitems/core/SecondaryListLabel.qml
    components/listitems/core/SectionHeader.qml
    components/listitems/core/SettingsListHeader.qml
    components/listitems/core/SettingsListNavigation.qml
    components/listitems/core/SliderHandleHighlight.qml

    components/widgets/AcWidget.qml
    components/widgets/AcInputWidget.qml
    components/widgets/AcLoadsWidget.qml
    components/widgets/BatteryWidget.qml
    components/widgets/DcInputWidget.qml
    components/widgets/DcLoadsWidget.qml
    components/widgets/EssentialLoadsWidget.qml
    components/widgets/EvcsWidget.qml
    components/widgets/InverterChargerWidget.qml
    components/widgets/OverviewWidget.qml
    components/widgets/SolarYieldWidget.qml
    components/widgets/WidgetConnector.qml
    components/widgets/WidgetConnectorAnchor.qml
    components/widgets/WidgetConnectorPath.qml
    components/widgets/WidgetHeader.qml

    data/AcInputs.qml
    data/DataManager.qml
    data/DcInputs.qml
    data/EnvironmentInputs.qml
    data/Ess.qml
    data/EvChargers.qml
    data/Generators.qml
    data/InverterChargers.qml
    data/Notifications.qml
    data/SolarInputs.qml
    data/StartPageConfiguration.qml
    data/Switches.qml
    data/System.qml
    data/SystemLoad.qml
    data/SystemSettings.qml
    data/Tanks.qml
    data/VenusPlatform.qml

    data/common/AcData.qml
    data/common/AcInputSettings.qml
    data/common/AcInputSettingsModel.qml
    data/common/AcInputSystemInfo.qml
    data/common/AcInput.qml
    data/common/ActiveSystemBattery.qml
    data/common/DcDevice.qml
    data/common/DcInput.qml
    data/common/DeviceModel.qml
    data/common/EvCharger.qml
    data/common/Generator.qml
    data/common/GensetErrorModel.qml
    data/common/Inverter.qml
    data/common/Notification.qml
    data/common/PvInverter.qml
    data/common/PvMonitor.qml
    data/common/SolarDailyHistory.qml
    data/common/SolarDevice.qml
    data/common/SolarHistory.qml
    data/common/SolarHistoryErrorModel.qml
    data/common/SolarTracker.qml
    data/common/SolarTrackerDailyHistory.qml
    data/common/SwitchableOutput.qml
    data/common/Tank.qml
    data/common/TankDescription.qml
    data/common/TankModel.qml

    pages/AuxCardsPage.qml
    pages/BriefSidePanel.qml
    pages/BriefPage.qml
    pages/ControlCardsPage.qml
    pages/DialogLayer.qml
    pages/EnvironmentTab.qml
    pages/LevelsPage.qml
    pages/LevelsTab.qml
    pages/MainView.qml
    pages/NotificationLayer.qml
    pages/NotificationsPage.qml
    pages/OverviewPage.qml
    pages/PageManager.qml
    pages/SettingsPage.qml
    pages/TanksTab.qml
    pages/controlcards/ESSCard.qml
    pages/controlcards/EVCSCard.qml
    pages/controlcards/GeneratorCard.qml
    pages/controlcards/InverterChargerCard.qml
    pages/evcs/EvChargerListPage.qml
    pages/evcs/EvChargerPage.qml
    pages/evcs/EvChargerSetupPage.qml
    pages/invertercharger/InverterChargerListPage.qml
    pages/invertercharger/OverviewInverterChargerPage.qml
    pages/settings/CanbusProfile.qml
    pages/settings/CanbusServiceFinder.qml
    pages/settings/DvccCommonSettings.qml
    pages/settings/GeneratorCondition.qml
    pages/settings/IpAddressListView.qml
    pages/settings/NetworkSettingsPageModel.qml
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
    pages/settings/PageSettingsAccessAndSecurity.qml
    pages/settings/PageSettingsAcSystem.qml
    pages/settings/PageSettingsAlarmsAndFeedback.qml
    pages/settings/PageSettingsBatteries.qml
    pages/settings/PageSettingsBatteryMeasurements.qml
    pages/settings/PageSettingsBleSensors.qml
    pages/settings/PageSettingsBluetooth.qml
    pages/settings/PageSettingsCanbus.qml
    pages/settings/PageSettingsCGwacs.qml
    pages/settings/PageSettingsCGwacsOverview.qml
    pages/settings/PageSettingsConnectivity.qml
    pages/settings/PageSettingsDisplayAndAppearance.qml
    pages/settings/PageSettingsDisplayBrief.qml
    pages/settings/PageSettingsDisplayMinMax.qml
    pages/settings/PageSettingsDisplayStartPage.qml
    pages/settings/PageSettingsDisplayUnits.qml
    pages/settings/PageSettingsDocumentation.qml
    pages/settings/PageSettingsDvcc.qml
    pages/settings/PageSettingsDynamicEss.qml
    pages/settings/PageSettingsEthernet.qml
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
    pages/settings/PageSettingsGsm.qml
    pages/settings/PageSettingsHub4.qml
    pages/settings/PageSettingsHub4Feedin.qml
    pages/settings/PageSettingsHub4Peakshaving.qml
    pages/settings/PageSettingsIntegrations.qml
    pages/settings/PageSettingsLarge.qml
    pages/settings/PageSettingsLogger.qml
    pages/settings/PageSettingsModbus.qml
    pages/settings/PageSettingsModbusAddDevice.qml
    pages/settings/PageSettingsModbusDevices.qml
    pages/settings/PageSettingsModbusDiscovered.qml
    pages/settings/PageSettingsModbusTcp.qml
    pages/settings/PageSettingsModbusTcpServices.qml
    pages/settings/PageSettingsNodeRed.qml
    pages/settings/PageSettingsRelay.qml
    pages/settings/PageSettingsRelayTempSensors.qml
    pages/settings/PageSettingsRootfsSelect.qml
    pages/settings/PageSettingsRvcDevice.qml
    pages/settings/PageSettingsRvcDeviceConfiguration.qml
    pages/settings/PageSettingsRvcDevices.qml
    pages/settings/PageSettingsShelly.qml
    pages/settings/PageSettingsSignalK.qml
    pages/settings/PageSettingsSupportStatus.qml
    pages/settings/PageSettingsSystem.qml
    pages/settings/PageSettingsSystemStatus.qml
    pages/settings/PageSettingsTailscale.qml
    pages/settings/PageSettingsTankPump.qml
    pages/settings/PageSettingsTcpIp.qml
    pages/settings/PageSettingsVecanDevice.qml
    pages/settings/PageSettingsVecanDevices.qml
    pages/settings/PageSettingsWifi.qml
    pages/settings/PageTzInfo.qml
    pages/settings/PageVrmDeviceInstances.qml
    pages/settings/debug/HubData.qml
    pages/settings/debug/PageDebug.qml
    pages/settings/debug/PageDebugVeQItems.qml
    pages/settings/debug/PagePowerDebug.qml
    pages/settings/debug/PageSettingsDemo.qml
    pages/settings/debug/PageSystemData.qml
    pages/settings/devicelist/DeviceListPage.qml
    pages/settings/devicelist/PageAcCharger.qml
    pages/settings/devicelist/PageDigitalInput.qml
    pages/settings/devicelist/PageGenset.qml
    pages/settings/devicelist/PageMeteo.qml
    pages/settings/devicelist/PageMeteoSettings.qml
    pages/settings/devicelist/PageMotorDrive.qml
    pages/settings/devicelist/PageSwitch.qml
    pages/settings/devicelist/PageUnsupportedDevice.qml
    pages/settings/devicelist/battery/BatteryDetails.qml
    pages/settings/devicelist/battery/BatteryHistory.qml
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
    pages/settings/devicelist/dc-in/DcHistorySettingsColumn.qml
    pages/settings/devicelist/dc-in/ListCycleHistoryItem.qml
    pages/settings/devicelist/dc-in/DcBmsSettingsPage.qml
    pages/settings/devicelist/dc-in/PageAlternator.qml
    pages/settings/devicelist/dc-in/PageAlternatorModel.qml
    pages/settings/devicelist/dc-in/PageDcDcConverter.qml
    pages/settings/devicelist/dc-in/PageDcMeter.qml
    pages/settings/devicelist/dc-in/PageDcMeterModel.qml
    pages/settings/devicelist/dc-in/PageDcMeterAlarms.qml
    pages/settings/devicelist/dc-in/PageDcMeterHistory.qml
    pages/settings/devicelist/delegates/AcInDeviceListDelegate.qml
    pages/settings/devicelist/delegates/DcDeviceListDelegate.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_acload.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_acsystem.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_alternator.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_battery.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_charger.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_dcdc.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_dcgenset.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_dcload.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_dcsource.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_dcsystem.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_digitalinput.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_evcharger.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_fuelcell.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_genset.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_gps.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_grid.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_heatpump.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_inverter.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_meteo.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_motordrive.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_multi.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_pulsemeter.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_pvinverter.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_solarcharger.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_switch.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_tank.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_temperature.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_unsupported.qml
    pages/settings/devicelist/delegates/DeviceListDelegate_vebus.qml
    pages/settings/devicelist/delegates/DisconnectedDeviceListDelegate.qml
    pages/settings/devicelist/delegates/GensetDeviceListDelegate.qml
    pages/settings/devicelist/inverter/PageInverter.qml
    pages/settings/devicelist/inverter/PageSolarStats.qml
    pages/settings/devicelist/rs/PageMultiRs.qml
    pages/settings/devicelist/rs/PageRsAlarms.qml
    pages/settings/devicelist/rs/PageRsAlarmSettings.qml
    pages/settings/devicelist/rs/PageRsSystem.qml
    pages/settings/devicelist/rs/PageRsSystemAlarms.qml
    pages/settings/devicelist/rs/PageRsSystemDevices.qml
    pages/settings/devicelist/rs/PageRsSystemEss.qml
    pages/settings/devicelist/tank/PageTankAlarm.qml
    pages/settings/devicelist/tank/PageTankSensor.qml
    pages/settings/devicelist/tank/PageTankSetup.qml
    pages/settings/devicelist/tank/PageTankShape.qml
    pages/settings/devicelist/ac-in/PageAcIn.qml
    pages/settings/devicelist/ac-in/PageAcInSetup.qml
    pages/settings/devicelist/ac-in/PageAcInModel.qml
    pages/settings/devicelist/ac-in/PageSmappeeCTList.qml
    pages/settings/devicelist/ac-in/PageSmappeeCTSetup.qml
    pages/settings/devicelist/ac-in/PageSmappeeDeviceList.qml
    pages/settings/devicelist/pulsemeter/PagePulseCounter.qml
    pages/settings/devicelist/pulsemeter/PagePulseCounterSetup.qml
    pages/settings/devicelist/switchable-outputs/PageSwitchableOutput.qml
    pages/settings/devicelist/switchable-outputs/SwitchableOutputListDelegate.qml
    pages/settings/devicelist/temperature/PageTemperatureSensor.qml
    pages/settings/devicelist/temperature/PageTemperatureSensorSetup.qml
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
    pages/solar/PageSolarCharger.qml
    pages/solar/PageSolarParallelOperation.qml
    pages/solar/PvInverterPage.qml
    pages/solar/SolarDevicePage.qml
    pages/solar/SolarHistoryPage.qml
    pages/solar/SolarInputListPage.qml
    pages/vebusdevice/PageAcSensor.qml
    pages/vebusdevice/PageAcSensors.qml
    pages/vebusdevice/PageVeBusAdvanced.qml
    pages/vebusdevice/PageVeBusAlarms.qml
    pages/vebusdevice/PageVeBusAlarmSettings.qml
    pages/vebusdevice/PageVeBusBms.qml
    pages/vebusdevice/PageVeBusDebug.qml
    pages/vebusdevice/PageVeBusError11Device.qml
    pages/vebusdevice/PageVeBusError11Menu.qml
    pages/vebusdevice/PageVeBusError11View.qml
    pages/vebusdevice/PageVeBusKwhCounters.qml
    pages/vebusdevice/PageVeBusSerialNumbers.qml
    pages/vebusdevice/PageVeBusBackupRestore.qml
    pages/vebusdevice/PVCFListQuantityGroup.qml
    pages/vebusdevice/VeBusAcSensorModel.qml
    pages/vebusdevice/PageVeBus.qml
    pages/vebusdevice/VeBusAlarm.qml
    pages/vebusdevice/VeBusDeviceAlarmGroup.qml
    pages/vebusdevice/VeBusDeviceAlarmSettingsModel.qml
    pages/vebusdevice/VeBusDeviceAlarmStatusModel.qml
    pages/vebusdevice/VeBusDeviceInfoModel.qml
    pages/vebusdevice/VeBusDeviceKwhCountersModel.qml
    pages/welcome/WelcomePage.qml
    pages/welcome/WelcomeView.qml
)

# TODO: re-enable for Desktop and Device builds, see issue #2351
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    list(APPEND VENUS_QML_MODULE_SOURCES
        components/controls/PressEffect.qml
    )
endif()

list(APPEND TRANSLATION_SOURCES ${VENUS_QML_MODULE_SOURCES})

list(APPEND VenusQMLModule_CPP_SOURCES
    src/aggregatedevicemodel.h
    src/aggregatedevicemodel.cpp
    src/aggregatetankmodel.h
    src/aggregatetankmodel.cpp
    src/visibleitemmodel.h
    src/visibleitemmodel.cpp
    src/basedevice.h
    src/basedevice.cpp
    src/basedevicemodel.h
    src/basedevicemodel.cpp
    src/basetankdevice.h
    src/basetankdevice.cpp
    src/basetankdevicemodel.h
    src/basetankdevicemodel.cpp
    src/theme.h
    src/theme.cpp
    src/themeobjects.h
    src/backendconnection.h
    src/backendconnection.cpp
    src/language.h
    src/language.cpp
    src/enums.h
    src/enums.cpp
    src/fastutils.h
    src/fastutils.cpp
    src/basenotification.h
    src/basenotification.cpp
    src/notificationsmodel.h
    src/notificationsmodel.cpp
    src/notificationsortfilterproxymodel.h
    src/notificationsortfilterproxymodel.cpp
    src/clocktime.h
    src/clocktime.cpp
    src/cpuinfo.h
    src/cpuinfo.cpp
    src/frameratemodel.h
    src/frameratemodel.cpp
    src/keyeventfilter.h
    src/keyeventfilter.cpp
    src/keynavigationhighlight.cpp
    src/keynavigationhighlight.h
    src/keynavigationhighlighthelper.h
    src/keynavigationhighlighthelper.cpp
    src/mockmanager.h
    src/mockmanager.cpp
    src/phasemodel.h
    src/phasemodel.cpp
    src/productinfo.h
    src/qmlobject.h
    src/qmlobject.cpp
    src/quantityinfo.h
    src/quantityinfo.cpp
    src/quantityobject.h
    src/quantityobject.cpp
    src/quantityobjectmodel.h
    src/quantityobjectmodel.cpp
    src/qrangemodel_p.h
    src/qrangemodel.h
    src/qrangemodel.cpp
    src/units.h
    src/units.cpp
    src/screenblanker.h
    src/screenblanker.cpp
    src/solarinputmodel.h
    src/solarinputmodel.cpp
    src/switchableoutputmodel.h
    src/switchableoutputmodel.cpp
    src/switchableoutputgroupmodel.h
    src/switchableoutputgroupmodel.cpp
    src/widgetconnectorpathupdater.h
    src/widgetconnectorpathupdater.cpp
)

list(APPEND VenusQMLModule_CPP_SOURCES ${Units_CPP_SOURCES})

qt_add_qml_module(VenusQMLModule
    ${QML_MODULE_OPTARGS}
    URI Victron.VenusOS
    VERSION 2.0
    STATIC
    OUTPUT_DIRECTORY Victron/VenusOS
    QML_FILES ${VENUS_QML_MODULE_SOURCES}
    SOURCES ${VenusQMLModule_CPP_SOURCES}
)

# Add shaders for WebAssembly builds (requires QtShaderTools)
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    qt6_add_shaders(VenusQMLModule "venus-shaders"
        BATCHABLE
        PRECOMPILE
        OPTIMIZED
        PREFIX
            "/"
        FILES
            "components/controls/presseffect.frag"
    )
endif()

list(APPEND TRANSLATION_SOURCES ${VenusQMLModule_CPP_SOURCES})

target_include_directories(VenusQMLModule PRIVATE src/veutil/inc/veutil/qt)

target_link_libraries(VenusQMLModule PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::QuickPrivate
    Qt6::Xml
    Qt6::Mqtt
)

if (${LOAD_QML_FROM_FILESYSTEM})
    set(thisModule VenusQMLModule)
    qt_query_qml_module(${thisModule} QML_FILES module_qml_files QMLDIR module_qmldir)
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
        # linktarget VenusQMLModuleplugin
        # optional plugin VenusQMLModuleplugin
        # classname Victron_VenusOSPlugin
        # typeinfo VenusQMLModule.qmltypes
        # prefer :/qt/qml/Victron/VenusOS/  <- this line tells the app to prefer the compiled qml sources, i.e. don't load from the file system
        # singleton CommonWords 2.0 components/CommonWords.qml
        # [lots more qml files]

    # The 'prefer' line can't be removed via 'qt_add_qml_module', we need to delete it after the build step, and before the install step.
    # That is what the calls to 'StripRegexFromFile.cmake' are for.
    add_custom_command(
        TARGET ${thisModule}
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    target_link_libraries(VenusQMLModule PRIVATE Qt6::WebSockets)
else()
    target_link_libraries(VenusQMLModule PRIVATE Qt6::DBus)
endif()
# end VENUS_QML_MODULE

# Mock_QML_MODULE
set(Mock_QML_MODULE_SOURCES
    data/mock/BatteriesImpl.qml
    data/mock/DevicesImpl.qml
    data/mock/EvChargersImpl.qml
    data/mock/GeneratorsImpl.qml
    data/mock/InverterChargersImpl.qml
    data/mock/MiscServicesImpl.qml
    data/mock/MockDataRandomizer.qml
    data/mock/MockDataRangeAnimator.qml
    data/mock/MockSetup.qml
    data/mock/MockShortcuts.qml
    data/mock/MotorDrivesImpl.qml
    data/mock/NotificationsImpl.qml
    data/mock/SolarInputsImpl.qml
    data/mock/SystemAcImpl.qml
    data/mock/SystemDcImpl.qml
    data/mock/TanksImpl.qml
    data/mock/TemperaturesImpl.qml
    data/mock/page-conf/BoatPageConfig.qml
    data/mock/page-conf/BriefAndOverviewPageConfig.qml
    data/mock/page-conf/LevelsPageConfig.qml
)

list(APPEND TRANSLATION_SOURCES ${Mock_QML_MODULE_SOURCES})

qt_add_qml_module(VictronMock
    URI Victron.Mock
    STATIC
    OUTPUT_DIRECTORY Victron/Mock
    QML_FILES ${Mock_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
if (${LOAD_QML_FROM_FILESYSTEM})
    set(thisModule VictronMock)
    qt_query_qml_module(${thisModule} QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock)
    install(DIRECTORY data/mock         DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock/data)
    add_custom_command(
        TARGET ${thisModule}
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()
qt_add_resources(VictronMock "VictronMock_resources"
    BIG_RESOURCES
    FILES
        data/mock/conf/barebones.json
        data/mock/conf/maximal.json
        data/mock/conf/multi-rs.json
        data/mock/conf/switch-pane.json
        data/mock/conf/services/alternator.json
        data/mock/conf/services/dcgenset.json
        data/mock/conf/services/dcload-fridge.json
        data/mock/conf/services/dcsystem.json
        data/mock/conf/services/dse-genset.json
        data/mock/conf/services/digitalinput-alarm.json
        data/mock/conf/services/em-acload.json
        data/mock/conf/services/em-evcharger.json
        data/mock/conf/services/em-genset.json
        data/mock/conf/services/em-grid.json
        data/mock/conf/services/em-heatpump-input.json
        data/mock/conf/services/em-heatpump-output.json
        data/mock/conf/services/em-pvinverter.json
        data/mock/conf/services/ess.json
        data/mock/conf/services/evcharger1.json
        data/mock/conf/services/fronius.json
        data/mock/conf/services/generator.json
        data/mock/conf/services/gioextender.json
        data/mock/conf/services/gps.json
        data/mock/conf/services/inverter-rs.json
        data/mock/conf/services/lynxbms.json
        data/mock/conf/services/lynxparallel.json
        data/mock/conf/services/meteo-solarsense.json
        data/mock/conf/services/modem.json
        data/mock/conf/services/motordrive.json
        data/mock/conf/services/mppt1.json
        data/mock/conf/services/mppt2.json
        data/mock/conf/services/multirs-smart.json
        data/mock/conf/services/network-bluetooth.json
        data/mock/conf/services/network-wifi-and-ethernet.json
        data/mock/conf/services/notifications-alarm.json
        data/mock/conf/services/notifications-no-alarm.json
        data/mock/conf/services/orionxs-alternator.json
        data/mock/conf/services/orionxs-dcdc.json
        data/mock/conf/services/phoenix-smart-charger.json
        data/mock/conf/services/pulsemeter.json
        data/mock/conf/services/pump.json
        data/mock/conf/services/pvinverter.json
        data/mock/conf/services/pylontech.json
        data/mock/conf/services/quattro-3phase-grid-genset.json
        data/mock/conf/services/relays-temperature-and-manual.json
        data/mock/conf/services/ruuvi-fridge.json
        data/mock/conf/services/ruuvi-salon.json
        data/mock/conf/services/shelly.json
        data/mock/conf/services/skylla-charger.json
        data/mock/conf/services/smartshunt-battery.json
        data/mock/conf/services/smartshunt-dcsource.json
        data/mock/conf/services/smartswitch.json
        data/mock/conf/services/switch-controls-tester.json
        data/mock/conf/services/tank-blackwater-error-state.json
        data/mock/conf/services/tank-fuel1.json
        data/mock/conf/services/tank-fuel2.json
        data/mock/conf/services/tank-fuel3.json
        data/mock/conf/services/tank-greywater.json
        data/mock/conf/services/tank-lpg.json
        data/mock/conf/services/tank-water1.json
        data/mock/conf/services/tank-water2.json
        data/mock/conf/services/tank-water3.json
        data/mock/conf/services/tank-water4.json
        data/mock/conf/services/temperature-freezer.json
        data/mock/conf/services/temperature-watertank.json
        data/mock/conf/services/unsupported.json
        data/mock/conf/services/wind.json
        data/mock/conf/setup-common.json
        data/mock/conf/setup-essential-loads.json
)
# end Mock_QML_MODULE

# Gauges_QML_MODULE
set(Gauges_QML_MODULE_SOURCES
    components/Gauges.js
)

list(APPEND TRANSLATION_SOURCES ${Gauges_QML_MODULE_SOURCES})

qt_add_qml_module(VictronGauges
    URI Victron.Gauges
    STATIC
    OUTPUT_DIRECTORY Victron/Gauges
    QML_FILES ${Gauges_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
if (${LOAD_QML_FROM_FILESYSTEM})
    set(thisModule VictronGauges)
    qt_query_qml_module(${thisModule} QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir}    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Gauges)
    install(FILES ${module_qml_files} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Gauges/components)
    add_custom_command(
        TARGET ${thisModule}
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()
# end Gauges_QML_MODULE

# BoatPageComponents_QML_MODULE
set(BoatPageComponents_QML_MODULE_SOURCES
    pages/boatpage/BoatPage.qml
    pages/boatpage/Background.qml
    pages/boatpage/BatteryArc.qml
    pages/boatpage/BatteryPercentage.qml
    pages/boatpage/ConsumptionGauge.qml
    pages/boatpage/Gear.qml
    pages/boatpage/Gps.qml
    pages/boatpage/LargeCenterGauge.qml
    pages/boatpage/LoadArc.qml
    pages/boatpage/MotorDrive.qml
    pages/boatpage/MotorDriveGauges.qml
    pages/boatpage/QuantityLabelIconRow.qml
    pages/boatpage/TemperatureGauge.qml
    pages/boatpage/TemperatureGauges.qml
    pages/boatpage/TimeToGo.qml
)

set_source_files_properties(pages/boatpage/BoatPage.qml PROPERTIES QT_RESOURCE_ALIAS BoatPage.qml)
set_source_files_properties(pages/boatpage/Background.qml PROPERTIES QT_RESOURCE_ALIAS Background.qml)
set_source_files_properties(pages/boatpage/BatteryArc.qml PROPERTIES QT_RESOURCE_ALIAS BatteryArc.qml)
set_source_files_properties(pages/boatpage/BatteryPercentage.qml PROPERTIES QT_RESOURCE_ALIAS BatteryPercentage.qml)
set_source_files_properties(pages/boatpage/ConsumptionGauge.qml PROPERTIES QT_RESOURCE_ALIAS ConsumptionGauge.qml)
set_source_files_properties(pages/boatpage/Gear.qml PROPERTIES QT_RESOURCE_ALIAS Gear.qml)
set_source_files_properties(pages/boatpage/Gps.qml PROPERTIES QT_RESOURCE_ALIAS Gps.qml)
set_source_files_properties(pages/boatpage/LargeCenterGauge.qml PROPERTIES QT_RESOURCE_ALIAS LargeCenterGauge.qml)
set_source_files_properties(pages/boatpage/LoadArc.qml PROPERTIES QT_RESOURCE_ALIAS LoadArc.qml)
set_source_files_properties(pages/boatpage/MotorDrive.qml PROPERTIES QT_RESOURCE_ALIAS MotorDrive.qml)
set_source_files_properties(pages/boatpage/MotorDriveGauges.qml PROPERTIES QT_RESOURCE_ALIAS MotorDriveGauges.qml)
set_source_files_properties(pages/boatpage/QuantityLabelIconRow.qml PROPERTIES QT_RESOURCE_ALIAS QuantityLabelIconRow.qml)
set_source_files_properties(pages/boatpage/TemperatureGauge.qml PROPERTIES QT_RESOURCE_ALIAS TemperatureGauge.qml)
set_source_files_properties(pages/boatpage/TemperatureGauges.qml PROPERTIES QT_RESOURCE_ALIAS TemperatureGauges.qml)
set_source_files_properties(pages/boatpage/TimeToGo.qml PROPERTIES QT_RESOURCE_ALIAS TimeToGo.qml)

list(APPEND TRANSLATION_SOURCES ${BoatPageComponents_QML_MODULE_SOURCES})

qt_add_qml_module(BoatPageComponents
    URI Victron.BoatPageComponents
    STATIC
    OUTPUT_DIRECTORY Victron/BoatPageComponents
    QML_FILES ${BoatPageComponents_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)
if (${LOAD_QML_FROM_FILESYSTEM})
    set(thisModule BoatPageComponents)
    qt_query_qml_module(${thisModule} QML_FILES module_qml_files QMLDIR module_qmldir)
    install(DIRECTORY pages/boatpage/ DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/BoatPageComponents)
    install(FILES ${module_qmldir}    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/BoatPageComponents)
    add_custom_command(
        TARGET ${thisModule}
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()

qt_add_resources(BoatPageComponents "BoatPageComponents_large_resources"
    BIG_RESOURCES
    FILES
        images/boat_glow.png
        images/icon_battery_40.png
        images/icon_boat_32.svg
        images/icon_engine_temp_32.svg
        images/icon_motorController_32.svg
        images/icon_propeller_32.png
        images/icon_propeller.svg
        images/icon_temp_coolant_32.svg
)

# end BoatPageComponents_QML_MODULE

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
)

# Add targets to update the ts files from poeditor.
foreach(code IN LISTS TS_CODES)
    set(output_file ${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}_${code}.ts)
    set(new_target ${PROJECT_NAME}_${code})
    add_custom_target( ${new_target}
        COMMAND bash "-c" "${CMAKE_CURRENT_SOURCE_DIR}/.github/scripts/download_from_poeditor.sh ${code} ${output_file}"
    )
    list(APPEND TS_TARGETS ${new_target})
endforeach()

add_custom_target(download_translations
    DEPENDS ${TS_TARGETS}
)

add_custom_target(upload_translations
    COMMAND bash "-c" "${CMAKE_CURRENT_SOURCE_DIR}/.github/scripts/upload_new_terms.sh ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}.ts"
    DEPENDS ${PROJECT_NAME}
)

# Copy the input .ts files to the build directory before running lupdate on the copies.
# That way if new entries are added in code, the updates don't pollute the git diff.
# Then run lupdate manually and lrelease manually, and mark the generated files as GENERATED TRUE
# to force CMake to respect an appropriate dependency ordering.
SET(BUILD_DIR_TS_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
)
SET(BUILD_DIR_QM_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm"
)
SET(TRANSLATION_RESOURCE_FILES
    "<file>${PROJECT_NAME}_en.qm</file>"
)
foreach(TsCode ${TS_CODES})
    list(APPEND BUILD_DIR_QM_FILES
        "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm"
    )
    list(APPEND BUILD_DIR_TS_FILES
        "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
    )
endforeach()



list(APPEND ABSOLUTE_PATH_TRANSLATION_SOURCES ${TRANSLATION_SOURCES})
list(TRANSFORM ABSOLUTE_PATH_TRANSLATION_SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/")
file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt"
    CONTENT "$<JOIN:${ABSOLUTE_PATH_TRANSLATION_SOURCES},\n>"
)
add_custom_target(${PROJECT_NAME}_generate_translation_sources_file ALL
    COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt"
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}.ts" "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
    COMMENT "copying: ${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}.ts to ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts"
)
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm
    COMMAND Qt6::lupdate -no-obsolete "@${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt" -ts "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts" -I "${CMAKE_CURRENT_SOURCE_DIR}/src/veutil/inc"
    COMMAND Qt6::lrelease -idbased "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.ts" -qm "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm"
    DEPENDS ${BUILD_DIR_TS_FILES} "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
    COMMENT "Running lupdate and lrelease for ${PROJECT_NAME}_en.ts"
)
foreach(TsCode ${TS_CODES})
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
        COMMENT "copying: ${CMAKE_CURRENT_SOURCE_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts to ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm
        COMMAND Qt6::lupdate -no-obsolete "@${CMAKE_CURRENT_BINARY_DIR}/i18n/translation_sources.txt" -ts "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" -I "${CMAKE_CURRENT_SOURCE_DIR}/src/veutil/inc"
        COMMAND Qt6::lrelease -idbased "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.ts" -qm "${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm"
        DEPENDS ${BUILD_DIR_TS_FILES} "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
        COMMENT "Running lupdate and lrelease for ${PROJECT_NAME}_${TsCode}.ts"
    )
endforeach()

set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_en.qm" PROPERTIES
    QT_RESOURCE_ALIAS "${PROJECT_NAME}_en.qm"
    GENERATED TRUE
)
foreach(TsCode ${TS_CODES})
    set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/i18n/${PROJECT_NAME}_${TsCode}.qm" PROPERTIES
        QT_RESOURCE_ALIAS "${PROJECT_NAME}_${TsCode}.qm"
        GENERATED TRUE
    )
endforeach()
add_custom_target(${PROJECT_NAME}_qm_files_exist
    DEPENDS ${BUILD_DIR_QM_FILES}
)


if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )

    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/wasm/index.html")
    add_custom_target(WasmFiles SOURCES wasm/index.html)
    add_custom_command(
       TARGET ${PROJECT_NAME} POST_BUILD
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/wasm/index.html"
            "${CMAKE_CURRENT_BINARY_DIR}/venus-gui-v2.html"
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/images/victronenergy.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/victronenergy.svg"
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/images/victronenergy-light.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/victronenergy-light.svg"
       COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_CURRENT_SOURCE_DIR}/images/mockup.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/mockup.svg"
    )

elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    list(APPEND venusCompileFlags  ${UNIX_COMPILE_FLAGS})
    qt_add_executable(${PROJECT_NAME}
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
else()
    list(APPEND venusCompileFlags ${UNIX_COMPILE_FLAGS})
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
endif()

if ("${RUN_UNIT_TESTS}" STREQUAL "ON")
    add_custom_command(
         TARGET ${PROJECT_NAME}
         COMMENT "Run tests"
         POST_BUILD
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
         COMMAND ${CMAKE_CTEST_COMMAND} -V -C $<CONFIGURATION> --output-on-failures
    )
endif()

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES Main.qml
    IMPORTS Victron.VenusOS
)
if (${LOAD_QML_FROM_FILESYSTEM})
    set(thisModule ${PROJECT_NAME})
    qt_query_qml_module(${thisModule} QML_FILES module_qml_files QMLDIR module_qmldir)
    install(TARGETS ${thisModule}
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    install(FILES ${module_qml_files} ${module_qmldir} $<TARGET_FILE:${thisModule}> DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(FILES $<TARGET_FILE:${thisModule}> DESTINATION ${CMAKE_INSTALL_BINDIR} PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)

    add_custom_command(
        TARGET ${thisModule}
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()

qt_add_resources(${PROJECT_NAME} "${PROJECT_NAME}_large_resources"
    BIG_RESOURCES
    FILES
        fonts/Roboto-Regular.ttf
        images/acloads.svg
        images/alternator.svg
        images/breadcrumb_lhs.svg
        images/breadcrumb_rhs.svg
        images/icon_battery_24.svg
        images/icon_battery_charging_24.svg
        images/icon_battery_discharging_24.svg
        images/icon_connectivity_32.png
        images/icon_debug_32.png
        images/icon_devices_32.png
        images/icon_general_32.png
        images/icon_integration_32.png
        images/icon_smartswitch_off_32.svg
        images/icon_smartswitch_on_32.svg
        images/icon_system_32.png
        images/icon_vrm_32.png
        images/brief.svg
        images/cloud.svg
        images/consumption.svg
        images/dcloads.svg
        images/dropdown.svg
        images/electron.svg
        images/electron_arrow.svg
        images/ess.svg
        images/freshWater.svg
        images/key_navigation_highlight_dark.svg
        images/key_navigation_highlight_light.svg
        images/icon_black_water_24.svg
        images/icon_charging_generator.svg
        images/icon_charging_grid.svg
        images/icon_charging_renewables.svg
        images/icon_charging_shore.svg
        images/icon_CL_24.svg
        images/icon_fresh_water_24.svg
        images/icon_raw_water_24.svg
        images/icon_waste_water_24.svg
        images/icon_livewell_24.svg
        images/icon_fuel_24.svg
        images/icon_from_grid.svg
        images/icon_oil_24.svg
        images/icon_hydraulic_oil_24.svg
        images/icon_lng_24.svg
        images/icon_lpg_24.svg
        images/icon_open_link_32.svg
        images/icon_to_grid.svg
        images/fueltank.svg
        images/gauge_intro_5_matte_black.gif
        images/gauge_intro_5_matte_white.gif
        images/gauge_intro_7_matte_black.gif
        images/gauge_intro_7_matte_white.gif
        images/generator.svg
        images/grid.svg
        images/icon_simlocked_32.svg
        images/icon_warning_24.svg
        images/icon_alarm_48.svg
        images/icon_alarm_snooze_24.svg
        images/icon_autostart_24.svg
        images/icon_arrow_32.svg
        images/icon_back_32.svg
        images/icon_charging_station_24.svg
        images/icon_checkmark_48.svg
        images/icon_controls_off_32.svg
        images/icon_controls_on_32.svg
        images/icon_dc_24.svg
        images/icon_humidity_32.svg
        images/icon_input_24.svg
        images/icon_manualstart_24.svg
        images/icon_manualstart_timer_24.svg
        images/icon_minus.svg
        images/icon_plus.svg
        images/icon_plus_32.svg
        images/icon_refresh_32.svg
        images/icon_sidepanel_off_32.svg
        images/icon_sidepanel_on_32.svg
        images/icon_screen_sleep_32.svg
        images/icon_switch_24.svg
        images/icon_temp_32.svg
        images/information.svg
        images/inverter.svg
        images/inverter_charger.svg
        images/levels.svg
        images/notifications.svg
        images/notifications_subtract.svg
        images/overview.svg
        images/rain.svg
        images/scatteredcloud.svg
        images/settings.svg
        images/shore.svg
        images/solaryield.svg
        images/spinbox_arrow_up.svg
        images/splash-logo-icon.svg
        images/splash-logo-text.svg
        images/sunny.svg
        images/switch_indicator.png
        images/switches.svg
        images/icon_warning_32.svg
        images/icon_checkmark_32.svg
        images/icon_close_32.svg
        images/icon_info_32.svg
        images/icon_info_48.svg
        images/icon_WiFi_1_32.svg
        images/icon_WiFi_2_32.svg
        images/icon_WiFi_3_32.svg
        images/icon_WiFi_4_32.svg
        images/icon_WiFi_noconnection_32.svg
        images/welcome-brief.png
        images/welcome-controls.png
        images/welcome-dark.png
        images/welcome-landing.png
        images/welcome-more.png
        images/welcome-overview.png
        images/welcome-qrCode.png
        images/welcome-qrCode-light.png
        images/welcome-units.png
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

qt_add_resources(${PROJECT_NAME} "${PROJECT_NAME}_translations_resources"
    PREFIX "/i18n"
    BIG_RESOURCES
    FILES ${BUILD_DIR_QM_FILES}
)
add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_qm_files_exist)

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
    BoatPageComponentsplugin
    VictronGaugesplugin
    VictronMockplugin
    qzxing
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

# Parse theme json files and generate themeobject.h.
# Use DEPENDS to ensure script is only run when the script or theme json files have changed.
find_package(Python3 COMPONENTS Interpreter)
add_custom_command(
    COMMAND ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/tools/themeparser.py "${PROJECT_SOURCE_DIR}/themes/" "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
    OUTPUT "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
    DEPENDS "${PROJECT_SOURCE_DIR}/themes/animation" "${PROJECT_SOURCE_DIR}/themes/color" "${PROJECT_SOURCE_DIR}/themes/geometry" "${PROJECT_SOURCE_DIR}/themes/typography" ${PROJECT_SOURCE_DIR}/tools/themeparser.py
    COMMENT "Generating themeobjects.h"
)
add_custom_target(
    theme_parser ALL
    DEPENDS "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
)
add_dependencies(${PROJECT_NAME} theme_parser)
