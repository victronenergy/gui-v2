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
		id: temperatureType
		uid: bindPrefix + "/TemperatureType"
	}
	VeQuickItem {
		id: deviceInstance
		uid: bindPrefix + "/DeviceInstance"
	}

	VeQuickItem {
		id: rawValueItem
		uid: root.bindPrefix + "/RawValue"
	}
	VeQuickItem {
		id: scaleItem
		uid: root.bindPrefix + "/Scale"
	}
	VeQuickItem {
		id: offsetItem
		uid: root.bindPrefix + "/Offset"
	}
	VeQuickItem {
		id: temperatureTypeItem
		uid: bindPrefix + "/TemperatureType"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: temperatureTypeItem.valid
				ListRadioButtonGroup {
					text: CommonWords.type
					dataItem.uid: bindPrefix + "/TemperatureType"
					optionModel: [
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Battery), value: VenusOS.Temperature_DeviceType_Battery },
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Fridge), value: VenusOS.Temperature_DeviceType_Fridge },
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Generic), value: VenusOS.Temperature_DeviceType_Generic },
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Room), value: VenusOS.Temperature_DeviceType_Room },
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Outdoor), value: VenusOS.Temperature_DeviceType_Outdoor },
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_WaterHeater), value: VenusOS.Temperature_DeviceType_WaterHeater },
						{ display: Global.environmentInputs.temperatureTypeToText(VenusOS.Temperature_DeviceType_Freezer), value: VenusOS.Temperature_DeviceType_Freezer },
					]
				}
			}

			DelegateComponent {
				preferredVisible: offsetItem.valid
				ListSpinBox {
					//% "Offset"
					text: qsTrId("temperature_offset")
					dataItem.uid: root.bindPrefix + "/Offset"
					from: -100
					to: 100
				}
			}

			DelegateComponent {
				preferredVisible: scaleItem.valid
				ListSpinBox {
					//% "Scale"
					text: qsTrId("temperature_scale")
					dataItem.uid: root.bindPrefix + "/Scale"
					from: 0
					to: 10
					stepSize: 0.1
					decimals: 1
				}
			}

			DelegateComponent {
				preferredVisible: rawValueItem.valid
				ListQuantity {
					//% "Sensor voltage"
					text: qsTrId("temperature_sensor_voltage")
					dataItem.uid: root.bindPrefix + "/RawValue"
					unit: VenusOS.Units_Volt_DC
				}
			}
		}
	}
}
