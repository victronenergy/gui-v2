/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import "/components/Units.js" as Units

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
		? Theme.geometry.levelsPage.environment.gaugePanel.twoGauge.compact.width
		: Theme.geometry.levelsPage.environment.gaugePanel.oneGauge.compact.width
	readonly property int compactHeight: Theme.geometry.levelsPage.environment.gaugePanel.compact.height
	readonly property int expandedWidth: _twoGauges
		? Theme.geometry.levelsPage.environment.gaugePanel.twoGauge.expanded.width
		: Theme.geometry.levelsPage.environment.gaugePanel.oneGauge.expanded.width
	readonly property int expandedHeight: Theme.geometry.levelsPage.environment.gaugePanel.expanded.height

	readonly property int _twoGauges: !isNaN(temperature) && !isNaN(humidity)
	readonly property int _gaugeWidth: _twoGauges
			? (width - (2 * Theme.geometry.levelsPage.environment.gaugePanel.border.width)) / 2
			: Theme.geometry.levelsPage.environment.gauge.width

	width: horizontalSize === VenusOS.EnvironmentGaugePanel_Size_Expanded ? expandedWidth : compactWidth
	height: verticalSize === VenusOS.EnvironmentGaugePanel_Size_Expanded ? expandedHeight : compactHeight

	color: Theme.color.levelsPage.environment.panel.border.color
	radius: Theme.geometry.levelsPage.environment.gaugePanel.radius

	Behavior on height {
		enabled: root.animationEnabled
		NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
	}

	Rectangle {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.levelsPage.environment.gaugePanel.title.height
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
			bottom: parent.bottom
			bottomMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
		}
		radius: Theme.geometry.levelsPage.environment.gaugePanel.innerRadius
		color: Theme.color.levelsPage.environment.panel.background
	}

	Label {
		id: titleLabel

		width: parent.width
		height: Theme.geometry.levelsPage.environment.gaugePanel.title.height
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		leftPadding: Theme.geometry.levelsPage.environment.gaugePanel.border.width
		rightPadding: Theme.geometry.levelsPage.environment.gaugePanel.border.width

		font.pixelSize: Theme.font.size.caption
		color: Theme.color.levelsPage.environment.panel.title
		elide: Text.ElideRight
	}

	EnvironmentGauge {
		id: tempGauge

		anchors {
			top: titleLabel.bottom
			left: humidityGaugeLoader.active ? parent.left : undefined
			leftMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
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
				? Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue
				: Units.celsiusToFahrenheit(Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue)
		maximumValue: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
				? Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue
				: Units.celsiusToFahrenheit(Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue)
		highlightedValue: Theme.geometry.levelsPage.environment.temperatureGauge.highlightedValue
		minimumValueColor: Theme.color.blue
		maximumValueColor: Theme.color.red
		highlightedValueColor: Theme.color.levelsPage.environment.temperatureGauge.highlightValue
		gradient: root.temperatureGaugeGradient
	}

	Loader {
		id: humidityGaugeLoader

		anchors {
			top: titleLabel.bottom
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
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
			minimumValue: Theme.geometry.levelsPage.environment.humidityGauge.minimumValue
			maximumValue: Theme.geometry.levelsPage.environment.humidityGauge.maximumValue
			highlightedValue: Theme.geometry.levelsPage.environment.humidityGauge.highlightedValue
			minimumValueColor: Theme.color.orange
			maximumValueColor: Theme.color.blue
			highlightedValueColor: Theme.color.green
			gradient: root.humidityGaugeGradient
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load himidity environment gauge:", errorString())
	}
}
