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
	delegate: EnvironmentGaugePanel {
		id: panel

		required property Device device

		width: hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
		height: Gauges.height(Global.pageManager?.expandLayout)
		animationEnabled: root.animationEnabled
		title: device?.name ?? ""
		temperature: temperatureItem.valid ? temperatureItem.value : NaN
		temperatureType: temperatureType.valid ? temperatureType.value : VenusOS.Temperature_DeviceType_Generic
		humidity: humidity.valid ? humidity.value : NaN
		temperatureGaugeGradient: temperatureGradient
		humidityGaugeGradient: humidityGradient

		VeQuickItem {
			id: temperatureItem
			uid: panel.device ? panel.device.serviceUid + "/Temperature" : ""
			sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
			displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		}
		VeQuickItem {
			id: temperatureType
			uid: panel.device ? panel.device.serviceUid + "/TemperatureType" : ""
		}
		VeQuickItem {
			id: humidity
			uid: panel.device ? panel.device.serviceUid + "/Humidity" : ""
		}
	}

	Gradient {
		id: temperatureGradient

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
