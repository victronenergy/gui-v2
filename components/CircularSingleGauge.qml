/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Item {
	id: gauges

	property alias voltage: voltageLabel.value
	property alias current: currentLabel.value
	property alias value: arc.value
	property int status
	property alias caption: captionLabel.text
	property alias animationEnabled: arc.animationEnabled
	property alias shineAnimationEnabled: arc.shineAnimationEnabled

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: true
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		// The single circular gauge is always the battery gauge :. shiny.
		ShinyProgressArc {
			id: arc

			width: gauges.width
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 359 // "Note that a single PathArc cannot be used to specify a circle."
			progressColor: Theme.color_darkOk,Theme.statusColorValue(gauges.status)
			remainderColor: Theme.color_darkOk,Theme.statusColorValue(gauges.status, true)
			strokeWidth: Theme.geometry_circularSingularGauge_strokeWidth
		}
	}

	Column {
		anchors {
			top: centerValue.isTemperature ? undefined : parent.top
			topMargin: centerValue.isTemperature ? undefined : Theme.geometry_briefPage_centerGauge_centerText_topMargin
			verticalCenter: centerValue.isTemperature ? parent.verticalCenter : undefined
			horizontalCenter: parent.horizontalCenter
		}
		spacing: Theme.geometry_briefPage_centerGauge_centerTextSpacing

		CenterValueDisplay {
			id: centerValue
			anchors.horizontalCenter: parent.horizontalCenter
			maximumWidth: 0.7*gauges.width - icon.width
			gaugeCount: 1
		}

		Row {
			visible: !centerValue.isTemperature
			topPadding: Theme.geometry_briefPage_centerGauge_centerText_topPadding
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: Theme.geometry_briefPage_centerGauge_centerText_horizontalSpacing

			QuantityLabel {
				id: voltageLabel

				valueColor: Theme.color_briefPage_battery_value_text_color
				unitColor: Theme.color_briefPage_battery_unit_text_color
				font.pixelSize: Theme.font_briefPage_battery_voltage_pixelSize
				unit: VenusOS.Units_Volt_DC
			}
			QuantityLabel {
				id: currentLabel

				valueColor: Theme.color_briefPage_battery_value_text_color
				unitColor: Theme.color_briefPage_battery_unit_text_color
				font.pixelSize: Theme.font_briefPage_battery_voltage_pixelSize
				unit: VenusOS.Units_Amp
			}
		}

		Label {
			id: captionLabel

			visible: !centerValue.isTemperature
			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font_briefPage_battery_timeToGo_pixelSize
			color: Theme.color_briefPage_battery_value_text_color
		}
	}
}
