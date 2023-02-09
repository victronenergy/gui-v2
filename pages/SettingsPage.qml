/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import net.connman 0.1

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: [
			{
				//% "Bluetooth"
				text: qsTrId("settings_bluetooth"),
				page: "/pages/settings/PageSettingsBluetooth.qml",
				show: Connman.technologyList.indexOf("bluetooth") !== -1
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
			//% "PV inverters"
			{
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
				page: accessPoint.valid
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
				//% "Relay"
				text: qsTrId("settings_relay"),
				page: "/pages/settings/PageSettingsRelay.qml",
				visible: relay0.valid
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
				visible: signalK.valid || nodeRed.valid
			},
			{
				text: "Debug",
				page: "/pages/settings/debug/PageDebug.qml",
				showAccessLevel: VenusOS.User_AccessType_Service
			},
		]

		delegate: SettingsListNavigationItem {
			text: modelData.text
			showAccessLevel: modelData.showAccessLevel || VenusOS.User_AccessType_User
			visible: defaultVisible && (modelData.visible === undefined || modelData.visible === true)
			onClicked: {
				Global.pageManager.pushPage(modelData.page, {"title": modelData.text})
			}
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
