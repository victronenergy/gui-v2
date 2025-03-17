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
		id: currentItem
		uid: root.bindPrefix + "/Dc/0/Current"
	}
	VeQuickItem {
		id: cellSumItem
		uid: root.bindPrefix + "/Voltages/Sum"
	}
	VeQuickItem {
		id: cellMinItem
		uid: root.bindPrefix + "/System/MinCellVoltage"
	}
	VeQuickItem {
		id: cellMaxItem
		uid: root.bindPrefix + "/System/MaxCellVoltage"
	}
	VeQuickItem {
		id: socItem
		uid: root.bindPrefix + "/Soc"
	}

	VeQuickItem {
		id: temperatureMosItem
		uid: root.bindPrefix + "/System/MOSTemperature"
	}
	VeQuickItem {
		id: temperature1Item
		uid: root.bindPrefix + "/System/Temperature1"
	}
	VeQuickItem {
		id: temperature1NameItem
		uid: root.bindPrefix + "/System/Temperature1Name"
	}
	VeQuickItem {
		id: temperature2Item
		uid: root.bindPrefix + "/System/Temperature2"
	}
	VeQuickItem {
		id: temperature2NameItem
		uid: root.bindPrefix + "/System/Temperature2Name"
	}
	VeQuickItem {
		id: temperature3Item
		uid: root.bindPrefix + "/System/Temperature3"
	}
	VeQuickItem {
		id: temperature3NameItem
		uid: root.bindPrefix + "/System/Temperature3Name"
	}
	VeQuickItem {
		id: temperature4Item
		uid: root.bindPrefix + "/System/Temperature4"
	}
	VeQuickItem {
		id: temperature4NameItem
		uid: root.bindPrefix + "/System/Temperature4Name"
	}

	GradientListView {
		model: VisibleItemModel {
			ListText {
				id: chargeModeItem
				text: "Charge Mode"
				dataItem.uid: root.bindPrefix + "/Info/ChargeMode"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				id: maxChargeVoltageItem
				//% "Charge Voltage Limit (CVL)"
				text: qsTrId("batteryparameters_charge_voltage_limit_cvl")
				dataItem.uid: root.bindPrefix + "/Info/MaxChargeVoltage"
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				id: chargeLimitationItem
				text: "Charge Limitation"
				dataItem.uid: root.bindPrefix + "/Info/ChargeLimitation"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				id: maxChargeCurrentItem
				//% "Charge Current Limit (CCL)"
				text: qsTrId("batteryparameters_charge_current_limit_ccl")
				dataItem.uid: root.bindPrefix + "/Info/MaxChargeCurrent"
				unit: VenusOS.Units_Amp
			}

			ListText {
				id: dischargeLimitationItem
				text: "Discharge Limitation"
				dataItem.uid: root.bindPrefix + "/Info/DischargeLimitation"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				id: maxDischargeCurrentItem
				//% "Discharge Current Limit (DCL)"
				text: qsTrId("batteryparameters_discharge_current_limit_dcl")
				dataItem.uid: root.bindPrefix + "/Info/MaxDischargeCurrent"
				unit: VenusOS.Units_Amp
			}

			ListItem {
				id: cellOverviewItem
				text: "Battery"
				content.children: [
					Row {
						id: contentRowOverview

						readonly property real itemWidth: (width - (spacing * 4)) / 5

						width: cellOverviewItem.maximumContentWidth
						spacing: Theme.geometry_listItem_content_spacing

						Column {
							width: contentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: currentItem.value ?? NaN
								unit: VenusOS.Units_Amp
								precision: 2
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: "Current"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: contentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: cellSumItem.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								precision: 2
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: "Voltage"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: contentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: cellMaxItem.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								precision: 3
								valueColor: chargeLimitationItem.dataItem.value.indexOf("Cell Voltage") !== -1 || dischargeLimitationItem.dataItem.value.indexOf("Cell Voltage") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: "Cell max"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: contentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: cellMinItem.value ?? NaN
								unit: VenusOS.Units_Volt_DC
								precision: 3
								valueColor: chargeLimitationItem.dataItem.value.indexOf("Cell Voltage") !== -1 || dischargeLimitationItem.dataItem.value.indexOf("Cell Voltage") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: "Cell min"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: contentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: socItem.value ?? NaN
								unit: VenusOS.Units_Percentage
								precision: 3
								valueColor: chargeLimitationItem.dataItem.value.indexOf("SoC") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: "SoC"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
					}
				]
			}

			ListItem {
				id: temperaturesOverviewItem
				text: "Battery"
				content.children: [
					Row {
						id: temperaturesContentRowOverview

						readonly property real itemWidth: (width - (spacing * 4)) / 5

						width: temperaturesOverviewItem.maximumContentWidth
						spacing: Theme.geometry_listItem_content_spacing

						Column {
							width: temperaturesContentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: temperatureMosItem.value ?? NaN
								unit: VenusOS.Units_Temperature_Celsius
								precision: 1
								valueColor: chargeLimitationItem.dataItem.value.indexOf("MOSFET") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: "MOSFET"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: temperaturesContentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: temperature1Item.value ?? NaN
								unit: VenusOS.Units_Temperature_Celsius
								precision: 1
								valueColor: chargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 || dischargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: temperature1NameItem.value ?? "Temp 1"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: temperaturesContentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: temperature2Item.value ?? NaN
								unit: VenusOS.Units_Temperature_Celsius
								precision: 1
								valueColor: chargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 || dischargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: temperature2NameItem.value ?? "Temp 2"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: temperaturesContentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: temperature3Item.value ?? NaN
								unit: VenusOS.Units_Temperature_Celsius
								precision: 1
								valueColor: chargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 || dischargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: temperature3NameItem.value ?? "Temp 3"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
						Column {
							width: temperaturesContentRowOverview.itemWidth

							QuantityLabel {
								width: parent.width
								value: temperature4Item.value ?? NaN
								unit: VenusOS.Units_Temperature_Celsius
								precision: 1
								valueColor: chargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 || dischargeLimitationItem.dataItem.value.indexOf("Temp") !== -1 ? "#BF4845" : Theme.color_font_primary
								font.pixelSize: 22
							}

							Label {
								width: parent.width
								horizontalAlignment: Text.AlignHCenter
								text: temperature4NameItem.value ?? "Temp 4"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
							}
						}
					}
				]
			}

			ListQuantity {
				//% "Low Voltage Disconnect (always ignored)"
				text: qsTrId("batteryparameters_low_voltage_disconnect_always_ignored")
				dataItem.uid: root.bindPrefix + "/Info/BatteryLowVoltage"
				showAccessLevel: VenusOS.User_AccessType_Service
				unit: VenusOS.Units_Volt_DC
			}

			ListItem {
				text: "Driver Debug"

				VeQuickItem {
					id: chargeModeDebug
					uid: root.bindPrefix + "/Info/ChargeModeDebug"
				}

				bottomContentChildren: [
					PrimaryListLabel {
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						text: chargeModeDebug.value
						horizontalAlignment: Text.AlignHCenter
					}
				]

				preferredVisible: chargeModeDebug.value !== undefined && chargeModeDebug.value !== ""
			}

			ListItem {
				text: "Driver Debug - Float"

				VeQuickItem {
					id: chargeModeDebugFloat
					uid: root.bindPrefix + "/Info/ChargeModeDebugFloat"
				}

				bottomContentChildren: [
					PrimaryListLabel {
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						text: chargeModeDebugFloat.value
						horizontalAlignment: Text.AlignHCenter
					}
				]

				preferredVisible: chargeModeDebugFloat.value !== undefined && chargeModeDebugFloat.value !== ""
			}

			ListItem {
				text: "Driver Debug - Bulk"

				VeQuickItem {
					id: chargeModeDebugBulk
					uid: root.bindPrefix + "/Info/ChargeModeDebugBulk"
				}

				bottomContentChildren: [
					PrimaryListLabel {
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						text: chargeModeDebugBulk.value
						horizontalAlignment: Text.AlignHCenter
					}
				]

				preferredVisible: chargeModeDebugBulk.value !== undefined && chargeModeDebugBulk.value !== ""
			}

		}
	}
}
