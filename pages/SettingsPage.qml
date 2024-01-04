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
import Victron.Veutil
import net.connman

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
				//% "Remote Console"
				text: qsTrId("settings_remote_console"),
				page: "/pages/settings/PageSettingsRemoteConsole.qml"
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
				//% "VRM online portal"
				text: qsTrId("settings_vrm_online_portal"),
				page: "/pages/settings/PageSettingsLogger.qml"
			},
			{
				//% "ESS"
				text: systemType.value === "Hub-4" ? systemType.value : qsTrId("settings_ess"),
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
				//% "Ethernet"
				text: qsTrId("settings_ethernet"),
				page: "/pages/settings/PageSettingsTcpIp.qml"
			},
			{
				//% "Wi-Fi"
				text: qsTrId("settings_wifi"),
				page: accessPoint.isValid
					? "/pages/settings/PageSettingsWifiWithAccessPoint.qml"
					: "/pages/settings/PageSettingsWifi.qml"
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
				show: Connman.technologyList.indexOf("bluetooth") !== -1
			},
			{
				//% "Generator start/stop"
				text: qsTrId("settings_generator_start_stop"),
				page: "/pages/settings/PageRelayGenerator.qml"
			},
			{
				//% "Tank pump"
				text: qsTrId("settings_tank_pump"),
				page: "/pages/settings/PageSettingsTankPump.qml"
			},
			{
				text: CommonWords.relay,
				page: "/pages/settings/PageSettingsRelay.qml",
				visible: relay0.isValid
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
				visible: signalK.isValid || nodeRed.isValid
			},
			{
				//% "VRM Device Instances"
				text: qsTrId("settings_vrm_device_instances"),
				page: "/pages/settings/PageVrmDeviceInstances.qml",
			},
			{
				text: "Debug",
				page: "/pages/settings/debug/PageDebug.qml",
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

	VeQuickItem {
		id: systemType
		uid: Global.system.serviceUid + "/SystemType"
	}

	VeQuickItem {
		id: accessPoint
		uid: Global.venusPlatform.serviceUid + "/Services/AccessPoint/Enabled"
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
}
