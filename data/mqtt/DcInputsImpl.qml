/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var _monitorModes: ({
		"-1": VenusOS.DcInputs_InputType_DcGenerator,
		// -2 AC charger
		// -3 DC charger
		// -4 Water generator
		// -7 Shaft generator
		// -8 Wind charger
		"-8": VenusOS.DcInputs_InputType_Wind,
	})

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/alternator", "mqtt/fuelcell", "mqtt/dcsource"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			id: input

			readonly property string serviceUid: model.uid

			readonly property int source: {
				if (model.uid.startsWith("mqtt/alternator")) {
					return VenusOS.DcInputs_InputType_Alternator
				} else if (model.uid.startsWith("mqtt/fuelcell")) {
					return VenusOS.DcInputs_InputType_FuelCell
				} else if (model.uid.startsWith("mqtt/dcsource")) {
					// Use DC Generator as the catch-all type for any DC power source that isn't
					// specifically handled.
					return root._monitorModes[monitorMode.toString()] || VenusOS.DcInputs_InputType_DcGenerator
				}
				return VenusOS.DcInputs_InputType_Unknown
			}

			property real voltage: NaN
			property real current: NaN
			property real power: isNaN(voltage) || isNaN(current) ? NaN : voltage * current
			property real temperature_celsius: NaN
			property int monitorMode

			Component.onCompleted: {
				Global.dcInputs.addInput(input)
			}
			Component.onDestruction: {
				const index = Utils.findIndex(Global.dcInputs.model, input)
				if (index >= 0) {
					Global.dcInputs.removeInput(index)
				}
			}

			property var _voltage: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Voltage"
				onValueChanged: {
					input.voltage = value === undefined ? NaN : value
					Qt.callLater(Global.dcInputs.updateTotals)
				}
			}

			property var _current: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Current"
				onValueChanged: {
					input.current = value === undefined ? NaN : value
					Qt.callLater(Global.dcInputs.updateTotals)
				}
			}

			property var _temperature: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Temperature"
				onValueChanged: input.temperature_celsius = value === undefined ? NaN : value
			}

			property var _monitorMode: VeQuickItem {
				uid: input.serviceUid + "/Settings/MonitorMode"
				onValueChanged: input.monitorMode = value === undefined ? NaN : value
			}
		}
	}
}
