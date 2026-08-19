/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: minBatteryVoltageItem
		uid: root.bindPrefix + "/History/Overall/MinBatteryVoltage"
	}
	VeQuickItem {
		id: maxBatteryVoltageItem
		uid: root.bindPrefix + "/History/Overall/MaxBatteryVoltage"
	}
	VeQuickItem {
		id: maxPvVoltageItem
		uid: root.bindPrefix + "/History/Overall/MaxPvVoltage"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: maxPvVoltageItem.valid
				ListQuantity {
					//% "Maximum PV voltage"
					text: qsTrId("inverter_maximum_pv_voltage")
					dataItem.uid: root.bindPrefix + "/History/Overall/MaxPvVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: maxBatteryVoltageItem.valid
				ListQuantity {
					//% "Maximum battery voltage"
					text: qsTrId("inverter_maximum_battery_voltage")
					dataItem.uid: root.bindPrefix + "/History/Overall/MaxBatteryVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: minBatteryVoltageItem.valid
				ListQuantity {
					//% "Minimum battery voltage"
					text: qsTrId("inverter_minimum_battery_voltage")
					dataItem.uid: root.bindPrefix + "/History/Overall/MinBatteryVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				id: errorModelDC
				property int count
				preferredVisible: errorModelDC.count > 0
				SettingsColumn {
					width: parent ? parent.width : 0

					Repeater {
						model: SolarHistoryErrorModel {
							id: errorModel
							uidPrefix: root.bindPrefix + "/History/Overall"
						}

						delegate: ListText {
							text: errorModel.count === 1 ? "" : CommonWords.lastErrorName(model.index)
							secondaryText: ChargerError.description(model.errorCode)
						}
					}
					Binding { target: errorModelDC; property: "count"; value: errorModel.count }

				}
			}
		}
	}
}
