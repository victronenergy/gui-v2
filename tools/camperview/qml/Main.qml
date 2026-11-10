/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VeUtil

/*
	Reads the system values over MQTT and shows them in the RV illustration.

	It reads the same values as pages/CamperPage.qml in gui-v2, but from the system service's
	totals, as this app does not have the gui-v2 data models.
*/
Window {
	id: root

	readonly property string _system: "mqtt/system/0"

	// e.g. "com.victronenergy.battery/512" -> "mqtt/battery/512"
	readonly property string _batteryServiceUid: {
		const value = activeBatteryServiceItem.value
		if (typeof value !== "string" || value.indexOf("/") < 0) {
			return ""
		}
		const parts = value.split("/")
		return "mqtt/%1/%2".arg(parts[0].split(".").pop()).arg(parts[parts.length - 1])
	}

	readonly property bool _generatorPresent: acIn0SourceItem.value === 2 || acIn1SourceItem.value === 2

	function _real(item) {
		return item.valid ? Number(item.value) : NaN
	}

	function _int(item, fallback) {
		return item.valid ? parseInt(item.value) : fallback
	}

	component PhaseSum : QtObject {
		required property string prefix   // e.g. "mqtt/system/0/Ac/Consumption"

		readonly property real power: {
			const values = [l1.value, l2.value, l3.value].filter((v) => v !== undefined && v !== null)
			return values.length ? values.reduce((sum, v) => sum + Number(v), 0) : NaN
		}
		readonly property VeQuickItem l1: VeQuickItem { uid: prefix + "/L1/Power" }
		readonly property VeQuickItem l2: VeQuickItem { uid: prefix + "/L2/Power" }
		readonly property VeQuickItem l3: VeQuickItem { uid: prefix + "/L3/Power" }
	}

	function _sum(values) {
		const valid = values.filter((v) => isFinite(v))
		return valid.length ? valid.reduce((sum, v) => sum + v, 0) : NaN
	}

	width: 1280
	height: 720
	visible: true
	title: "RV"
	color: view.colorScheme === 1 ? "black" : "white"

	CamperOverviewView {
		id: view

		anchors.fill: parent

		colorScheme: camperBackend.colorScheme === "dark" ? 1 : 0

		activeInputSource: root._int(activeInputSourceItem, 0)
		systemState: root._int(systemStateItem, -1)
		inverterChargerPower: root._real(inverterChargerPowerItem)
		alternatorState: root._int(alternatorStateItem, -1)
		lowSocAlarm: root._int(lowSocAlarmItem, 0)
		veBusLowBatteryAlarm: root._int(veBusLowBatteryAlarmItem, 0)
		solarPresent: isFinite(view.solarPower)
		generatorPresent: root._generatorPresent

		activeInputPower: activeInputPowerItem.power
		generatorPower: root._generatorPresent ? generatorPowerItem.power : NaN
		solarPower: root._sum([root._real(dcPvPowerItem), pvOnGridItem.power, pvOnGensetItem.power, pvOnOutputItem.power])
		alternatorPower: root._real(alternatorPowerItem)
		batteryPower: root._real(batteryPowerItem)
		batterySoc: root._real(batterySocItem)
		dcLoadsPower: root._real(dcLoadsPowerItem)
		acLoadsPower: acLoadsPowerItem.power
	}

	VeQuickItem { id: activeInputSourceItem; uid: root._system + "/Ac/ActiveIn/Source" }
	VeQuickItem { id: acIn0SourceItem; uid: root._system + "/Ac/In/0/Source" }
	VeQuickItem { id: acIn1SourceItem; uid: root._system + "/Ac/In/1/Source" }
	VeQuickItem { id: systemStateItem; uid: root._system + "/SystemState/State" }
	VeQuickItem { id: inverterChargerPowerItem; uid: root._system + "/Dc/InverterCharger/Power" }
	VeQuickItem { id: dcPvPowerItem; uid: root._system + "/Dc/Pv/Power" }
	VeQuickItem { id: alternatorPowerItem; uid: root._system + "/Dc/Alternator/Power" }
	VeQuickItem { id: batteryPowerItem; uid: root._system + "/Dc/Battery/Power" }
	VeQuickItem { id: batterySocItem; uid: root._system + "/Dc/Battery/Soc" }
	VeQuickItem { id: dcLoadsPowerItem; uid: root._system + "/Dc/System/Power" }
	VeQuickItem { id: activeBatteryServiceItem; uid: root._system + "/ActiveBatteryService" }
	VeQuickItem { id: veBusInstanceItem; uid: root._system + "/VebusInstance" }

	VeQuickItem {
		id: alternatorStateItem
		uid: camperBackend.alternatorServiceUid ? camperBackend.alternatorServiceUid + "/State" : ""
	}
	VeQuickItem {
		id: lowSocAlarmItem
		uid: root._batteryServiceUid ? root._batteryServiceUid + "/Alarms/LowSoc" : ""
	}
	VeQuickItem {
		id: veBusLowBatteryAlarmItem
		uid: veBusInstanceItem.valid ? "mqtt/vebus/%1/Alarms/LowBattery".arg(veBusInstanceItem.value) : ""
	}

	PhaseSum { id: activeInputPowerItem; prefix: root._system + "/Ac/ActiveIn" }
	PhaseSum { id: generatorPowerItem; prefix: root._system + "/Ac/Genset" }
	PhaseSum { id: acLoadsPowerItem; prefix: root._system + "/Ac/Consumption" }
	PhaseSum { id: pvOnGridItem; prefix: root._system + "/Ac/PvOnGrid" }
	PhaseSum { id: pvOnGensetItem; prefix: root._system + "/Ac/PvOnGenset" }
	PhaseSum { id: pvOnOutputItem; prefix: root._system + "/Ac/PvOnOutput" }
}
