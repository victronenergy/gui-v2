/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Column {
	id: root

	readonly property SystemBattery battery: Global.system.battery
	property bool showAllDetails
	property bool smallTextMode

	Row {
		anchors {
			horizontalCenter: parent.horizontalCenter
			horizontalCenterOffset: -(icon.width / 4) // cancel out the icon's internal whitespace
		}
		visible: root.showAllDetails

		CP.ColorImage {
			id: icon

			source: root.battery.icon
			color: Theme.color_font_primary
		}

		Label {
			// Keep the name bounding box inside the circle to avoid truncation
			width: Math.min(implicitWidth, 0.8 * (root.width - icon.width))
			anchors.verticalCenter: icon.verticalCenter
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_primary
			text: CommonWords.battery
			elide: Text.ElideRight
		}
	}

	QuantityLabel {
		id: centerLabel

		anchors.horizontalCenter: parent.horizontalCenter
		height: root.smallTextMode ? centerLabelMetrics.ascent : implicitHeight
		font.pixelSize: root.smallTextMode
				? Theme.font_briefPage_battery_percentage_minimumPixelSize
				: Theme.font_briefPage_battery_percentage_maximumPixelSize
		unit: VenusOS.Units_Percentage
		value: root.battery.stateOfCharge

		FontMetrics {
			id: centerLabelMetrics
			font: centerLabel.font
		}
	}

	Row {
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Theme.geometry_briefPage_centerGauge_centerText_horizontalSpacing
		visible: root.showAllDetails

		QuantityLabel {
			valueColor: Theme.color_briefPage_battery_value_text_color
			unitColor: Theme.color_briefPage_battery_unit_text_color
			font.pixelSize: Theme.font_briefPage_battery_voltage_pixelSize
			unit: VenusOS.Units_Volt_DC
			value: root.battery.voltage
		}

		QuantityLabel {
			readonly property bool unitAmps: (Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && !isNaN(root.battery.current))
					|| (!isNaN(root.battery.current) && isNaN(root.battery.power))
			valueColor: Theme.color_briefPage_battery_value_text_color
			unitColor: Theme.color_briefPage_battery_unit_text_color
			font.pixelSize: Theme.font_briefPage_battery_voltage_pixelSize
			value: unitAmps ? root.battery.current : root.battery.power
			unit: unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
		}
	}

	Label {
		anchors.horizontalCenter: parent.horizontalCenter
		font.pixelSize: Theme.font_briefPage_battery_timeToGo_pixelSize
		color: Theme.color_briefPage_battery_value_text_color
		text: Utils.formatBatteryTimeToGo(root.battery.timeToGo, VenusOS.Battery_TimeToGo_LongFormat)
	}
}
