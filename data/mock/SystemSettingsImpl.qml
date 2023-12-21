/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function setMockSettingValue(settingId, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.settings/Settings/" + settingId, value)
	}

	function setMockPumpValue(settingId, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.pump.startstop0/" + settingId, value)
	}

	function setMockSystemValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.system/" + key, value)
	}

	function setMockGenerator0Value(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.settings/Settings/Generator0/" + key, value)
	}

	function setMockGeneratorStartStopValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.generator.startstop0/" + key, value)
	}

	function setMockModbusTcpValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.modbustcp/" + key, value)
	}

	function setMockPlatformValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.platform/" + key, value)
	}

	function setMockVecanValue(gateway, key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.vecan." + gateway + "/" + key, value)
	}

	function setMockModemValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.modem" + key, value)
	}

	function setMockModemSetting(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.settings/Settings/Modem" + key, value)
	}

	function setMockFroniusValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.fronius" + "/" + key, value)
	}

	function setMockGpsValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.gps" + key, value)
	}

	function setMockSolarChargerValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.solarcharger.ttyUSB1" + key, value)
	}

	Component.onCompleted: {
		// Other system settings
		setMockSettingValue("System/VncInternet", 1)
		setMockSettingValue("System/VncLocal", 1)
		setMockSettingValue("SystemSetup/AcInput1", 2)
		setMockSettingValue("SystemSetup/AcInput2", 3)
		setMockSettingValue("Gui/DemoMode", 1)

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

		setMockSystemValue("SystemType", "ESS")
		setMockSettingValue("CGwacs/AcPowerSetPoint", 50)
		setMockSettingValue("CGwacs/BatteryLife/DischargedTime", 0)
		setMockSettingValue("CGwacs/BatteryLife/Flags", 0)
		setMockSettingValue("CGwacs/BatteryLife/MinimumSocLimit", 10)
		setMockSettingValue("CGwacs/BatteryLife/Schedule/Charge/0/AllowDischarge", 1)
		setMockSettingValue("CGwacs/BatteryLife/Schedule/Charge/0/Day", -1)
		setMockSettingValue("CGwacs/BatteryLife/Schedule/Charge/0/Duration", -1)
		setMockSettingValue("CGwacs/BatteryLife/Schedule/Charge/0/Soc", 90)
		setMockSettingValue("CGwacs/BatteryLife/Schedule/Charge/0/Start", 0)
		setMockSettingValue("CGwacs/BatteryLife/SocLimit", 10)
		setMockSettingValue("CGwacs/BatteryLife/State", 4)
		setMockSettingValue("CGwacs/Hub4Mode", 2)
		setMockSettingValue("CGwacs/MaxChargePower", -1)
		setMockSettingValue("CGwacs/MaxDischargePower", -1)
		setMockSettingValue("CGwacs/RunWithoutGridMeter", 0)
		setMockSettingValue("CGwacs/PreventFeedback", 0)

		setMockSettingValue("CGwacs/DeviceIds", "1,2,3,4,5,6")
		setMockSettingValue("Devices/cgwacs_1/CustomName", "pvinverter customname1")
		setMockSettingValue("Devices/cgwacs_2/CustomName", "grid customname2")
		setMockSettingValue("Devices/cgwacs_3/CustomName", "genset customname3")
		setMockSettingValue("Devices/cgwacs_4/CustomName", "acload customname4")
		setMockSettingValue("Devices/cgwacs_5/CustomName", "pvinverter customname5")
		setMockSettingValue("Devices/cgwacs_6/CustomName", "grid customname6")
		setMockSettingValue("Devices/cgwacs_1/ServiceType", "pvinverter")
		setMockSettingValue("Devices/cgwacs_2/ServiceType", "grid")
		setMockSettingValue("Devices/cgwacs_3/ServiceType", "genset")
		setMockSettingValue("Devices/cgwacs_4/ServiceType", "acload")
		setMockSettingValue("Devices/cgwacs_5/ServiceType", "pvinverter")
		setMockSettingValue("Devices/cgwacs_6/ServiceType", "grid")
		setMockSettingValue("Devices/cgwacs_1/L2/ServiceType", "pvinverter")
		setMockSettingValue("Devices/cgwacs_2/L2/ServiceType", "grid")
		setMockSettingValue("Devices/cgwacs_3/L2/ServiceType", "genset")
		setMockSettingValue("Devices/cgwacs_4/L2/ServiceType", "acload")
		setMockSettingValue("Devices/cgwacs_1/ClassAndVrmInstance", "pvinverter:1")
		setMockSettingValue("Devices/cgwacs_2/ClassAndVrmInstance", "grid:1")
		setMockSettingValue("Devices/cgwacs_3/ClassAndVrmInstance", "genset:1")
		setMockSettingValue("Devices/cgwacs_4/ClassAndVrmInstance", "acload:1")
		setMockSettingValue("Devices/cgwacs_1/Position", 0)
		setMockSettingValue("Devices/cgwacs_2/Position", 1)
		setMockSettingValue("Devices/cgwacs_3/Position", 2)
		setMockSettingValue("Devices/cgwacs_4/Position", 0)
		setMockSettingValue("Devices/cgwacs_5/Position", 1)
		setMockSettingValue("Devices/cgwacs_6/Position", 2)
		setMockSettingValue("Devices/cgwacs_1/SupportMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_2/SupportMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_3/SupportMultiphase", 0)
		setMockSettingValue("Devices/cgwacs_4/SupportMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_5/SupportMultiphase", 0)
		setMockSettingValue("Devices/cgwacs_6/SupportMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_1/IsMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_2/IsMultiphase", 0)
		setMockSettingValue("Devices/cgwacs_3/IsMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_4/IsMultiphase", 0)
		setMockSettingValue("Devices/cgwacs_5/IsMultiphase", 1)
		setMockSettingValue("Devices/cgwacs_6/IsMultiphase", 0)
		setMockSettingValue("Devices/cgwacs_1_S/Enabled", 0)
		setMockSettingValue("Devices/cgwacs_2_S/Enabled", 1)
		setMockSettingValue("Devices/cgwacs_3_S/Enabled", 0)
		setMockSettingValue("Devices/cgwacs_4_S/Enabled", 1)
		setMockSettingValue("Devices/cgwacs_5_S/Enabled", 0)
		setMockSettingValue("Devices/cgwacs_6_S/Enabled", 1)
		setMockSettingValue("Devices/cgwacs_1_S/Position", 0)
		setMockSettingValue("Devices/cgwacs_2_S/Position", 1)
		setMockSettingValue("Devices/cgwacs_3_S/Position", 2)
		setMockSettingValue("Devices/cgwacs_4_S/Position", 0)
		setMockSettingValue("Devices/cgwacs_5_S/Position", 1)
		setMockSettingValue("Devices/cgwacs_6_S/Position", 2)

		setMockPumpValue("State", 0)
		setMockSettingValue("Pump0/Mode", 2)
		setMockPumpValue("AvailableTankServices", '{"notanksensor": "No tank sensor"}')
		setMockSettingValue("Pump0/StartValue", 50)
		setMockSettingValue("Pump0/StopValue", 80)

		setMockGenerator0Value('AccumulatedTotal', 3780849)
		setMockGenerator0Value('AutoStartEnabled', 1)
		setMockGenerator0Value('AccumulatedDaily', '{"1667347200": 60, "1667433600": 120, "1667520000": 1800}')
		setMockGenerator0Value('BatteryService', "default")
		setMockGenerator0Value('OnLossCommunication', 2)
		setMockGenerator0Value('ServiceInterval', 159984000)
		setMockGenerator0Value('Soc', 1)
		setMockGenerator0Value('StopWhenAc1Available', 0)
		setMockGenerator0Value('WarmUpTime', 600)
		setMockGenerator0Value('CoolDownTime', 1200)

		setMockSettingValue("Services/Modbus", 0)
		setMockModbusTcpValue("Services/Count", 2)
		setMockModbusTcpValue("Services/0/ServiceName", "com.victronenergy.battery.ttyUSB0")
		setMockModbusTcpValue("Services/0/UnitId", 288)
		setMockModbusTcpValue("Services/1/ServiceName", "com.victronenergy.solarcharger.ttyUSB1")
		setMockModbusTcpValue("Services/1/UnitId", 289)

		setMockSettingValue("Services/MqttLocal", 0)
		setMockSettingValue("Services/MqttLocalInsecure", 0)
		setMockPlatformValue("CanBus/Interfaces", [{'config': 1, 'interface': 'can1', 'name': 'BMS-Can port'}, {'config': 0, 'interface': 'can0', 'name': 'VE.Can port'}])
		setMockSettingValue("Canbus/can0/Profile", 1)
		setMockSettingValue("Canbus/can1/Profile", 3)
		setMockSettingValue("Vecan/can0/N2kGatewayEnabled", 0)
		setMockSettingValue("Vecan/can0/VenusUniqueId", 1)

		setMockVecanValue("can0", "Devices/0/ModelName", "BlueSolar Charger MPTT 150/70")
		setMockVecanValue("can0", "Devices/0/CustomName", "Some custom name")
		setMockVecanValue("can0", "Devices/0/N2kUniqueNumber", 15965)
		setMockVecanValue("can0", "Devices/0/DeviceInstance", 255)
		setMockVecanValue("can0", "Devices/0/Manufacturer", "Widgets Inc")
		setMockVecanValue("can0", "Devices/0/Nad", "161")
		setMockVecanValue("can0", "Devices/0/FirmwareVersion", "34.2.1")
		setMockVecanValue("can0", "Devices/0/Serial", "12345")

		setMockPlatformValue("CanBus/Interface/can0/Statistics", '[{"ifindex":3,"ifname":"can0","flags":["NOARP","UP","LOWER_UP","ECHO"],"mtu":16,"qdisc":"pfifo_fast","operstate":"UP","linkmode":"DEFAULT","group":"default","txqlen":100,"link_type":"can","promiscuity":0,"min_mtu":0,"max_mtu":0,"linkinfo":{"info_kind":"can","info_data":{"state":"ERROR-PASSIVE","berr_counter":{"tx":0,"rx":135},"restart_ms":100,"bittiming":{"bitrate":250000,"sample_point":0.875,"tq":250,"prop_seg":6,"phase_seg1":7,"phase_seg2":2,"sjw":1},"bittiming_const":{"name":"sun4i_can","tseg1":{"min":1,"max":16},"tseg2":{"min":1,"max":8},"sjw":{"min":1,"max":4},"brp":{"min":1,"max":64},"brp_inc":1},"clock":24000000},"info_xstats":{"restarts":0,"bus_error":2,"arbitration_lost":0,"error_warning":1,"error_passive":1,"bus_off":0}},"num_tx_queues":1,"num_rx_queues":1,"gso_max_size":65536,"gso_max_segs":65535,"stats64":{"rx":{"bytes":16,"packets":2,"errors":2,"dropped":0,"over_errors":0,"multicast":0},"tx":{"bytes":0,"packets":0,"errors":0,"dropped":0,"carrier_errors":0,"collisions":0}}}]')

		setMockSettingValue("Relay/Function", 1)
		setMockSettingValue("Relay/Polarity", 0)
		setMockSettingValue("Relay/1/Function", 4) // Temperature
		setMockSettingValue("Relay/1/Polarity", 0)
		setMockSystemValue("Relay/0/State", 1)
		setMockSystemValue("Relay/1/State", 1)

		// GSM modem
		setMockModemValue("/Connected", 1)
		setMockModemValue("/IMEI", "863427041986440")
		setMockModemValue("/IP", "1.2.3.4")
		setMockModemValue("/Model", "SIMCOM_SIM7600SA")
		setMockModemValue("/NetworkName", "Telstra")
		setMockModemValue("/NetworkType", "LTE")
		setMockModemValue("/RegStatus", 1)
		setMockModemValue("/Roaming", 1)
		setMockModemValue("/SignalStrength", 17)
		setMockModemValue("/SimStatus", 1000)
		setMockModemSetting("/APN", "")
		setMockModemSetting("/Connected", 1)
		setMockModemSetting("/PIN", "1234")
		setMockModemSetting("/Password", "tinyurl.com/msvnbd3r")
		setMockModemSetting("/RoamingPermitted", 0)
		setMockModemSetting("/User", "Rick")

		setMockSettingValue("Services/Bluetooth", 1)
		setMockSettingValue("Ble/Service/Pincode", "12345")

		// Fronius PV Inverter settings
		setMockSettingValue("Fronius/AutoScan", 0)
		setMockSettingValue("Fronius/IPAddresses", "2.2.2.2,2.2.2.3")
		setMockSettingValue("Fronius/InverterIds", "Inverter1,Inverter2")
		setMockSettingValue("Fronius/Inverters/Inverter1/CustomName", "customName1")
		setMockSettingValue("Fronius/Inverters/Inverter1/IsActive", 1)
		setMockSettingValue("Fronius/Inverters/Inverter1/Phase", 1)
		setMockSettingValue("Fronius/Inverters/Inverter1/Position", 0)
		setMockSettingValue("Fronius/Inverters/Inverter1/SerialNumber", 1234)
		setMockSettingValue("Fronius/Inverters/Inverter2/CustomName", "customName2")
		setMockSettingValue("Fronius/Inverters/Inverter2/IsActive", 1)
		setMockSettingValue("Fronius/Inverters/Inverter2/Phase", 1)
		setMockSettingValue("Fronius/Inverters/Inverter2/Position", 1)
		setMockSettingValue("Fronius/Inverters/Inverter2/SerialNumber", 5678)
		setMockSettingValue("Fronius/KnownIPAddresses", "1.2.3.4,1.2.3.5")
		setMockSettingValue("Fronius/PortNumber", 81)
		setMockFroniusValue("AutoDetect", 0)
		setMockFroniusValue("ScanProgress", 0)

		// GPS settings
		setMockGpsValue("/Position/Latitude", -25.734968)
		setMockGpsValue("/Position/Longitude", 134.489563)
		setMockGpsValue("/Speed", 100)
		setMockGpsValue("/Course", 100)
		setMockGpsValue("/Fix", 1)
		setMockGpsValue("/NrOfSatellites", 1)
		setMockGpsValue("/Altitude", 10)

		// Large features
		setMockPlatformValue("Services/SignalK/Enabled", 1)
		setMockPlatformValue("Services/NodeRed/Mode", 1)

		// Solar charger
		setMockSolarChargerValue("/Link/NetworkStatus", 1)
		setMockSolarChargerValue("/Settings/BmsPresent", 1)
		setMockSolarChargerValue("/Alarms/LowVoltage", VenusOS.Alarm_Level_Warning)
		setMockSolarChargerValue("/Alarms/HighVoltage", VenusOS.Alarm_Level_OK)

		setMockSystemValue("/SystemType", "ESS")

		ClockTime.setClockTime(new Date().getTime() / 1000)
	}
}
