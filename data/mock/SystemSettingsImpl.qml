/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function setMockSettingValue(settingId, value) {
		Global.demoManager.mockDataValues["com.victronenergy.settings/Settings/" + settingId] = value
	}

	function setMockSystemValue(key, value) {
		Global.demoManager.mockDataValues["com.victronenergy.system/" + key] = value
	}

	Component.onCompleted: {
		// Settings that are converted for convenient UI access
		Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_Service)
		Global.systemSettings.demoMode.setValue(VenusOS.SystemSettings_DemoModeActive)
		Global.systemSettings.colorScheme.setValue(Theme.Dark)
		Global.systemSettings.energyUnit.setValue(VenusOS.Units_Energy_Watt)
		Global.systemSettings.temperatureUnit.setValue(VenusOS.Units_Temperature_Celsius)
		Global.systemSettings.volumeUnit.setValue(VenusOS.Units_Volume_CubicMeter)
		Global.systemSettings.briefView.showPercentages.setValue(false)

		// Other system settings
		setMockSettingValue("System/VncInternet", 1)
		setMockSettingValue("System/VncLocal", 1)
		setMockSettingValue("SystemSetup/AcInput1", 2)
		setMockSettingValue("SystemSetup/AcInput2", 3)

		setMockSystemValue("AvailableBatteryServices", '{"default": "Automatic", "nobattery": "No battery monitor", "com.victronenergy.vebus/257": "Quattro 24/3000/70-2x50 on VE.Bus", "com.victronenergy.battery/0": "Lynx Smart BMS 500 on VE.Can"}')
		setMockSystemValue("AutoSelectedBatteryService", "Lynx Smart BMS 500 on VE.Can")
		setMockSystemValue("AvailableBatteries", '{"com.victronenergy.battery/0": {"name": "Lynx Smart BMS HQ21302VUDQ", "channel": null, "type": "battery"}, "com.victronenergy.vebus/257": {"name": "Quattro 24/3000/70-2x50", "channel": null, "type": "vebus"}}')
		setMockSystemValue("ActiveBatteryService", "com.victronenergy.battery/0")
		setMockSettingValue("SystemSetup/Batteries/Configuration/com_victronenergy_battery/0/Enabled", 1)
		setMockSettingValue("SystemSetup/Batteries/Configuration/com_victronenergy_battery/0/Name", "My battery")
		setMockSettingValue("SystemSetup/Batteries/Configuration/com_victronenergy_vebus/257/Enabled", 1)
		setMockSettingValue("SystemSetup/Batteries/Configuration/com_victronenergy_vebus/257/Name", "")
		setMockSettingValue("SystemSetup/BatteryService", "default")
		setMockSettingValue("Alarm/System/GridLost", 1)

		setMockSettingValue("System/TimeZone", "Europe/Berlin")

		setMockSettingValue("Services/Bol", 1)
		setMockSettingValue("SystemSetup/MaxChargeCurrent", -1)
		setMockSettingValue("SystemSetup/MaxChargeVoltage", 0)
		setMockSettingValue("SystemSetup/SharedVoltageSense", 3)
		setMockSettingValue("SystemSetup/TemperatureService", "default")
		setMockSystemValue("AvailableTemperatureServices", '{"com.victronenergy.vebus/257/Dc/0/Temperature": "Quattro 24/3000/70-2x50 on VE.Bus","default": "Automatic","nosensor": "No sensor"}')
		setMockSystemValue("AutoSelectedTemperatureService", "-")
		setMockSettingValue("SystemSetup/SharedTemperatureSense", 2)
		setMockSystemValue("Control/BatteryCurrentSense", 0)
	}

	property Connections briefSettingsConn: Connections {
		target: Global.systemSettings.briefView

		function onSetGaugeRequested(index, value) {
			Global.systemSettings.briefView.setGauge(index, value)
		}
	}
}
