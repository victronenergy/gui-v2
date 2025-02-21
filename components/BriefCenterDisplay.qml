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

	property bool showFullDetails
	property bool smallTextMode

	readonly property string _serviceUid: centerService.value ?? ""
	readonly property bool _useTemperature: BackendConnection.serviceTypeFromUid(_serviceUid) === "temperature"

	VeQuickItem {
		id: centerService
		uid: Global.systemSettings.serviceUid + "/Settings/Gui2/BriefView/CenterService"
	}

	VeQuickItem {
		id: temperature
		uid: root._useTemperature ? root._serviceUid + "/Temperature" : ""
	}

	Row {
		anchors {
			horizontalCenter: parent.horizontalCenter
			horizontalCenterOffset: -(icon.width / 4) // cancel out the icon's internal whitespace
		}
		visible: root.showFullDetails

		CP.ColorImage {
			id: icon

			source: root._useTemperature ? "qrc:/images/icon_temp_32.svg" : Global.system.battery.icon
			color: Theme.color_font_primary
		}

		Label {
			// Keep the name bounding box inside the circle to avoid truncation
			width: Math.min(implicitWidth, 0.8 * (root.width - icon.width))
			anchors.verticalCenter: icon.verticalCenter
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_primary
			text: root._useTemperature ? CommonWords.temperature : CommonWords.battery
			elide: Text.ElideRight
		}
	}

	QuantityLabel {
		id: centerLabel

		anchors.horizontalCenter: parent.horizontalCenter
		height: root.smallTextMode ? centerLabelMetrics.ascent : implicitHeight
		font.pixelSize: {
			if (root._useTemperature) {
				return root.smallTextMode
					? Theme.font_briefPage_battery_temperature_minimumPixelSize
					: Theme.font_briefPage_battery_temperature_maximumPixelSize
			} else {
				return root.smallTextMode
					? Theme.font_briefPage_battery_percentage_minimumPixelSize
					: Theme.font_briefPage_battery_percentage_maximumPixelSize
			}
		}
		unit: root._useTemperature ? Global.systemSettings.temperatureUnit : VenusOS.Units_Percentage
		value: root._useTemperature
			   ? Global.systemSettings.convertFromCelsius(temperature.value ?? NaN)
			   : Global.system.battery.stateOfCharge

		FontMetrics {
			id: centerLabelMetrics
			font: centerLabel.font
		}
	}

	Loader {
		width: parent.width
		height: active ? implicitHeight : 0
		active: root.showFullDetails && !root._useTemperature

		sourceComponent: Column {
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Theme.geometry_briefPage_centerGauge_centerText_horizontalSpacing

				QuantityLabel {
					valueColor: Theme.color_briefPage_battery_value_text_color
					unitColor: Theme.color_briefPage_battery_unit_text_color
					font.pixelSize: Theme.font_briefPage_battery_voltage_pixelSize
					unit: VenusOS.Units_Volt_DC
					value: Global.system.battery.voltage
				}

				QuantityLabel {
					readonly property bool unitAmps: (Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && !isNaN(Global.system.battery.current))
							|| (!isNaN(Global.system.battery.current) && isNaN(Global.system.battery.power))
					valueColor: Theme.color_briefPage_battery_value_text_color
					unitColor: Theme.color_briefPage_battery_unit_text_color
					font.pixelSize: Theme.font_briefPage_battery_voltage_pixelSize
					value: unitAmps ? Global.system.battery.current : Global.system.battery.power
					unit: unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
				}
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				font.pixelSize: Theme.font_briefPage_battery_timeToGo_pixelSize
				color: Theme.color_briefPage_battery_value_text_color
				text: Utils.formatBatteryTimeToGo(Global.system.battery.timeToGo, VenusOS.Battery_TimeToGo_LongFormat)
				visible: text.length > 0
			}
		}
	}
}
