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

SwipeViewPage {
	id: root

	//% "Settings"
	navButtonText: qsTrId("nav_settings")
	navButtonIcon: "qrc:/images/settings.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/SettingsPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	GradientListView {
		id: settingsListView

		clip: true

		model: [
			{
				//% "Device list"
				text: qsTrId("settings_device_list"),
				page: "/pages/settings/devicelist/DeviceListPage.qml",
			},
			{
				//% "General"
				text: qsTrId("settings_general"),
				page: "/pages/settings/PageSettingsGeneral.qml"
			},
			{
				//% "Firmware"
				text: qsTrId("settings_firmware"),
				page: "/pages/settings/PageSettingsFirmware.qml"
			},
			{
				//% "Date & Time"
				text: qsTrId("settings_date_and_time"),
				page: "/pages/settings/PageTzInfo.qml"
			},
			{
				//% "System setup"
				text: qsTrId("settings_system_setup"),
				page: "/pages/settings/PageSettingsSystem.qml"
			},
			{
				//% "DVCC"
				text: qsTrId("settings_system_dvcc"),
				page: "/pages/settings/PageSettingsDvcc.qml"
			},
			{
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
				page: "/pages/settings/PageSettingsDisplay.qml"
			},
			{
				//% "VRM Portal mode"
				text: qsTrId("settings_vrm_portal_mode"),
				page: "/pages/settings/PageSettingsLogger.qml"
			},
			{
				text: systemType.value === "Hub-4" ? systemType.value : CommonWords.ess,
				page: "/pages/settings/PageSettingsHub4.qml"
			},
			{
				//% "Energy meters"
				text: qsTrId("settings_energy_meters"),
				page: "/pages/settings/PageSettingsCGwacsOverview.qml"
			},
			{
				//% "PV inverters"
				text: qsTrId("settings_pv_inverters"),
				page: "/pages/settings/PageSettingsFronius.qml"
			},
			{
				//% "Modbus TCP/UDP devices"
				text: qsTrId("settings_modbus_tcp_udp_devices"),
				page: "/pages/settings/PageSettingsModbus.qml"
			},
			{
				//% "Ethernet"
				text: qsTrId("settings_ethernet"),
				page: "/pages/settings/PageSettingsTcpIp.qml"
			},
			{
				//% "Wi-Fi"
				text: qsTrId("settings_wifi"),
				page: "/pages/settings/PageSettingsWifi.qml"
			},
			{
				//% "GSM modem"
				text: qsTrId("settings_gsm_modem"),
				page: "/pages/settings/PageSettingsGsm.qml"
			},
			{
				//% "GPS"
				text: qsTrId("settings_gps"),
				page: "/pages/settings/PageSettingsGpsList.qml"
			},
			{
				//% "Bluetooth"
				text: qsTrId("settings_bluetooth"),
				page: "/pages/settings/PageSettingsBluetooth.qml",
				show: hasBluetoothSupport.value
			},
			{
				//% "Generator start/stop"
				text: qsTrId("settings_generator_start_stop"),
				page: "/pages/settings/PageRelayGenerator.qml",
				allowed: relay0.isValid
			},
			{
				//% "Tank pump"
				text: qsTrId("settings_tank_pump"),
				page: "/pages/settings/PageSettingsTankPump.qml"
			},
			{
				text: CommonWords.relay,
				page: "/pages/settings/PageSettingsRelay.qml",
				allowed: relay0.isValid
			},
			{
				//% "Services"
				text: qsTrId("settings_services"),
				page: "/pages/settings/PageSettingsServices.qml"
			},
			{
				//% "I/O"
				text: qsTrId("settings_io"),
				page: "/pages/settings/PageSettingsIo.qml"
			},
			{
				//% "Venus OS Large features"
				text: qsTrId("settings_venus_os_large_features"),
				page: "/pages/settings/PageSettingsLarge.qml",
				allowed: signalK.isValid || nodeRed.isValid
			},
			{
				//% "VRM device instances"
				text: qsTrId("settings_vrm_device_instances"),
				page: "/pages/settings/PageVrmDeviceInstances.qml",
			},
			{
				text: "Debug",
				page: "/pages/settings/debug/PageDebug.qml",
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			},
		]

		delegate: ListNavigation {
			text: modelData.text
			showAccessLevel: modelData.showAccessLevel || VenusOS.User_AccessType_User
			allowed: defaultAllowed && (modelData.allowed === undefined || modelData.allowed === true)
			onClicked: Global.pageManager.pushPage(modelData.page, {"title": modelData.text})
		}
	}

	VeQuickItem {
		id: systemType
		uid: Global.system.serviceUid + "/SystemType"
	}

	VeQuickItem {
		id: relay0
		uid: Global.system.serviceUid + "/Relay/0/State"
	}

	VeQuickItem {
		id: signalK
		uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
	}

	VeQuickItem {
		id: nodeRed
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
	}

	VeQuickItem {
		id: hasBluetoothSupport
		uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
	}
}
