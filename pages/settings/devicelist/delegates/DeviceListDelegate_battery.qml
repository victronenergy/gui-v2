/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property bool isParallelBms: numberOfBmses.isValid

	readonly property var _pendingModel: [
		{ unit: VenusOS.Units_None, value: CommonWords.pending },
		{ unit: VenusOS.Units_Volt_DC, value: voltage.value },
		{ unit: VenusOS.Units_Percentage, value: soc.value },
	]

	readonly property var _defaultModel: [
		{ unit: VenusOS.Units_Percentage, value: soc.value },
		{ unit: VenusOS.Units_Volt_DC, value: voltage.value },
		{ unit: VenusOS.Units_Amp, value: current.value },
	]

	quantityModel: !root.isParallelBms && state.isValid && state.value === VenusOS.Battery_State_Pending
		   ? _pendingModel
		   : _defaultModel

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml",
				{ bindPrefix: root.device.serviceUid })
	}

	VeQuickItem {
		id: numberOfBmses
		uid: root.device.serviceUid + "/NumberOfBmses"
	}

	VeQuickItem {
		id: state
		uid: root.device.serviceUid + "/State"
	}

	VeQuickItem {
		id: voltage
		uid: root.device.serviceUid + "/Dc/0/Voltage"
	}

	VeQuickItem {
		id: soc
		uid: root.device.serviceUid + "/Soc"
	}

	VeQuickItem {
		id: current
		uid: root.device.serviceUid + "/Dc/0/Current"
	}
}
