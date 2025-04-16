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
		required property Device device

		width: hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
		height: Gauges.height(Global.pageManager?.expandLayout)
		animationEnabled: root.animationEnabled
		title: device?.name ?? ""
		temperature: Global.systemSettings.convertFromCelsius(device?.temperature ?? NaN)
		temperatureType: device?.temperatureType ?? NaN
		humidity: device?.humidity ?? NaN
		temperatureGaugeGradient: temperatureGradient
		humidityGaugeGradient: humidityGradient
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
