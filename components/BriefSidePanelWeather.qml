/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Rectangle {
	id: root

	// As per BriefSidePanelWidget: background is only shown in portrait.
	implicitWidth: weatherLayout.implicitWidth
	implicitHeight: weatherLayout.implicitHeight + (2 * Theme.geometry_sidePanel_sideWidget_verticalMargin)
	color: Theme.screenSize === Theme.Portrait ? Theme.color_background_secondary : "transparent"
	radius: Theme.geometry_button_radius

	ColumnLayout {
		id: weatherLayout

		anchors.centerIn: parent
		width: parent.width - (2 * Theme.geometry_sidePanel_sideWidget_horizontalMargin)
		spacing: Theme.geometry_sidePanel_weather_spacing_vertical

		WidgetHeader {
			icon.source: VenusOS.weather_conditionToIcon(Services.vrm.weatherCondition)
			//% "Outside"
			text: qsTrId("weather_outside")
			Layout.fillWidth: true
		}

		// Weather condition + temperature
		Label {
			QuantityLabel {
				id: temperatureLabel

				anchors.verticalCenter: parent.verticalCenter
				value: temperature.value ?? NaN
				unit: Services.settings.temperatureUnit
				unitColor: valueColor
				formatHints: Units.CompactUnitFormat

				VeQuickItem {
					id: temperature

					uid: Services.vrm.serviceUid + "/Weather/Temperature"
					sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
					displayUnit: Units.unitToVeUnit(Services.settings.temperatureUnit)
				}
			}

			leftPadding: temperatureLabel.width + Theme.geometry_sidePanel_weather_spacing_horizontal
			text: VenusOS.weather_conditionToText(Services.vrm.weatherCondition)
			elide: Text.ElideRight
			Layout.fillWidth: true
		}

		Label {
			//: %1 = date/time when the displayed weather information was received from the server
			//% "From VRM, %1"
			text: Services.vrm.heartbeat <= 0 ? ""
					: qsTrId("weather_from_vrm").arg(Utils.formatTimestamp(new Date(Services.vrm.heartbeat * 1000), ClockTime.dateTime))
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_size_tiny
			Layout.fillWidth: true
		}
	}
}