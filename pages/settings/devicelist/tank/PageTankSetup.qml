/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Units.js" as Units
import "/components/Gauges.js" as Gauges

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListSpinBox {
				id: capacitySpinBox

				readonly property var _quantityInfo: Units.getDisplayText(Global.systemSettings.volumeUnit.value)

				function _stepSize() {
					switch (Global.systemSettings.volumeUnit.value) {
					case VenusOS.Units_Volume_Liter:
					case VenusOS.Units_Volume_GallonImperial:
					case VenusOS.Units_Volume_GallonUS:
						return 1
					default:    // Units_Volume_CubicMeter
						return 0.005
					}
				}

				//% "Capacity"
				text: qsTrId("devicelist_tanksetup_capacity")
				suffix: _quantityInfo.unit
				stepSize: _stepSize()
				decimals: Units.defaultUnitPrecision(Global.systemSettings.volumeUnit.value)
				from: Units.convertVolumeForUnit(capacity.min, Global.systemSettings.volumeUnit.value)
				to: Units.convertVolumeForUnit(capacity.max, Global.systemSettings.volumeUnit.value)

				onSelectorAccepted: function(newValue) {
					capacity.value = Units.convertVolumeForUnit(newValue, VenusOS.Units_Volume_CubicMeter)
				}

				DataPoint {
					id: capacity

					source: root.bindPrefix + "/Capacity"
					onValueChanged: {
						if (valid) {
							capacitySpinBox.value = Units.convertVolumeForUnit(value, Global.systemSettings.volumeUnit.value)
						} else {
							capacitySpinBox.value = 0
						}
					}
				}
			}

			ListRadioButtonGroup {
				//% "Sensor type"
				text: qsTrId("devicelist_tanksetup_sensor_type")
				dataSource: root.bindPrefix + "/SenseType"
				visible: defaultVisible && dataValid
				optionModel: [
					{ display: CommonWords.voltage, value: 1 },
					{ display: CommonWords.current_amps, value: 2 },
				]
			}

			ListRadioButtonGroup {
				id: standard

				//% "Standard"
				text: qsTrId("devicelist_tanksetup_standard")
				dataSource: root.bindPrefix + "/Standard"
				visible: defaultVisible && dataValid
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
				visible: dataSeen && (!standard.dataValid || standard.currentValue === 2)
				dataSource: root.bindPrefix + "/RawValueEmpty"
				suffix: rawUnit.value || ""
				stepSize: 0.1
			}

			ListSpinBox {
				//% "Sensor value when empty"
				text: qsTrId("devicelist_tanksetup_sensor_value_when_empty")
				visible: dataSeen && (!standard.dataValid || standard.currentValue === 2)
				dataSource: root.bindPrefix + "/RawValueFull"
				suffix: rawUnit.value || ""
				stepSize: 0.1
			}

			ListRadioButtonGroup {
				//% "Fluid type"
				text: qsTrId("devicelist_tanksetup_fluid_type")
				dataSource: root.bindPrefix + "/FluidType"
				optionModel: Global.tanks.tankTypes.map(function(tankType) {
					return { display: Gauges.tankProperties(tankType).name || "", value: tankType }
				})
			}

			ListSpinBox {
				//% "Butane ratio"
				text: qsTrId("devicelist_tanksetup_butane_ratio")
				visible: defaultVisible && dataValid
				dataSource: root.bindPrefix + "/ButaneRatio"
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

				DataPoint {
					id: shape
					source: root.bindPrefix + "/Shape"
				}
			}

			ListSpinBox {
				//% "Averaging time"
				text: qsTrId("devicelist_tanksetup_averaging_time")
				dataSource: root.bindPrefix + "/FilterLength"
				visible: defaultVisible && dataValid
				suffix: "s"
			}

			ListSpinBox {
				//% "Sensor value"
				text: qsTrId("devicelist_tanksetup_sensor_value")
				dataSource: root.bindPrefix + "/RawValue"
				visible: defaultVisible && dataValid
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

				DataPoint {
					id: low
					source: root.bindPrefix + "/Alarms/Low/Enable"
				}
			}

			ListNavigationItem {
				text: CommonWords.high_level_alarm
				visible: high.seen

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankAlarm.qml",
							{ "title": text, "bindPrefix": root.bindPrefix + "/Alarms/High" })
				}

				DataPoint {
					id: high
					source: root.bindPrefix + "/Alarms/High/Enable"
				}
			}
		}
	}

	DataPoint {
		id: rawUnit
		source: root.bindPrefix + "/RawUnit"
	}
}
