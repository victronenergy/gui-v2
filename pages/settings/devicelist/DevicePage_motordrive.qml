/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a motordrive device.
*/
DevicePage {
	id: root

	property string bindPrefix

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListQuantityGroup {
			text: CommonWords.dc
			model: QuantityObjectModel {
				filterType: QuantityObjectModel.HasValue

				QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC}
				QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
				QuantityObject { object: dcPower; unit: VenusOS.Units_Watt }
			}
			preferredVisible: dcVoltage.valid || dcCurrent.valid || dcPower.valid

			VeQuickItem {
				id: dcVoltage
				uid: root.bindPrefix + "/Dc/0/Voltage"
			}

			VeQuickItem {
				id: dcCurrent
				uid: root.bindPrefix + "/Dc/0/Current"
			}

			VeQuickItem {
				id: dcPower
				uid: root.bindPrefix + "/Dc/0/Power"
			}
		}

		ListQuantity {
			//% "Motor RPM"
			text: qsTrId("devicelist_motordrive_motorrpm")
			dataItem.uid: root.bindPrefix + "/Motor/RPM"
			unit: VenusOS.Units_RevolutionsPerMinute
			preferredVisible: dataItem.valid
		}

		ListMotorDriveGear {
			//% "Motor direction"
			text: qsTrId("devicelist_motordrive_motordirection")
			dataItem.uid: root.bindPrefix + "/Motor/Direction"
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Motor torque"
			text: qsTrId("devicelist_motordrive_motortorque")
			dataItem.uid: root.bindPrefix + "/Motor/Torque"
			unit: VenusOS.Units_NewtonMeter
			preferredVisible: dataItem.valid
		}

		ListTemperature {
			//% "Motor temperature"
			text: qsTrId("devicelist_motordrive_motortemperature")
			dataItem.uid: root.bindPrefix + "/Motor/Temperature"
			preferredVisible: dataItem.valid
		}

		ListTemperature {
			//% "Coolant temperature"
			text: qsTrId("devicelist_motordrive_coolanttemperature")
			dataItem.uid: root.bindPrefix + "/Coolant/Temperature"
			preferredVisible: dataItem.valid
		}

		ListTemperature {
			//% "Controller temperature"
			text: qsTrId("devicelist_motordrive_controllertemperature")
			dataItem.uid: root.bindPrefix + "/Controller/Temperature"
			preferredVisible: dataItem.valid
		}

		ListSwitch {
			//% "Motor direction inverted"
			text: qsTrId("devicelist_motordrive_motordirectioninverted")
			dataItem.uid: root.bindPrefix + "/Settings/Motor/DirectionInverted"
			dataItem.invalidate: false
			preferredVisible: dataItem.valid
		}
	}
}
