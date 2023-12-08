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

	property alias icon: icon
	property alias name: nameLabel.text
	property alias voltage: voltageLabel.value
	property alias current: currentLabel.value
	property alias value: arc.value
	property int status
	property alias caption: captionLabel.text
	property alias animationEnabled: arc.animationEnabled
	property alias shineAnimationEnabled: arc.shineAnimationEnabled

	// The single circular gauge is always the battery gauge :. shiny.
	ShaderCircularGauge {
		id: arc

		width: gauges.width
		height: width
		anchors.centerIn: parent
		startAngle: 0
		endAngle: 359 // "Note that a single PathArc cannot be used to specify a circle."
		progressColor: Theme.statusColorValue(gauges.status)
		remainderColor: Theme.statusColorValue(gauges.status, true)
		strokeWidth: Theme.geometry.circularSingularGauge.strokeWidth
	}

	Column {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.centerGauge.centerText.topMargin
			horizontalCenter: parent.horizontalCenter
		}
		spacing: Theme.geometry.briefPage.centerGauge.centerTextSpacing

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			CP.ColorImage {
				id: icon

				color: Theme.color.font.primary
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
			Label {
				id: nameLabel

				anchors.verticalCenter: icon.verticalCenter
				font.pixelSize: Theme.font.size.body2
				color: Theme.color.font.primary
			}
		}

		QuantityLabel {
			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font.briefPage.battery.percentage.pixelSize
			unit: VenusOS.Units_Percentage
			value: gauges.value
		}

		Row {
			topPadding: Theme.geometry.briefPage.centerGauge.centerText.topPadding
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: Theme.geometry.briefPage.centerGauge.centerText.horizontalSpacing

			QuantityLabel {
				id: voltageLabel

				valueColor: Theme.color.briefPage.battery.value.text.color
				unitColor: Theme.color.briefPage.battery.unit.text.color
				font.pixelSize: Theme.font.briefPage.battery.voltage.pixelSize
				unit: VenusOS.Units_Volt
			}
			QuantityLabel {
				id: currentLabel

				valueColor: Theme.color.briefPage.battery.value.text.color
				unitColor: Theme.color.briefPage.battery.unit.text.color
				font.pixelSize: Theme.font.briefPage.battery.voltage.pixelSize
				unit: VenusOS.Units_Amp
			}
		}

		Label {
			id: captionLabel

			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font.briefPage.battery.timeToGo.pixelSize
			color: Theme.color.briefPage.battery.value.text.color
		}
	}
}
