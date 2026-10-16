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
	delegate: ListItemLoader {
		id: panelLoader

		required property Device device
		readonly property bool hasAirQuality: iaqsItem.valid || pm25Item.valid || co2Item.valid

		sourceComponent: hasAirQuality ? twoPanelsComponent : singlePanelComponent
		KeyNavigationHighlight.active: activeFocus

		Component {
			id: singlePanelComponent

			EnvironmentGaugePanel {
				width: root.orientation === ListView.Vertical
					   ? root.width
					   : hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
				height: root.orientation === ListView.Vertical
					   ? implicitHeight
					   : Gauges.height(Global.pageManager?.expandLayout ?? false)
				device: panelLoader.device
				animationEnabled: root.animationEnabled
				temperatureGaugeGradient: temperatureGradient
				humidityGaugeGradient: humidityGradient

				Behavior on height {
					enabled: root.animationEnabled && Global.pageManager?.animatingIdleResize
					NumberAnimation {
						duration: Theme.animation_page_idleResize_duration
						easing.type: Easing.InOutQuad
					}
				}
			}
		}

		Component {
			id: twoPanelsComponent

			Grid {
				height: root.orientation === ListView.Vertical ? implicitHeight : Gauges.height(Global.pageManager?.expandLayout ?? false)
				columns: root.orientation === ListView.Vertical ? 1 : 2
				rows: root.orientation === ListView.Vertical ? 2 : 1
				columnSpacing: Math.max(root.spacing, Theme.geometry_levelsPage_gauge_spacing_tiny)
				rowSpacing: root.spacing

				Behavior on height {
					enabled: root.animationEnabled && Global.pageManager?.animatingIdleResize
					NumberAnimation {
						duration: Theme.animation_page_idleResize_duration
						easing.type: Easing.InOutQuad
					}
				}

				AirQualityGaugePanel {
					width: root.orientation === ListView.Vertical ? root.width : root.twoGaugeWidth
					height: root.orientation === ListView.Vertical ? implicitHeight : parent.height
					device: panelLoader.device
				}

				EnvironmentGaugePanel {
					width: root.orientation === ListView.Vertical
							? root.width
							: hasTwoGauges ? root.twoGaugeWidth : root.oneGaugeWidth
					height: root.orientation === ListView.Vertical ? implicitHeight : parent.height
					device: panelLoader.device
					animationEnabled: root.animationEnabled
					temperatureGaugeGradient: temperatureGradient
					humidityGaugeGradient: humidityGradient
				}
			}
		}

		VeQuickItem {
			id: iaqsItem
			uid: panelLoader.device ? panelLoader.device.serviceUid + "/IAQS" : ""
		}

		VeQuickItem {
			id: pm25Item
			uid: panelLoader.device ? panelLoader.device.serviceUid + "/PM25" : ""
		}

		VeQuickItem {
			id: co2Item
			uid: panelLoader.device ? panelLoader.device.serviceUid + "/CO2" : ""
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
