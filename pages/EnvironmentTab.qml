/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Utils

Flickable {
	id: root

	property bool animationEnabled: true

	width: parent.width
	height: parent.height
	contentWidth: contentRow.width
	leftMargin: contentRow.width > width
			? Theme.geometry_levelsPage_environment_minimumHorizontalMargin
			: (width - contentRow.width) / 2
	rightMargin: Theme.geometry_levelsPage_environment_minimumHorizontalMargin
	boundsBehavior: Flickable.StopAtBounds
	contentX: -leftMargin   // shouldn't be needed, but initial value may be incorrect due to delegate resizing

	Row {
		id: contentRow

		height: parent.height

		spacing: {
			if (levelsRepeater.count === 0) {
				return 0
			}
			// Find a spacing between panels that is within the min/max spacing range.
			const availableWidth = root.width - Theme.geometry_levelsPage_environment_minimumHorizontalMargin*2
			let panelWidths = 0
			for (let i = 0; i < levelsRepeater.count; ++i) {
				const item = levelsRepeater.itemAt(i)
				if (item) {
					panelWidths += item.width
				}
			}
			let candidateSpacing = Math.max(Theme.geometry_levelsPage_environment_minimumSpacing,
					Math.min(Theme.geometry_levelsPage_environment_maximumSpacing, (availableWidth - panelWidths) / (levelsRepeater.count-1)))

			// If the spacing is larger than the horizontal margin, use the horizontal margin as
			// the spacing instead, otherwise looks odd when panels are pushed to edges.
			let requiredAreaWidth = panelWidths + ((levelsRepeater.count-1) * candidateSpacing)
			let candidateHorizontalMargin = (root.width - requiredAreaWidth) / 2
			if (candidateSpacing > candidateHorizontalMargin) {
				candidateSpacing = candidateHorizontalMargin
			}
			return Math.max(Theme.geometry_levelsPage_environment_minimumSpacing, candidateSpacing)
		}

		Repeater {
			id: levelsRepeater
			model: Global.environmentInputs.model

			delegate: EnvironmentGaugePanel {
				animationEnabled: root.animationEnabled
				horizontalSize: {
					if (levelsRepeater.count === 0) {
						return VenusOS.EnvironmentGaugePanel_Size_Expanded
					}
					// If available area is not big enough to fit all the panels at their max width,
					// use a compact (reduced) width for two-gauge panels.
					const availableAreaWidth = root.width - Theme.geometry_levelsPage_environment_minimumHorizontalMargin*2
					let panelWidths = 0
					for (let i = 0; i < levelsRepeater.count; ++i) {
						const item = levelsRepeater.itemAt(i)
						if (item) {
							panelWidths += item.expandedWidth
						}
					}
					const requiredAreaWidth = panelWidths + ((levelsRepeater.count-1) * Theme.geometry_levelsPage_environment_minimumSpacing)
					return requiredAreaWidth > availableAreaWidth
							? VenusOS.EnvironmentGaugePanel_Size_Compact
							: VenusOS.EnvironmentGaugePanel_Size_Expanded
				}

				verticalSize: (!!Global.pageManager && Global.pageManager.expandLayout)
						? VenusOS.EnvironmentGaugePanel_Size_Expanded
						: VenusOS.EnvironmentGaugePanel_Size_Compact
				title: model.device.name
				temperature: Global.systemSettings.convertFromCelsius(model.device.temperature_celsius)
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
