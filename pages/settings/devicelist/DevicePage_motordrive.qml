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
				uid: root.serviceUid + "/Dc/0/Voltage"
			}

			VeQuickItem {
				id: dcCurrent
				uid: root.serviceUid + "/Dc/0/Current"
			}

			VeQuickItem {
				id: dcPower
				uid: root.serviceUid + "/Dc/0/Power"
			}
		}

		ListQuantity {
			//% "Motor RPM"
			text: qsTrId("devicelist_motordrive_motorrpm")
			dataItem.uid: root.serviceUid + "/Motor/RPM"
			unit: VenusOS.Units_RevolutionsPerMinute
			preferredVisible: dataItem.valid
		}

		ListMotorDriveGear {
			//% "Motor direction"
			text: qsTrId("devicelist_motordrive_motordirection")
			dataItem.uid: root.serviceUid + "/Motor/Direction"
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Motor torque"
			text: qsTrId("devicelist_motordrive_motortorque")
			dataItem.uid: root.serviceUid + "/Motor/Torque"
			unit: VenusOS.Units_NewtonMeter
			preferredVisible: dataItem.valid
		}

		ListTemperature {
			//% "Motor temperature"
			text: qsTrId("devicelist_motordrive_motortemperature")
			dataItem.uid: root.serviceUid + "/Motor/Temperature"
			preferredVisible: dataItem.valid
		}

		ListTemperature {
			//% "Coolant temperature"
			text: qsTrId("devicelist_motordrive_coolanttemperature")
			dataItem.uid: root.serviceUid + "/Coolant/Temperature"
			preferredVisible: dataItem.valid
		}

		ListTemperature {
			//% "Controller temperature"
			text: qsTrId("devicelist_motordrive_controllertemperature")
			dataItem.uid: root.serviceUid + "/Controller/Temperature"
			preferredVisible: dataItem.valid
		}

		ListSwitch {
			//% "Motor direction inverted"
			text: qsTrId("devicelist_motordrive_motordirectioninverted")
			dataItem.uid: root.serviceUid + "/Settings/Motor/DirectionInverted"
			dataItem.invalidate: false
			preferredVisible: dataItem.valid
		}
	}
}
