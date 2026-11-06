/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Window {
	id: root

	readonly property var _data: camperDataProvider.data

	function _number(value) {
		// Number(null) is 0, but a missing value must be displayed as missing, not as zero.
		return value === null || value === undefined ? NaN : Number(value)
	}

	width: 1280
	height: 720
	visible: true
	title: "Camper View"

	CamperOverviewView {
		anchors.fill: parent

		colorScheme: root._data.colorScheme === "dark" ? 1 : 0

		activeInputSource: root._data.activeInputSource ?? 0
		acInputConnected: root._data.acInputConnected ?? false
		alternatorState: root._data.alternatorState ?? -1
		lowSocAlarm: root._data.lowSocAlarm ?? 0
		solarPresent: root._data.solarPresent ?? true
		generatorPresent: root._data.generatorPresent ?? true

		activeInputPower: root._number(root._data.activeInputPower)
		generatorPower: root._number(root._data.generatorPower)
		solarPower: root._number(root._data.solarPower)
		alternatorPower: root._number(root._data.alternatorPower)
		batteryPower: root._number(root._data.batteryPower)
		batterySoc: root._number(root._data.batterySoc)
		dcLoadsPower: root._number(root._data.dcLoadsPower)
		acLoadsPower: root._number(root._data.acLoadsPower)
	}
}
