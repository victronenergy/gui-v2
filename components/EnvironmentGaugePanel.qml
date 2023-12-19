/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Rectangle {
	id: root

	property alias title: titleLabel.text
	property real temperature: NaN
	property real humidity: NaN
	property int horizontalSize: VenusOS.EnvironmentGaugePanel_Size_Expanded
	property int verticalSize: VenusOS.EnvironmentGaugePanel_Size_Expanded
	property bool animationEnabled: true

	property var temperatureGaugeGradient
	property var humidityGaugeGradient

	readonly property int compactWidth: _twoGauges
		? Theme.geometry_levelsPage_environment_gaugePanel_twoGauge_compact_width
		: Theme.geometry_levelsPage_environment_gaugePanel_oneGauge_compact_width
	readonly property int compactHeight: Theme.geometry_levelsPage_environment_gaugePanel_compact_height
	readonly property int expandedWidth: _twoGauges
		? Theme.geometry_levelsPage_environment_gaugePanel_twoGauge_expanded_width
		: Theme.geometry_levelsPage_environment_gaugePanel_oneGauge_expanded_width
	readonly property int expandedHeight: Theme.geometry_levelsPage_environment_gaugePanel_expanded_height

	readonly property int _twoGauges: !isNaN(temperature) && !isNaN(humidity)
	readonly property int _gaugeWidth: _twoGauges
			? (width - (2 * Theme.geometry_levelsPage_environment_gaugePanel_border_width)) / 2
			: Theme.geometry_levelsPage_environment_gauge_width

	width: horizontalSize === VenusOS.EnvironmentGaugePanel_Size_Expanded ? expandedWidth : compactWidth
	height: verticalSize === VenusOS.EnvironmentGaugePanel_Size_Expanded ? expandedHeight : compactHeight

	color: Theme.color_levelsPage_environment_panel_border_color
	radius: Theme.geometry_levelsPage_environment_gaugePanel_radius

	Behavior on height {
		enabled: root.animationEnabled
		NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
	}

	Rectangle {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_levelsPage_environment_gaugePanel_title_height
			left: parent.left
			leftMargin: Theme.geometry_levelsPage_environment_gaugePanel_border_width
			right: parent.right
			rightMargin: Theme.geometry_levelsPage_environment_gaugePanel_border_width
			bottom: parent.bottom
			bottomMargin: Theme.geometry_levelsPage_environment_gaugePanel_border_width
		}
		radius: Theme.geometry_levelsPage_environment_gaugePanel_innerRadius
		color: Theme.color_levelsPage_environment_panel_background
	}

	Label {
		id: titleLabel

		width: parent.width
		height: Theme.geometry_levelsPage_environment_gaugePanel_title_height
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		leftPadding: Theme.geometry_levelsPage_environment_gaugePanel_border_width
		rightPadding: Theme.geometry_levelsPage_environment_gaugePanel_border_width

		font.pixelSize: Theme.font_size_caption
		color: Theme.color_levelsPage_environment_panel_title
		elide: Text.ElideRight
	}

	EnvironmentGauge {
		id: tempGauge

		anchors {
			top: titleLabel.bottom
			left: humidityGaugeLoader.active ? parent.left : undefined
			leftMargin: Theme.geometry_levelsPage_environment_gaugePanel_border_width
			bottom: parent.bottom
			horizontalCenter: humidityGaugeLoader.active ? undefined : parent.horizontalCenter
		}
		width: root._gaugeWidth
		animationEnabled: root.animationEnabled
		icon.source: "qrc:/images/icon_temp_32.svg"

		text: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Fahrenheit ? "F" : "C"
		value: Math.round(root.temperature)
		unit: Global.systemSettings.temperatureUnit.value

		// TODO min, max and highlight need to come from dbus backend, but not yet available.
		minimumValue: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
				? Theme.geometry_levelsPage_environment_temperatureGauge_minimumValue
				: Units.celsiusToFahrenheit(Theme.geometry_levelsPage_environment_temperatureGauge_minimumValue)
		maximumValue: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
				? Theme.geometry_levelsPage_environment_temperatureGauge_maximumValue
				: Units.celsiusToFahrenheit(Theme.geometry_levelsPage_environment_temperatureGauge_maximumValue)
		highlightedValue: Theme.geometry_levelsPage_environment_temperatureGauge_highlightedValue
		minimumValueColor: Theme.color_blue
		maximumValueColor: Theme.color_red
		highlightedValueColor: Theme.color_levelsPage_environment_temperatureGauge_highlightValue
		gradient: root.temperatureGaugeGradient
	}

	Loader {
		id: humidityGaugeLoader

		anchors {
			top: titleLabel.bottom
			right: parent.right
			rightMargin: Theme.geometry_levelsPage_environment_gaugePanel_border_width
			bottom: parent.bottom
		}

		active: !isNaN(root.humidity)
		sourceComponent: EnvironmentGauge {
			id: humidityGauge

			width: root._gaugeWidth
			icon.source: "qrc:/images/icon_humidity_32.svg"
			//: Abbreviation of "Room Humidity"
			//% "RH"
			text: qsTrId("environment_gauge_humidity")
			animationEnabled: root.animationEnabled
			unit: VenusOS.Units_Percentage
			value: Math.round(root.humidity)
			minimumValue: Theme.geometry_levelsPage_environment_humidityGauge_minimumValue
			maximumValue: Theme.geometry_levelsPage_environment_humidityGauge_maximumValue
			highlightedValue: Theme.geometry_levelsPage_environment_humidityGauge_highlightedValue
			minimumValueColor: Theme.color_orange
			maximumValueColor: Theme.color_blue
			highlightedValueColor: Theme.color_green
			gradient: root.humidityGaugeGradient
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load himidity environment gauge:", errorString())
	}
}
