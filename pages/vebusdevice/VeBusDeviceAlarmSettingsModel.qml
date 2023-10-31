/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

ListModel {
	readonly property var displayTexts: [
		CommonWords.low_battery_voltage,
		CommonWords.high_temperature,
		CommonWords.inverter_overload,
		//% "High DC ripple"
		qsTrId("vebus_device_high_dc_ripple"),
		//% "High DC voltage"
		qsTrId("vebus_device_high_dc_voltage"),
		//% "High DC current"
		qsTrId("vebus_device_high_dc_current"),
		//% "Temperature sense error"
		qsTrId("vebus_device_temperature_sense_error"),
		//% "Voltage sense error"
		qsTrId("vebus_device_voltage_sense_error"),
		CommonWords.vebus_error
	]

	ListElement {pathSuffix: "/LowBattery";				multiPhaseOnly: false}
	ListElement {pathSuffix: "/HighTemperature";		multiPhaseOnly: false}
	ListElement {pathSuffix: "/InverterOverload";		multiPhaseOnly: false}
	ListElement {pathSuffix: "/HighDcRipple";			multiPhaseOnly: false}
	ListElement {pathSuffix: "/HighDcVoltage";			multiPhaseOnly: false}
	ListElement {pathSuffix: "/HighDcCurrent";			multiPhaseOnly: false}
	ListElement {pathSuffix: "/TemperatureSenseError";	multiPhaseOnly: true}
	ListElement {pathSuffix: "/VoltageSenseError";		multiPhaseOnly: true}
	ListElement {pathSuffix: "/VeBusError";				multiPhaseOnly: false}
}
