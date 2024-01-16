/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				//% "Maximum PV voltage"
				text: qsTrId("inverter_maximum_pv_voltage")
				dataItem.uid: root.bindPrefix + "/History/Overall/MaxPvVoltage"
				unit: VenusOS.Units_Volt
				precision: 2
				visible: defaultVisible && dataItem.isValid
			}

			ListQuantityItem {
				//% "Maximum battery voltage"
				text: qsTrId("inverter_maximum_battery_voltage")
				dataItem.uid: root.bindPrefix + "/History/Overall/MaxBatteryVoltage"
				unit: VenusOS.Units_Volt
				precision: 2
				visible: defaultVisible && dataItem.isValid
			}

			ListQuantityItem {
				//% "Minimum battery voltage"
				text: qsTrId("inverter_minimum_battery_voltage")
				dataItem.uid: root.bindPrefix + "/History/Overall/MinBatteryVoltage"
				unit: VenusOS.Units_Volt
				precision: 2
				visible: defaultVisible && dataItem.isValid
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: SolarHistoryErrorModel {
						id: errorModel
						uidPrefix: root.bindPrefix + "/History/Overall"
					}

					delegate: ListTextItem {
						text: errorModel.count === 1 ? "" : CommonWords.lastErrorName(model.index)
						secondaryText: ChargerError.description(model.errorCode)
					}
				}

			}
		}
	}
}
