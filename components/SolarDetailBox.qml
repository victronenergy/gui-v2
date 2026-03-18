/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Rectangle {
	id: root

	property real minBatteryVoltage
	property real maxBatteryVoltage
	property real maxBatteryCurrent

	property real timeInBulk
	property real timeInAbsorption
	property real timeInFloat

	property int bodyFontSize: Theme.font_size_body2

	function _formatTime(minutes) {
		if (isNaN(minutes)) {
			return "--"
		} else {
			return Math.floor(minutes / 60) + ":" + Utils.pad(minutes % 60, 2)
		}
	}

	implicitHeight: contentLayout.height
	border.width: Theme.geometry_solarDetailBox_border_width
	border.color: Theme.color_solarDetailBox_border
	color: "transparent"
	radius: Theme.geometry_solarDetailBox_border_radius

	// Landscape layout:
	// | Battery                                | Charge time            |
	// | MinVoltage  MaxVoltage  MaxCurrent     | Bulk   Abs   Float     |
	//
	// Portrait layout:
	// | Battery                            |
	// | MinVoltage  MaxVoltage  MaxCurrent |
	// --------------------------------------
	// | Charge time                        |
	// | Bulk        Abs         Float      |
	Grid {
		id: contentLayout

		x: Theme.geometry_solarDetailBox_horizontalPadding
		width: parent.width - (2 * Theme.geometry_solarDetailBox_horizontalPadding)
		spacing: Theme.geometry_solarDetailBox_separator_horizontalMargin
		topPadding: Theme.geometry_solarDetailBox_verticalPadding
		bottomPadding: Theme.geometry_solarDetailBox_verticalPadding
		rows: Theme.screenSize === Theme.Portrait ? 3 : 1

		GridLayout {
			id: batteryDetailsLayout

			width: Theme.screenSize === Theme.Portrait ? parent.width : parent.width / 2
			rows: 2
			columns: 3
			columnSpacing: 0
			rowSpacing: 0

			DetailHeader {
				text: CommonWords.battery
			}

			BatteryDetail {
				//% "Min Voltage"
				title: qsTrId("charger_history_box_min_voltage")
				value: root.minBatteryVoltage
				unit: VenusOS.Units_Volt_DC
			}

			BatteryDetail {
				//% "Max Voltage"
				title: qsTrId("charger_history_box_max_voltage")
				value: root.maxBatteryVoltage
				unit: VenusOS.Units_Volt_DC
			}

			BatteryDetail {
				//% "Max Current"
				title: qsTrId("charger_history_box_max_current")
				value: root.maxBatteryCurrent
				unit: VenusOS.Units_Amp
			}
		}

		Rectangle {
			color: Theme.color_solarDetailBox_border
			width: Theme.screenSize === Theme.Portrait ? root.width : 1
			height: Theme.screenSize === Theme.Portrait ? 1 : batteryDetailsLayout.height
		}

		GridLayout {
			width: Theme.screenSize === Theme.Portrait ? parent.width : parent.width / 2
			rows: 2
			columns: 3
			columnSpacing: 0
			rowSpacing: 0

			DetailHeader {
				//: Statistics for battery charging time
				//% "Charge time"
				text: qsTrId("charger_history_charge_time")
			}

			TimeDetail {
				//: Battery: time spent in 'Bulk' mode
				//% "Bulk"
				title: qsTrId("charger_history_box_bulk")
				value: root.timeInBulk
			}

			TimeDetail {
				//: Battery: time spent in 'Absorption' mode
				//% "Abs"
				title: qsTrId("charger_history_box_abs")
				value: root.timeInAbsorption
			}

			TimeDetail {
				//: Battery: time spent in 'Float' mode
				//% "Float"
				title: qsTrId("charger_history_box_float")
				value: root.timeInFloat
			}
		}
	}

	component DetailHeader : Label {
		elide: Text.ElideRight
		font.pixelSize: Theme.font_solarDetailBox_header_size
		color: Theme.color_solarDetailBox_columnTitle

		Layout.columnSpan: 3
		Layout.bottomMargin: Theme.geometry_solarDetailBox_header_bottomPadding
	}

	component BatteryDetail : ColumnLayout {
		id: batteryDetail

		required property string title
		required property real value
		required property int unit

		spacing: Theme.geometry_solarDetailBox_title_bottomPadding
		Layout.fillWidth: true

		Label {
			elide: Text.ElideRight
			font.pixelSize: Theme.font_size_tiny
			text: batteryDetail.title
			color: Theme.color_solarDetailBox_quantityTitle
		}

		QuantityLabel {
			value: batteryDetail.value
			unit: batteryDetail.unit
			font.pixelSize: root.bodyFontSize
		}
	}

	component TimeDetail : ColumnLayout {
		id: timeDetail

		required property string title
		required property real value

		spacing: Theme.geometry_solarDetailBox_title_bottomPadding
		Layout.fillWidth: true

		Label {
			elide: Text.ElideRight
			font.pixelSize: Theme.font_size_tiny
			text: timeDetail.title
			color: Theme.color_solarDetailBox_quantityTitle
		}

		Label {
			rightPadding: hourLabel.width + Theme.geometry_quantityLabel_spacing
			text: root._formatTime(timeDetail.value)
			font.pixelSize: root.bodyFontSize

			Label {
				id: hourLabel

				anchors.right: parent.right
				//: Abbreviation of "hour"
				//% "hr"
				text: qsTrId("charger_history_hr")
				font.pixelSize: root.bodyFontSize
				color: Theme.color_font_secondary
			}
		}
	}
}
