/*
** Copyright (C) 2021 Victron Energy B.V.
*
* These settings are regularly brought up to date with the settings from gui-v1.
* Currently up to date with gui-v1 v5.6.6.
*/

import QtQuick
import Victron.VenusOS 2.0
import net.connman 0.1

Page {
	id: root

	// for mock simulator
	property alias settingsListView: settingsListView

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	Component {
		id: pageSettingsBluetooth

		PageSettingsBluetooth { }
	}

	Component {
		id: pageSettingsGeneral

		PageSettingsGeneral { }
	}

	Component {
		id: pageSettingsFirmware

		PageSettingsFirmware { }
	}

	Component {
		id: pageTzInfo

		PageTzInfo { }
	}

	Component {
		id: pageSettingsRemoteConsole

		PageSettingsRemoteConsole { }
	}

	Component {
		id: pageSettingsSystem

		PageSettingsSystem { }
	}

	Component {
		id: pageSettingsDvcc

		PageSettingsDvcc { }
	}

	Component {
		id: pageSettingsDisplay

		PageSettingsDisplay { }
	}

	Component {
		id: pageSettingsLogger

		PageSettingsLogger { }
	}

	Component {
		id: pageSettingsHub4

		PageSettingsHub4 { }
	}

	Component {
		id: pageSettingsCGwacsOverview

		PageSettingsCGwacsOverview { }
	}

	Component {
		id: pageSettingsFronius

		PageSettingsFronius{ }
	}

	Component {
		id: pageSettingsTcpIp

		PageSettingsTcpIp { }
	}

	Component {
		id: pageSettingsWifi

		PageSettingsWifi { }
	}

	Component {
		id: pageSettingsGsm

		PageSettingsGsm { }
	}

	Component {
		id: pageSettingsGpsList

		PageSettingsGpsList { }
	}

	Component {
		id: pageRelayGenerator

		PageRelayGenerator { }
	}

	Component {
		id: pageSettingsTankPump

		PageSettingsTankPump { }
	}

	Component {
		id: pageSettingsRelay

		PageSettingsRelay { }
	}

	Component {
		id: pageSettingsServices

		PageSettingsServices { }
	}

	Component {
		id: pageSettingsIo

		PageSettingsIo { }
	}

	Component {
		id: pageSettingsLarge

		PageSettingsLarge { }
	}

	Component {
		id: pageVrmDeviceInstances

		PageVrmDeviceInstances { }
	}

	Component {
		id: pageDebug

		PageDebug { }
	}

	Component {
		id: pageSettingsWifiWithAccessPoint

		PageSettingsWifiWithAccessPoint { }
	}

	GradientListView {
		id: settingsListView

		model: [
			{
				//% "Bluetooth"
				text: qsTrId("settings_bluetooth"),
				page: pageSettingsBluetooth,
				show: Connman.technologyList.indexOf("bluetooth") !== -1
			},
			{
				//% "General"
				text: qsTrId("settings_general"),
				page: pageSettingsGeneral
			},
			{
				//% "Firmware"
				text: qsTrId("settings_firmware"),
				page: pageSettingsFirmware
			},
			{
				//% "Date & Time"
				text: qsTrId("settings_date_and_time"),
				page: pageTzInfo
			},
			{
				//% "Remote Console"
				text: qsTrId("settings_remote_console"),
				page: pageSettingsRemoteConsole
			},
			{
				//% "System setup"
				text: qsTrId("settings_system_setup"),
				page: pageSettingsSystem
			},
			{
				//% "DVCC"
				text: qsTrId("settings_system_dvcc"),
				page: pageSettingsDvcc
			},
			{
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
				page: pageSettingsDisplay
			},
			{
				//% "VRM online portal"
				text: qsTrId("settings_vrm_online_portal"),
				page: pageSettingsLogger
			},
			{
				//% "ESS"
				text: systemType.value === "Hub-4" ? systemType.value : qsTrId("settings_ess"),
				page: pageSettingsHub4
			},
			{
				//% "Energy meters"
				text: qsTrId("settings_energy_meters"),
				page: pageSettingsCGwacsOverview
			},
			//% "PV inverters"
			{
				text: qsTrId("settings_pv_inverters"),
				page: pageSettingsFronius
			},
			{
				//% "Ethernet"
				text: qsTrId("settings_ethernet"),
				page: pageSettingsTcpIp
			},
			{
				//% "Wi-Fi"
				text: qsTrId("settings_wifi"),
				page: accessPoint.valid
					? pageSettingsWifiWithAccessPoint
					: pageSettingsWifi
			},
			{
				//% "GSM modem"
				text: qsTrId("settings_gsm_modem"),
				page: pageSettingsGsm
			},
			{
				//% "GPS"
				text: qsTrId("settings_gps"),
				page: pageSettingsGpsList
			},
			{
				//% "Generator start/stop"
				text: qsTrId("settings_generator_start_stop"),
				page: pageRelayGenerator
			},
			{
				//% "Tank pump"
				text: qsTrId("settings_tank_pump"),
				page: pageSettingsTankPump
			},
			{
				text: CommonWords.relay,
				page: pageSettingsRelay,
				visible: relay0.valid
			},
			{
				//% "Services"
				text: qsTrId("settings_services"),
				page: pageSettingsServices
			},
			{
				//% "I/O"
				text: qsTrId("settings_io"),
				page: pageSettingsIo
			},
			{
				//% "Venus OS Large features"
				text: qsTrId("settings_venus_os_large_features"),
				page: pageSettingsLarge,
				visible: signalK.valid || nodeRed.valid
			},
			{
				//% "VRM Device Instances"
				text: qsTrId("settings_vrm_device_instances"),
				page: pageVrmDeviceInstances
			},
			{
				text: "Debug",
				page: pageDebug,
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
