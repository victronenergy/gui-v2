/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units
import Victron.Gauges

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListSpinBox {
				id: capacitySpinBox

				//% "Capacity"
				text: qsTrId("devicelist_tanksetup_capacity")
				suffix: Units.defaultUnitString(Global.systemSettings.volumeUnit.value)
				stepSize: Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_CubicMeter
						  ? 5   // Cubic meters (this becomes 0.005 when ListSpinBox adjusts it for decimals)
						  : 1   // Liters, Gallons
				decimals: Units.defaultUnitPrecision(Global.systemSettings.volumeUnit.value)
				from: Units.convertVolumeForUnit(capacity.min, Global.systemSettings.volumeUnit.value)
				to: Units.convertVolumeForUnit(capacity.max, Global.systemSettings.volumeUnit.value)
				value: capacity.value === undefined ? 0
					 : Units.convertVolumeForUnit(capacity.value, Global.systemSettings.volumeUnit.value)

				onSelectorAccepted: function(newValue) {
					capacity.setValue(Units.convertVolumeForUnit(newValue, VenusOS.Units_Volume_CubicMeter))
				}

				VeQuickItem {
					id: capacity

					uid: root.bindPrefix + "/Capacity"
				}
			}

			ListRadioButtonGroup {
				//% "Sensor type"
				text: qsTrId("devicelist_tanksetup_sensor_type")
				dataItem.uid: root.bindPrefix + "/SenseType"
				visible: defaultVisible && dataItem.isValid
				optionModel: [
					{ display: CommonWords.voltage, value: 1 },
					{ display: CommonWords.current_amps, value: 2 },
				]
			}

			ListRadioButtonGroup {
				id: standard

				//% "Standard"
				text: qsTrId("devicelist_tanksetup_standard")
				dataItem.uid: root.bindPrefix + "/Standard"
				visible: defaultVisible && dataItem.isValid
				optionModel: [
					//% "European (0 to 180 Ohm)"
					{ display: qsTrId("devicelist_tanksetup_european_(0_to_180_ohm)"), value: 0 },
					//% "US (240 to 30 Ohm)"
					{ display: qsTrId("devicelist_tanksetup_us_(240_to_30_ohm)"), value: 1 },
					//% "Custom"
					{ display: qsTrId("devicelist_tanksetup_custom"), value: 2 },
				]
			}

			ListSpinBox {
				//% "Sensor value when empty"
				text: qsTrId("devicelist_tanksetup_sensor_value_when_empty")
				visible: dataItem.seen && (!standard.dataItem.isValid || standard.currentValue === 2)
				dataItem.uid: root.bindPrefix + "/RawValueEmpty"
				suffix: rawUnit.value || ""
				decimals: 1
				stepSize: 0.1
			}

			ListSpinBox {
				//% "Sensor value when empty"
				text: qsTrId("devicelist_tanksetup_sensor_value_when_empty")
				visible: dataItem.seen && (!standard.dataItem.isValid || standard.currentValue === 2)
				dataItem.uid: root.bindPrefix + "/RawValueFull"
				suffix: rawUnit.value || ""
				decimals: 1
				stepSize: 0.1
			}

			ListRadioButtonGroup {
				//% "Fluid type"
				text: qsTrId("devicelist_tanksetup_fluid_type")
				dataItem.uid: root.bindPrefix + "/FluidType"
				optionModel: Global.tanks.tankTypes.map(function(tankType) {
					return { display: Gauges.tankProperties(tankType).name || "", value: tankType }
				})
			}

			ListSpinBox {
				//% "Butane ratio"
				text: qsTrId("devicelist_tanksetup_butane_ratio")
				visible: defaultVisible && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/ButaneRatio"
				suffix: "%"
			}

			VolumeUnitRadioButtonGroup {
				//% "Volume unit"
				text: qsTrId("devicelist_tanksetup_volume_unit")
			}

			ListNavigationItem {
				//% "Custom shape"
				text: qsTrId("devicelist_tanksetup_custom_shape")
				visible: shape.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankShape.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: shape
					uid: root.bindPrefix + "/Shape"
				}
			}

			ListSpinBox {
				//% "Averaging time"
				text: qsTrId("devicelist_tanksetup_averaging_time")
				dataItem.uid: root.bindPrefix + "/FilterLength"
				visible: defaultVisible && dataItem.isValid
				suffix: "s"
			}

			ListSpinBox {
				//% "Sensor value"
				text: qsTrId("devicelist_tanksetup_sensor_value")
				dataItem.uid: root.bindPrefix + "/RawValue"
				visible: defaultVisible && dataItem.isValid
				suffix: rawUnit.value || ""
				decimals: 1
			}

			ListNavigationItem {
				text: CommonWords.low_level_alarm
				visible: low.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankAlarm.qml",
							{ "title": text, "bindPrefix": root.bindPrefix + "/Alarms/Low" })
				}

				VeQuickItem {
					id: low
					uid: root.bindPrefix + "/Alarms/Low/Enable"
				}
			}

			ListNavigationItem {
				text: CommonWords.high_level_alarm
				visible: high.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankAlarm.qml",
							{ "title": text, "bindPrefix": root.bindPrefix + "/Alarms/High" })
				}

				VeQuickItem {
					id: high
					uid: root.bindPrefix + "/Alarms/High/Enable"
				}
			}
		}
	}

	VeQuickItem {
		id: rawUnit
		uid: root.bindPrefix + "/RawUnit"
	}
}
