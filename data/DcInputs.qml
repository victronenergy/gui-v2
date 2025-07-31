/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property real power: NaN
	property real current: NaN
	readonly property real maximumPower: _maximumPower.valid ? _maximumPower.value : NaN
	readonly property list<string> serviceTypes: ["alternator","fuelcell","dcsource","dcgenset"]

	readonly property DeviceModel model: DeviceModel {
		modelId: "dcInputs"
		onCountChanged: Qt.callLater(root.updateTotals)
	}

	function updateTotals() {
		let totalPower = NaN
		let totalCurrent = NaN
		for (let i = 0; i < model.count; ++i) {
			const input = model.deviceAt(i)
			const p = input.power
			if (!isNaN(p)) {
				if (isNaN(totalPower)) {
					totalPower = 0
				}
				totalPower += p
			}
			const c = input.current
			if (!isNaN(c)) {
				if (isNaN(totalCurrent)) {
					totalCurrent = 0
				}
				totalCurrent += c
			}
		}
		power = totalPower
		current = totalCurrent
	}

	readonly property VeQuickItem _maximumPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/Input/Power/Max"
	}

	readonly property Instantiator _dcInputObjects: Instantiator {
		model: FilteredServiceModel { serviceTypes: root.serviceTypes }
		delegate: DcInput {
			id: input
			required property string uid
			serviceUid: uid
			onValidChanged: {
				if (valid) {
					root.model.addDevice(input)
				} else {
					root.model.removeDevice(input.serviceUid)
				}
			}

			onVoltageChanged: Qt.callLater(root.updateTotals)
			onCurrentChanged: Qt.callLater(root.updateTotals)
			onPowerChanged: Qt.callLater(root.updateTotals)
		}
	}

	Component.onCompleted: Global.dcInputs = root
}
