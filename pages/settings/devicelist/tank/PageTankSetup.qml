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
		id: rawValueItem
		uid: root.bindPrefix + "/RawValue"
	}
	VeQuickItem {
		id: filterLengthItem
		uid: root.bindPrefix + "/FilterLength"
	}
	VeQuickItem {
		id: butaneRatioItem
		uid: root.bindPrefix + "/ButaneRatio"
	}
	VeQuickItem {
		id: standardItem
		uid: root.bindPrefix + "/Standard"
	}
	VeQuickItem {
		id: senseTypeItem
		uid: root.bindPrefix + "/SenseType"
	}
	VeQuickItem {
		id: rawUnit

		// The possible values here are not well defined. The doco says: "can be V, and probably also mA and R or O."
		// At least one installation uses "cm".
		// Resistive tank sensors (European 0-180Ω, US 240-30Ω, Custom) publish "Ω" or
		// its ASCII equivalent "O". 1 decimal place and 0.1 Ω step are appropriate for
		// resistance values in the tens-to-hundreds-of-ohms range.
		readonly property int displayDecimals: {
			switch (value) {
			case "cm":
			case "Ω":
			case "O":
				return 1
			default:
				return 3
			}
		}

		readonly property real stepSize: {
			switch (value) {
			case "cm":
			case "Ω":
			case "O":
				return 0.1
			default:
				return 0.005
			}
		}

		uid: root.bindPrefix + "/RawUnit"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListSpinBox {
					//% "Capacity"
					text: qsTrId("devicelist_tanksetup_capacity")
					dataItem.uid: root.bindPrefix + "/Capacity"
					dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMetre)
					dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.volumeUnit)
					suffix: Units.defaultUnitString(Global.systemSettings.volumeUnit)
					stepSize: Global.systemSettings.volumeUnit === VenusOS.Units_Volume_CubicMetre
							  ? 0.005
							  : 1   // Litres, Gallons
					decimals: Units.defaultUnitDecimals(Global.systemSettings.volumeUnit)
				}
			}

			DelegateComponent {
				preferredVisible: senseTypeItem.valid
				ListRadioButtonGroup {
					//% "Sensor type"
					text: qsTrId("devicelist_tanksetup_sensor_type")
					dataItem.uid: root.bindPrefix + "/SenseType"
					optionModel: [
						{ display: CommonWords.voltage, value: 1 },
						{ display: CommonWords.current_amps, value: 2 },
					]
				}
			}

			DelegateComponent {
				id: standardDC
				property var currentValue: standardItem.valid ? standardItem.value : undefined
				preferredVisible: standardItem.valid
				ListRadioButtonGroup {
					id: standard

					//% "Standard"
					text: qsTrId("devicelist_tanksetup_standard")
					dataItem.uid: root.bindPrefix + "/Standard"
					optionModel: [
						//% "European (0 to 180 Ohm)"
						{ display: qsTrId("devicelist_tanksetup_european_(0_to_180_ohm)"), value: 0 },
						//% "US (240 to 30 Ohm)"
						{ display: qsTrId("devicelist_tanksetup_us_(240_to_30_ohm)"), value: 1 },
						//% "Custom"
						{ display: qsTrId("devicelist_tanksetup_custom"), value: 2 },
					]
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/RawValueEmpty" }
				preferredVisible: dataItem.seen && (!standardItem.valid || standardDC.currentValue === 2)
				ListSpinBox {
					//% "Sensor value when empty"
					text: qsTrId("devicelist_tanksetup_sensor_value_when_empty")
					dataItem.uid: root.bindPrefix + "/RawValueEmpty"
					suffix: rawUnit.value || ""
					decimals: rawUnit.displayDecimals
					stepSize: rawUnit.stepSize
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/RawValueFull" }
				preferredVisible: dataItem.seen && (!standardItem.valid || standardDC.currentValue === 2)
				ListSpinBox {
					//% "Sensor value when full"
					text: qsTrId("devicelist_tanksetup_sensor_value_when_full")
					dataItem.uid: root.bindPrefix + "/RawValueFull"
					suffix: rawUnit.value || ""
					decimals: rawUnit.displayDecimals
					stepSize: rawUnit.stepSize
				}
			}

			DelegateComponent {
				ListRadioButtonGroup {
					//% "Fluid type"
					text: qsTrId("devicelist_tanksetup_fluid_type")
					dataItem.uid: root.bindPrefix + "/FluidType"
					optionModel: Global.tanks.tankTypes.map(function(tankType) {
						return { display: VenusOS.tank_fluidTypeToText(tankType), value: tankType }
					})
				}
			}

			DelegateComponent {
				preferredVisible: butaneRatioItem.valid
				ListSpinBox {
					//% "Butane ratio"
					text: qsTrId("devicelist_tanksetup_butane_ratio")
					dataItem.uid: root.bindPrefix + "/ButaneRatio"
					suffix: "%"
				}
			}

			DelegateComponent {
				ListVolumeUnitRadioButtonGroup {}
			}

			DelegateComponent {
				id: shapeDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Shape" }
				preferredVisible: shapeDC.dataItem.seen
				ListNavigation {
					//% "Custom shape"
					text: qsTrId("devicelist_tanksetup_custom_shape")

					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankShape.qml",
								{ "title": text, "bindPrefix": root.bindPrefix })
					}

					VeQuickItem {
						id: shape
						uid: root.bindPrefix + "/Shape"
					}
				}
			}

			DelegateComponent {
				preferredVisible: filterLengthItem.valid
				ListSpinBox {
					//% "Averaging time"
					text: qsTrId("devicelist_tanksetup_averaging_time")
					dataItem.uid: root.bindPrefix + "/FilterLength"
					suffix: "s"
				}
			}

			DelegateComponent {
				preferredVisible: rawValueItem.valid
				ListText {
					//% "Sensor value"
					text: qsTrId("devicelist_tanksetup_sensor_value")
					dataItem.uid: root.bindPrefix + "/RawValue"
					secondaryText: dataItem.valid ? Units.formatNumber(dataItem.value, rawUnit.displayDecimals) + (rawUnit.value || "") : "--"
				}
			}

			DelegateComponent {
				id: lowDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Alarms/Low/Enable" }
				preferredVisible: lowDC.dataItem.seen
				ListNavigation {
					text: CommonWords.low_level_alarm

					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankAlarm.qml",
								{ "title": text, "bindPrefix": root.bindPrefix + "/Alarms/Low" })
					}

					VeQuickItem {
						id: low
						uid: root.bindPrefix + "/Alarms/Low/Enable"
					}
				}
			}

			DelegateComponent {
				id: highDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Alarms/High/Enable" }
				preferredVisible: highDC.dataItem.seen
				ListNavigation {
					text: CommonWords.high_level_alarm

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
	}
}