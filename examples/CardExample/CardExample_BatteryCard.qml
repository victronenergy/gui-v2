/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

PluginCard {
	id: root

	// The fluid type that a tank gives for fresh water.
	readonly property int freshWaterFluidType: 1

	// The level of the emptiest fresh water tank, or NaN if there is none. It reads every tank, as a
	// binding is not updated when the tanks only change their order.
	readonly property real freshWaterLevel: {
		let lowest = NaN
		for (let i = 0; i < tanks.count; ++i) {
			const tank = tanks.objectAt(i)
			if (tank && tank.fluidType.valid && tank.fluidType.value === freshWaterFluidType
					&& tank.level.valid) {
				lowest = isNaN(lowest) ? tank.level.value : Math.min(lowest, tank.level.value)
			}
		}
		return lowest
	}

	// A row with a name on the left and a value next to it. Items declared inside the row are
	// placed on the right. The row is not a list item, so set its x to the card's contentMargin: the
	// row then keeps the same margin on the right.
	component SummaryRow: Item {
		default property alias details: detailRow.data
		property alias text: nameLabel.text
		property alias quantity: valueLabel

		width: parent ? parent.width - 2 * x : 0
		implicitHeight: Math.max(nameLabel.implicitHeight, valueLabel.implicitHeight, detailRow.implicitHeight)

		PluginLabel {
			id: nameLabel

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width / 3
			color: PluginPalette.color_font_secondary
			elide: Text.ElideRight
		}

		PluginQuantityLabel {
			id: valueLabel

			anchors.left: nameLabel.right
			anchors.verticalCenter: parent.verticalCenter
			decimals: 0
		}

		Row {
			id: detailRow

			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 4
		}
	}

	//% "Plugin dashboard"
	title: qsTrId("cardexample_title")
	iconSource: Qt.resolvedUrl("icon_brick.svg")

	SummaryRow {
		x: root.contentMargin
		text: PluginWords.battery
		quantity.dataItem.serviceType: "system"
		quantity.dataItem.path: "/Dc/Battery/Soc"
		quantity.unit: PluginUnit.Percentage
		quantity.valueColor: isNaN(quantity.value) ? PluginPalette.color_font_primary
			: quantity.value <= 15 ? PluginPalette.color_critical
			: quantity.value <= 30 ? PluginPalette.color_warning
			: PluginPalette.color_success

		PluginLabel {
			text: {
				if (!batteryPower.valid || batteryPower.value === 0) {
					return ""
				}
				// Positive battery power is charging.
				return batteryPower.value > 0
					//% "Charging"
					? qsTrId("cardexample_charging")
					//% "Discharging"
					: qsTrId("cardexample_discharging")
			}
			fontSize: PluginPalette.font_size_small
			color: PluginPalette.color_font_secondary
		}

		PluginQuantityLabel {
			visible: batteryPower.valid
			value: Math.abs(batteryPower.value)
			unit: PluginUnit.Watt
			decimals: 0
			fontSize: PluginPalette.font_size_small
			valueColor: PluginPalette.color_font_secondary
		}
	}

	// The power from the solar chargers. Solar power from PV inverters on AC is not included.
	SummaryRow {
		x: root.contentMargin
		//% "Solar"
		text: qsTrId("cardexample_solar")
		quantity.dataItem.serviceType: "system"
		quantity.dataItem.path: "/Dc/Pv/Power"
		quantity.unit: PluginUnit.Watt
		quantity.valueColor: quantity.value > 0 ? PluginPalette.color_success : PluginPalette.color_font_primary

		PluginLabel {
			visible: solarChargers.count > 0
			//% "%1 MPPT"
			text: qsTrId("cardexample_mppt_count").arg(solarChargers.count)
			fontSize: PluginPalette.font_size_small
			color: PluginPalette.color_font_secondary
		}
	}

	SummaryRow {
		x: root.contentMargin
		//% "Water"
		text: qsTrId("cardexample_water")
		quantity.value: root.freshWaterLevel
		quantity.unit: PluginUnit.Percentage
		quantity.valueColor: isNaN(quantity.value) ? PluginPalette.color_font_primary : PluginPalette.color_success

		PluginLabel {
			//% "fresh"
			text: qsTrId("cardexample_fresh")
			fontSize: PluginPalette.font_size_small
			color: PluginPalette.color_font_secondary
		}
	}

	// The pump is not real: the switch only changes its own 'checked'.
	PluginListSwitch {
		flat: true
		//% "Water pump"
		text: qsTrId("cardexample_water_pump")
		checkable: true
		writeAccessLevel: PluginAccessLevel.User
	}

	PluginDataItem {
		id: batteryPower

		serviceType: "system"
		path: "/Dc/Battery/Power"
	}

	PluginDeviceModel {
		id: solarChargers

		serviceTypes: ["solarcharger"]
	}

	// A tank's row does not give its fluid type, so each tank has its own data items for it.
	Instantiator {
		id: tanks

		model: PluginDeviceModel {
			serviceTypes: ["tank"]
			requiredPaths: ["FluidType", "Level"]
		}
		delegate: QtObject {
			required property string serviceUid

			readonly property PluginDataItem fluidType: PluginDataItem {
				uid: serviceUid + "/FluidType"
			}
			readonly property PluginDataItem level: PluginDataItem {
				uid: serviceUid + "/Level"
			}
		}
	}
}
