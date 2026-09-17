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

	VeQuickItem {
		id: directionInvertedItem
		uid: root.bindPrefix + "/Settings/Motor/DirectionInverted"
	}
	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Controller/Temperature"
	}
	VeQuickItem {
		id: temperatureItem2
		uid: root.bindPrefix + "/Coolant/Temperature"
	}
	VeQuickItem {
		id: temperatureItem3
		uid: root.bindPrefix + "/Motor/Temperature"
	}
	VeQuickItem {
		id: torqueItem
		uid: root.bindPrefix + "/Motor/Torque"
	}
	VeQuickItem {
		id: directionItem
		uid: root.bindPrefix + "/Motor/Direction"
	}
	VeQuickItem {
		id: rPMItem
		uid: root.bindPrefix + "/Motor/RPM"
	}
	VeQuickItem {
		id: dcVoltageItem
		uid: root.bindPrefix + "/Dc/0/Voltage"
	}
	VeQuickItem {
		id: dcCurrentItem
		uid: root.bindPrefix + "/Dc/0/Current"
	}
	VeQuickItem {
		id: dcPowerItem
		uid: root.bindPrefix + "/Dc/0/Power"
	}

	serviceUid: bindPrefix
	settingsModel: DelegateComponentModel {
		DelegateComponent {
			preferredVisible: dcVoltageItem.valid || dcCurrentItem.valid || dcPowerItem.valid
			ListQuantityGroup {
				text: CommonWords.dc
				model: QuantityObjectModel {
					filterType: QuantityObjectModel.HasValue

					QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC}
					QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
					QuantityObject { object: dcPower; unit: VenusOS.Units_Watt }
				}

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
		}

		DelegateComponent {
			preferredVisible: rPMItem.valid
			ListQuantity {
				//% "Motor RPM"
				text: qsTrId("devicelist_motordrive_motorrpm")
				dataItem.uid: root.bindPrefix + "/Motor/RPM"
				unit: VenusOS.Units_RevolutionsPerMinute
			}
		}

		DelegateComponent {
			preferredVisible: directionItem.valid
			ListMotorDriveGear {
				//% "Motor direction"
				text: qsTrId("devicelist_motordrive_motordirection")
				dataItem.uid: root.bindPrefix + "/Motor/Direction"
			}
		}

		DelegateComponent {
			preferredVisible: torqueItem.valid
			ListQuantity {
				//% "Motor torque"
				text: qsTrId("devicelist_motordrive_motortorque")
				dataItem.uid: root.bindPrefix + "/Motor/Torque"
				unit: VenusOS.Units_NewtonMeter
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem3.valid
			ListTemperature {
				//% "Motor temperature"
				text: qsTrId("devicelist_motordrive_motortemperature")
				dataItem.uid: root.bindPrefix + "/Motor/Temperature"
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem2.valid
			ListTemperature {
				//% "Coolant temperature"
				text: qsTrId("devicelist_motordrive_coolanttemperature")
				dataItem.uid: root.bindPrefix + "/Coolant/Temperature"
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid
			ListTemperature {
				//% "Controller temperature"
				text: qsTrId("devicelist_motordrive_controllertemperature")
				dataItem.uid: root.bindPrefix + "/Controller/Temperature"
			}
		}

		DelegateComponent {
			preferredVisible: directionInvertedItem.valid
			ListSwitch {
				//% "Motor direction inverted"
				text: qsTrId("devicelist_motordrive_motordirectioninverted")
				dataItem.uid: root.bindPrefix + "/Settings/Motor/DirectionInverted"
				dataItem.invalidate: false
			}
		}
	}
}