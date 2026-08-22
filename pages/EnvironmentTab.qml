/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

LevelsTab {
	id: root

	readonly property int twoGaugeWidth: Gauges.width(Services.temperature.model.count, 4, Theme.geometry_screen_width)
	readonly property int oneGaugeWidth: Gauges.width(Services.temperature.model.count, 6, Theme.geometry_screen_width)

	readonly property var _temperatureGaugeParameters: [
		{ min: -20,     max: 60,    step: 10 },     // 0: Battery
		{ min: 0,       max: 20,    step: 5 },      // 1: Fridge
		{ min: -40,     max: 60,    step: 10 },     // 2: Generic
		{ min: 5,       max: 35,    step: 10 },     // 3: Room
		{ min: -40,     max: 60,    step: 10 },     // 4: Outdoor
		{ min: 0,       max: 100,   step: 10 },     // 5: Water Heater
		{ min: -30,     max: 0,     step: 5 },      // 6: Freezer
	]

	function _gaugeParameters(temperatureType) {
		return temperatureType == null || temperatureType < 0 || temperatureType >= _temperatureGaugeParameters.length
				? _temperatureGaugeParameters[VenusOS.Temperature_DeviceType_Generic]
				: _temperatureGaugeParameters[temperatureType]
	}

	model: Services.temperature.model
	delegate: EnvironmentGaugePanel {
		width: root.orientation === ListView.Vertical
			   ? ListView.view.width
			   : hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
		height: root.orientation === ListView.Vertical
			   ? implicitHeight
			   : Gauges.height(Global.pageManager?.expandLayout ?? false)
		animationEnabled: root.animationEnabled
		minimumValue: Units.convert(root._gaugeParameters(temperatureType.value).min,
				VenusOS.Units_Temperature_Celsius,
				Services.settings.temperatureUnit)
		maximumValue: Units.convert(root._gaugeParameters(temperatureType.value).max,
				VenusOS.Units_Temperature_Celsius,
				Services.settings.temperatureUnit)
		stepSize: root._gaugeParameters(temperatureType.value).step
		temperatureGaugeGradient: temperatureGradient
		humidityGaugeGradient: humidityGradient
		focusPolicy: Qt.TabFocus

		Behavior on height {
			enabled: root.animationEnabled && Global.pageManager?.animatingIdleResize
			NumberAnimation {
				duration: Theme.animation_page_idleResize_duration
				easing.type: Easing.InOutQuad
			}
		}

		KeyNavigationHighlight.active: activeFocus
		KeyNavigationHighlight.leftMargin: leftInset
		KeyNavigationHighlight.rightMargin: rightInset

		VeQuickItem {
			id: temperatureType
			uid: parent.device ? parent.device.serviceUid + "/TemperatureType" : ""
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
