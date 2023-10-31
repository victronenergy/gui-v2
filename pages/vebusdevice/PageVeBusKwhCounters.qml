/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Page {
	id: root

	property string bindPrefix
	property var service

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				//% "VE.Bus Quirks"
				text: qsTrId("vebus_quirks")
				dataSource: service + "/Quirks"
			}

			ListRadioButtonGroup {
				text: "Power Type"
				dataSource: service + "/Ac/PowerMeasurementType"
				enabled: false
				optionModel: [
					{ display: "Apparent power, phase masters", value: 0 },
					{ display: "Real power, phase master, no snapshot", value: 1 },
					{ display: "Real power, all devices, no snapshot", value: 2 },
					{ display: "Real power, phase masters, snapshot", value: 3 },
					{ display: "Real power, all devices, snapshot", value: 4 },
				]
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: VeBusDeviceKwhCountersModel { }

					ListTextItem {

						property var value: Units.getDisplayText(VenusOS.Units_Energy_KiloWattHour, dataValue)

						text: displayText
						secondaryText: value.number + value.unit
						dataSource: bindPrefix + pathSuffix
					}
				}
			}
		}
	}
}
