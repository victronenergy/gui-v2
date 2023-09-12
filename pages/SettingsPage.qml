/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

/*
 * These settings are regularly brought up to date with the settings from gui-v1.
 * Currently up to date with gui-v1 v5.6.6.
 */

import QtQuick
import Victron.VenusOS
import net.connman 0.1

Page {
	id: root

	// for mock simulator
	property alias settingsListView: settingsListView

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	GradientListView {
		id: settingsListView

		model: [
			{
				//% "Device List"
				text: qsTrId("settings_device_list"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/devicelist/DeviceListPage.qml",
			},
			{
				//% "General"
				text: qsTrId("settings_general"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsGeneral.qml"
			},
			{
				//% "Firmware"
				text: qsTrId("settings_firmware"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsFirmware.qml"
			},
			{
				//% "Date & Time"
				text: qsTrId("settings_date_and_time"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageTzInfo.qml"
			},
			{
				//% "Remote Console"
				text: qsTrId("settings_remote_console"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsRemoteConsole.qml"
			},
			{
				//% "System setup"
				text: qsTrId("settings_system_setup"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsSystem.qml"
			},
			{
				//% "DVCC"
				text: qsTrId("settings_system_dvcc"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsDvcc.qml"
			},
			{
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsDisplay.qml"
			},
			{
				//% "VRM online portal"
				text: qsTrId("settings_vrm_online_portal"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsLogger.qml"
			},
			{
				//% "ESS"
				text: systemType.value === "Hub-4" ? systemType.value : qsTrId("settings_ess"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsHub4.qml"
			},
			{
				//% "Energy meters"
				text: qsTrId("settings_energy_meters"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsCGwacsOverview.qml"
			},
			{
				//% "PV inverters"
				text: qsTrId("settings_pv_inverters"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsFronius.qml"
			},
			{
				//% "Ethernet"
				text: qsTrId("settings_ethernet"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsTcpIp.qml"
			},
			{
				//% "Wi-Fi"
				text: qsTrId("settings_wifi"),
				page: accessPoint.valid
					? "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsWifiWithAccessPoint.qml"
					: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsWifi.qml"
			},
			{
				//% "GSM modem"
				text: qsTrId("settings_gsm_modem"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsGsm.qml"
			},
			{
				//% "GPS"
				text: qsTrId("settings_gps"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsGpsList.qml"
			},
			{
				//% "Bluetooth"
				text: qsTrId("settings_bluetooth"),
				page: "/pages/settings/PageSettingsBluetooth.qml",
				show: Connman.technologyList.indexOf("bluetooth") !== -1
			},
			{
				//% "Generator start/stop"
				text: qsTrId("settings_generator_start_stop"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageRelayGenerator.qml"
			},
			{
				//% "Tank pump"
				text: qsTrId("settings_tank_pump"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsTankPump.qml"
			},
			{
				text: CommonWords.relay,
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsRelay.qml",
				visible: relay0.valid
			},
			{
				//% "Services"
				text: qsTrId("settings_services"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsServices.qml"
			},
			{
				//% "I/O"
				text: qsTrId("settings_io"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsIo.qml"
			},
			{
				//% "Venus OS Large features"
				text: qsTrId("settings_venus_os_large_features"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsLarge.qml",
				visible: signalK.valid || nodeRed.valid
			},
			{
				//% "VRM Device Instances"
				text: qsTrId("settings_vrm_device_instances"),
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/PageVrmDeviceInstances.qml",
			},
			{
				text: "Debug",
				page: "qrc:/qt/qml/Victron/VenusOS/pages/settings/debug/PageDebug.qml",
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			},
		]

		delegate: ListNavigationItem {
			text: modelData.text
			showAccessLevel: modelData.showAccessLevel || VenusOS.User_AccessType_User
			visible: defaultVisible && (modelData.visible === undefined || modelData.visible === true)
			onClicked: Global.pageManager.pushPage(modelData.page, {"title": modelData.text})
		}
	}

	DataPoint {
		id: systemType
		source: "com.victronenergy.system/SystemType"
	}

	DataPoint {
		id: accessPoint
		source: "com.victronenergy.platform/Services/AccessPoint/Enabled"
	}

	DataPoint {
		id: relay0
		source: "com.victronenergy.system/Relay/0/State"
	}

	DataPoint {
		id: signalK
		source: "com.victronenergy.platform/Services/SignalK/Enabled"
	}

	DataPoint {
		id: nodeRed
		source: "com.victronenergy.platform/Services/NodeRed/Mode"
	}
}
