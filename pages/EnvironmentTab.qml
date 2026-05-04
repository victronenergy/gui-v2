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
		width: root.orientation === ListView.Vertical
			   ? ListView.view.width
			   : hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
		height: root.orientation === ListView.Vertical
			   ? implicitHeight
			   : Gauges.height(Global.pageManager?.expandLayout ?? false)
		animationEnabled: root.animationEnabled
		// temperature: temperatureItem.valid ? temperatureItem.value : NaN
		// temperatureType: temperatureType.valid ? temperatureType.value : VenusOS.Temperature_DeviceType_Generic
		// humidity: humidity.valid ? humidity.value : NaN
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
