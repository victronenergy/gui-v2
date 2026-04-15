/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AbstractListItem {
	id: root

	required property Device device
	required property bool animationEnabled

	required property Gradient temperatureGaugeGradient
	required property Gradient humidityGaugeGradient

	readonly property bool hasTwoGauges: !isNaN(temperatureItem.value) && !isNaN(humidityItem.value)

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	leftInset: Theme.geometry_levelsPage_panel_horizontalInset
	rightInset: Theme.geometry_levelsPage_panel_horizontalInset
	leftPadding: leftInset + Theme.geometry_levelsGauge_horizontalPadding
	rightPadding: rightInset + Theme.geometry_levelsGauge_horizontalPadding
	topPadding: Theme.geometry_levelsPage_panel_header_height + Theme.geometry_environmentGaugePanel_verticalPadding
	bottomPadding: Theme.geometry_environmentGaugePanel_verticalPadding

	background: Item {
		implicitWidth: Theme.geometry_levelsPage_panel_background_width
		implicitHeight: Theme.geometry_levelsPage_panel_background_height

		// The colour indicator is on the top in landscape, and not visible in portrait.
		Rectangle {
			id: colorIndicator

			width: parent.width
			height: Theme.geometry_levelsPage_panel_header_height
			topLeftRadius: Theme.geometry_levelsPage_panel_radius
			topRightRadius: Theme.geometry_levelsPage_panel_radius
			color: Theme.color_environmentGaugePanel_header
			visible: Theme.screenSize !== Theme.Portrait

			Label {
				anchors {
					left: parent.left
					right: parent.right
					bottom: parent.bottom
					margins: Theme.geometry_levelsPage_panel_background_title_padding
				}
				horizontalAlignment: Text.AlignHCenter
				elide: Text.ElideRight
				text: root.device?.name ?? ""
			}
		}

		// Fill out the rest of the background with a background colour.
		Rectangle {
			anchors {
				fill: parent
				topMargin: Theme.geometry_levelsPage_panel_header_height
			}
			border.color: Theme.screenSize === Theme.Portrait ? "transparent" : Theme.color_environmentGaugePanel_header
			color: Theme.color_environmentGaugePanel_background
			topLeftRadius: colorIndicator.visible ? 0 : Theme.geometry_levelsPage_panel_radius
			topRightRadius: colorIndicator.visible ? 0 : Theme.geometry_levelsPage_panel_radius
			bottomLeftRadius: Theme.geometry_levelsPage_panel_radius
			bottomRightRadius: Theme.geometry_levelsPage_panel_radius
		}
	}

	contentItem: Item {
		// In landscape, stretch the height to fill the parent.
		// In portrait, size the height to the gauge content.
		implicitHeight: Theme.screenSize !== Theme.Portrait ? 0
				: (nameLabel.text.length ? nameLabel.height : 0) + gaugeFlow.height

		// In portrait, if there are two gauges, show the name here instead of within the outline.
		Label {
			id: nameLabel

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_icon_size_medium + Theme.geometry_levelsGauge_horizontalSpacing
				right: parent.right
			}
			font.pixelSize: Theme.font_size_body1
			wrapMode: Text.Wrap
			text: Theme.screenSize === Theme.Portrait && root.hasTwoGauges ? root.device?.name ?? "" : ""
			color: Theme.color_font_primary
		}

		Flow {
			id: gaugeFlow

			readonly property int gaugeWidth: Theme.screenSize === Theme.Portrait ? parent.width
					: hasTwoGauges ? (parent.width - (2 * Theme.geometry_levelsPage_panel_border_width)) / 2
					: Theme.geometry_environmentGauge_width

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: nameLabel.text.length ? nameLabel.bottom : undefined
			}
			width: Theme.screenSize === Theme.Portrait ? parent.width
					: root.hasTwoGauges ? gaugeWidth * 2
					: gaugeWidth
			flow: Theme.screenSize === Theme.Portrait ? Flow.TopToBottom : Flow.LeftToRight
			spacing: Theme.screenSize === Theme.Portrait ? Theme.geometry_levelsGauge_verticalPadding : 0

			LevelsGaugeOutline {
				width: gaugeFlow.gaugeWidth
				height: Theme.screenSize === Theme.Portrait ? implicitHeight : gaugeFlow.parent.height
				name: root.hasTwoGauges ? "" : (root.device?.name ?? "")
				iconSource: "qrc:/images/icon_temp_32.svg"
				value: temperatureItem.valid ? Math.round(temperatureItem.value) : NaN
				unit: Global.systemSettings.temperatureUnit
				unitText: Units.defaultUnitString(Global.systemSettings.temperatureUnit)
				quantityFormatHints: Theme.screenSize === Theme.Portrait ? 0 : Units.CompactUnitFormat
				gaugeHorizontalPadding: Theme.geometry_environmentGauge_gauge_horizontalPadding

				gauge: EnvironmentGauge {
					orientation: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical
					value: temperatureItem.value ?? NaN
					minimumValue: Global.environmentInputs.temperatureGaugeMinimum(root.temperatureType)
					maximumValue: Global.environmentInputs.temperatureGaugeMaximum(root.temperatureType)
					stepSize: Global.environmentInputs.temperatureGaugeStepSize(root.temperatureType)
					highlightedValue: Theme.geometry_levelsPage_environment_temperatureGauge_highlightedValue
					minimumValueColor: Theme.color_blue
					maximumValueColor: Theme.color_red
					highlightedValueColor: Theme.color_levelsPage_environment_temperatureGauge_highlightValue
					gradient: root.temperatureGaugeGradient
					animationEnabled: root.animationEnabled
				}
			}

			LevelsGaugeOutline {
				width: gaugeFlow.gaugeWidth
				height: Theme.screenSize === Theme.Portrait ? implicitHeight : gaugeFlow.parent.height
				visible: !isNaN(humidityItem.value)
				name: root.hasTwoGauges ? "" : (root.device?.name ?? "")
				iconSource: "qrc:/images/icon_humidity_32.svg"
				value: humidityItem.valid ? Math.round(humidityItem.value) : NaN
				unit: VenusOS.Units_Percentage
				// Don't translate. Short local acronyms often don't exist. RH is an international standard.
				// In case user is not familiar with the acronym "RH" there is also drop icon and percentage sign (%).
				unitText: "RH"
				quantityFormatHints: Theme.screenSize === Theme.Portrait ? 0 : Units.CompactUnitFormat
				gaugeHorizontalPadding: Theme.geometry_environmentGauge_gauge_horizontalPadding
				gauge: isNaN(humidityItem.value) ? null : humidityGaugeComponent

				Component {
					id: humidityGaugeComponent

					EnvironmentGauge {
						orientation: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical
						value: humidityItem.value ?? NaN
						minimumValue: Theme.geometry_levelsPage_environment_humidityGauge_minimumValue
						maximumValue: Theme.geometry_levelsPage_environment_humidityGauge_maximumValue
						stepSize: Theme.geometry_environmentGauge_tick_step
						highlightedValue: Theme.geometry_levelsPage_environment_humidityGauge_highlightedValue
						minimumValueColor: Theme.color_orange
						maximumValueColor: Theme.color_blue
						highlightedValueColor: Theme.color_green
						gradient: root.humidityGaugeGradient
						animationEnabled: root.animationEnabled
					}
				}
			}
		}

		VeQuickItem {
			id: temperatureType
			readonly property int intValue: valid ? value : VenusOS.Temperature_DeviceType_Generic
			uid: root.device ? root.device.serviceUid + "/TemperatureType" : ""
		}
	}

	VeQuickItem {
		id: humidityItem
		uid: root.device ? root.device.serviceUid + "/Humidity" : ""
	}

	VeQuickItem {
		id: temperatureItem
		uid: root.device ? root.device.serviceUid + "/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}
}
