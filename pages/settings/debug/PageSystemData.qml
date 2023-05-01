/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function _formatValue(value, unit) {
		return (value == null ? "--" : value.toFixed(2)) + " " + unit
	}

	function _formatPowerValue(value) {
		return _formatValue(value, "W")
	}

	HubData {
		id: data
	}

	GradientListView {
		model: ObjectModel {
			ListTextGroup {
				text: "PV On ACIn1"
				textModel: [
					_formatPowerValue(data.pvOnAcIn1.power),
					_formatPowerValue(data.pvOnAcIn1.powerL1.value),
					_formatPowerValue(data.pvOnAcIn1.powerL2.value),
					_formatPowerValue(data.pvOnAcIn1.powerL3.value),
				]
			}

			ListTextGroup {
				text: "PV On ACIn2"
				textModel: [
					_formatPowerValue(data.pvOnAcIn2.power),
					_formatPowerValue(data.pvOnAcIn2.powerL1.value),
					_formatPowerValue(data.pvOnAcIn2.powerL2.value),
					_formatPowerValue(data.pvOnAcIn2.powerL3.value),
				]
			}

			ListTextGroup {
				text: "PV On AC Out"
				textModel: [
					_formatPowerValue(data.pvOnAcOut.power),
					_formatPowerValue(data.pvOnAcOut.powerL1.value),
					_formatPowerValue(data.pvOnAcOut.powerL2.value),
					_formatPowerValue(data.pvOnAcOut.powerL3.value),
				]
			}

			ListTextGroup {
				text: "VE.Bus AC out"
				textModel: [
					_formatPowerValue(data.vebusAcOut.power),
					_formatPowerValue(data.vebusAcOut.powerL1.value),
					_formatPowerValue(data.vebusAcOut.powerL2.value),
					_formatPowerValue(data.vebusAcOut.powerL3.value),
				]
			}

			ListTextGroup {
				text: "AC loads"
				textModel: [
					_formatPowerValue(data.acLoad.power),
					_formatPowerValue(data.acLoad.powerL1.value),
					_formatPowerValue(data.acLoad.powerL2.value),
					_formatPowerValue(data.acLoad.powerL3.value),
				]
			}

			ListTextGroup {
				text: "Battery"
				textModel: [
					_formatPowerValue(Global.batteries.first.power),
					_formatValue(Global.batteries.first.voltage, "V"),
					_formatValue(Global.batteries.first.current, "A"),
				]
			}

			ListTextGroup {
				text: "PV Charger"
				textModel: [
					_formatPowerValue(data.pvCharger.power.value),
				]
			}
		}
	}
}
