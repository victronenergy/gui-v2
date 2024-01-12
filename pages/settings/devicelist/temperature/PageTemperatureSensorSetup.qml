/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: temperatureType
		uid: bindPrefix + "/TemperatureType"
	}

	VeQuickItem {
		id: deviceInstance
		uid: bindPrefix + "/DeviceInstance"
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				text: CommonWords.type
				dataItem.uid: bindPrefix + "/TemperatureType"
				visible: defaultVisible && dataItem.isValid
				optionModel: [
					{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Battery), value: VenusOS.Temperature_DeviceType_Battery },
					{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Fridge), value: VenusOS.Temperature_DeviceType_Fridge },
					{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Generic), value: VenusOS.Temperature_DeviceType_Generic },
				]
			}

			ListSpinBox {
				//% "Offset"
				text: qsTrId("temperature_offset")
				writeAccessLevel: VenusOS.User_AccessType_SuperUser
				dataItem.uid: root.bindPrefix + "/Offset"
				visible: defaultVisible && dataItem.isValid
				from: -100
				to: 100
			}

			ListSpinBox {
				//% "Scale"
				text: qsTrId("temperature_scale")
				writeAccessLevel: VenusOS.User_AccessType_SuperUser
				dataItem.uid: root.bindPrefix + "/Scale"
				visible: defaultVisible && dataItem.isValid
				from: 0
				to: 10
				decimals: 1
			}

			ListQuantityItem {
				//% "Sensor voltage"
				text: qsTrId("temperature_sensor_voltage")
				visible: defaultVisible && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/RawValue"
				unit: VenusOS.Units_Volt
				precision: 2
			}
		}
	}
}
