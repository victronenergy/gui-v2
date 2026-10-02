/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

LevelsTab {
	id: root

	readonly property int twoGaugeWidth: Gauges.width(Global.environmentInputs.model.count, 4, Theme.geometry_screen_width)
	readonly property int oneGaugeWidth: Gauges.width(Global.environmentInputs.model.count, 6, Theme.geometry_screen_width)

	model: Global.environmentInputs.model
	delegate: Item {
		id: environmentDelegate

		required property Device device

		// Air quality sensors (e.g. Ruuvi Air) get an air quality card before the
		// temperature/humidity card. Key navigation treats both cards as a single item.
		readonly property bool hasAirQuality: iaqsItem.valid || pm25Item.valid || co2Item.valid
		readonly property int focusPolicy: Qt.TabFocus

		width: root.orientation === ListView.Vertical
			   ? root.width
			   : environmentPanel.x + environmentPanel.width
		height: root.orientation === ListView.Vertical
			   ? environmentPanel.y + environmentPanel.height
			   : Gauges.height(Global.pageManager?.expandLayout ?? false)

		Behavior on height {
			enabled: root.animationEnabled && Global.pageManager?.animatingIdleResize
			NumberAnimation {
				duration: Theme.animation_page_idleResize_duration
				easing.type: Easing.InOutQuad
			}
		}

		KeyNavigationHighlight.active: activeFocus

		Loader {
			id: airQualityLoader

			width: root.orientation === ListView.Vertical ? parent.width : root.twoGaugeWidth
			height: root.orientation === ListView.Vertical ? implicitHeight : parent.height
			active: environmentDelegate.hasAirQuality
			sourceComponent: EnvironmentGaugePanel {
				device: environmentDelegate.device
				animationEnabled: root.animationEnabled
				temperatureGaugeGradient: temperatureGradient
				humidityGaugeGradient: humidityGradient
				showAirQuality: true
				focusPolicy: Qt.NoFocus
			}
		}

		EnvironmentGaugePanel {
			id: environmentPanel

			x: root.orientation === ListView.Vertical || !airQualityLoader.active ? 0
				: airQualityLoader.width + root.spacing
			y: root.orientation === ListView.Vertical && airQualityLoader.active
				? airQualityLoader.height + root.spacing
				: 0
			width: root.orientation === ListView.Vertical
				   ? parent.width
				   : hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
			height: root.orientation === ListView.Vertical ? implicitHeight : parent.height
			device: environmentDelegate.device
			animationEnabled: root.animationEnabled
			temperatureGaugeGradient: temperatureGradient
			humidityGaugeGradient: humidityGradient
			focusPolicy: Qt.NoFocus
		}

		VeQuickItem {
			id: iaqsItem
			uid: environmentDelegate.device ? environmentDelegate.device.serviceUid + "/IAQS" : ""
		}

		VeQuickItem {
			id: pm25Item
			uid: environmentDelegate.device ? environmentDelegate.device.serviceUid + "/PM25" : ""
		}

		VeQuickItem {
			id: co2Item
			uid: environmentDelegate.device ? environmentDelegate.device.serviceUid + "/CO2" : ""
		}
	}

	Gradient {
		id: temperatureGradient

		orientation: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical

		GradientStop {
			position: Theme.geometry_levelsPage_environment_temperatureGauge_gradient_position1
			color: Theme.color_temperature1
		}
		GradientStop {
			position: Theme.geometry_levelsPage_environment_temperatureGauge_gradient_position2
			color: Theme.color_temperature2
		}
		GradientStop {
			position: Theme.geometry_levelsPage_environment_temperatureGauge_gradient_position3
			color: Theme.color_temperature3
		}
	}

	Gradient {
		id: humidityGradient

		orientation: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical

		GradientStop {
			position: Theme.geometry_levelsPage_environment_humidityGauge_gradient_position1
			color: Theme.color_humidity1
		}
		GradientStop {
			position: Theme.geometry_levelsPage_environment_humidityGauge_gradient_position2
			color: Theme.color_humidity2
		}
		GradientStop {
			position: Theme.geometry_levelsPage_environment_humidityGauge_gradient_position3
			color: Theme.color_humidity3
		}
	}
}
