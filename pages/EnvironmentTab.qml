/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Gauges

Flickable {
	id: root

	property bool animationEnabled: true

	width: parent.width
	height: parent.height
	contentWidth: contentRow.width
	leftMargin: levelsRepeater.count > 3 ? Theme.geometry_levelsPage_environment_horizontalMargin : (width - contentRow.width) / 2
	rightMargin: Theme.geometry_levelsPage_environment_horizontalMargin
	boundsBehavior: Flickable.StopAtBounds
	contentX: -leftMargin   // shouldn't be needed, but initial value may be incorrect due to delegate resizing

	property int twoGaugeWidth: Gauges.width(levelsRepeater.count, 4, root.width)
	property int oneGaugeWidth: Gauges.width(levelsRepeater.count, 6, root.width)

	Row {
		id: contentRow

		height: parent.height

		spacing: Gauges.spacing(levelsRepeater.count)

		Repeater {
			id: levelsRepeater
			model: Global.environmentInputs.model

			delegate: EnvironmentGaugePanel {
				animationEnabled: root.animationEnabled

				width: _twoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
				height: Gauges.height(!!Global.pageManager && Global.pageManager.expandLayout)
				title: model.device.name
				temperature: Global.systemSettings.convertFromCelsius(model.device.temperature)
				temperatureType: model.device.temperatureType
				humidity: model.device.humidity
				temperatureGaugeGradient: temperatureGradient
				humidityGaugeGradient: humidityGradient
			}
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
