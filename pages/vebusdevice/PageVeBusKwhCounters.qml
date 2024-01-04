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
				dataItem.uid: service + "/Quirks"
			}

			ListRadioButtonGroup {
				text: "Power Type"
				dataItem.uid: service + "/Ac/PowerMeasurementType"
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

						property quantityInfo value: Units.getDisplayText(VenusOS.Units_Energy_KiloWattHour, dataItem.value)

						text: displayText
						secondaryText: value.number + value.unit
						dataItem.uid: bindPrefix + pathSuffix
					}
				}
			}
		}
	}
}
