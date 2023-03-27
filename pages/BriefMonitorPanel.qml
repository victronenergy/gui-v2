/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

Column {
	id: root

	property string gridIcon

	spacing: Theme.geometry.briefPage.sidePanel.columnSpacing

	// TODO connect weather forecast to data backend
	Column {
		width: parent.width
		spacing: Theme.geometry.briefPage.sidePanel.header.spacing

		Row {
			width: parent.width

			Label {
				id: todayTemperature

				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: Theme.font.briefPage.sidePanel.forecastRow.today.temperature.size
				text: "10°"
			}
			CP.ColorImage {
				id: todayIcon

				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/images/cloud.svg"
				color: Theme.color.font.primary
			}
			Label {
				anchors.baseline: todayTemperature.baseline
				width: parent.width - todayTemperature.width - todayIcon.width
				horizontalAlignment: Text.AlignRight
				font.pixelSize: Theme.font.briefPage.sidePanel.forecastRow.today.date.size
				text: "Sun 3 Oct"
			}
		}

		SeparatorBar {
			width: parent.width
			height: Theme.geometry.briefPage.sidePanel.separatorBar.height
			color: Theme.color.briefPage.sidePanel.forecast.separator
		}

		Row {
			spacing: Theme.geometry.briefPage.sidePanel.forecastRow.spacing

			WeatherDetails {
				day: "Mon"
				temperature: "9°"
				source: "qrc:/images/rain.svg"
			}
			WeatherDetails {
				day: "Tue"
				temperature: "11°"
				source: "qrc:/images/scatteredcloud.svg"
			}
			WeatherDetails {
				day: "Wed"
				temperature: "13°"
				source: "qrc:/images/sunny.svg"
			}
		}
	}

	Item {
		width: parent.width
		height: solarQuantityLabel.y + solarQuantityLabel.height
		visible: Global.solarChargers.model.count > 0

		WidgetHeader {
			id: solarHeader

			//% "Solar yield"
			title: qsTrId("brief_solar_yield")
			icon.source: "qrc:/images/solaryield.svg"
		}

		EnergyQuantityLabel {
			id: solarQuantityLabel

			anchors.top: solarHeader.bottom
			dataObject: Global.solarChargers
			font.pixelSize: Theme.font.briefPage.quantityLabel.size
		}

		SolarYieldGraph {
			anchors {
				right: parent.right
				top: parent.top
				bottom: solarQuantityLabel.bottom
				bottomMargin: solarQuantityLabel.bottomPadding
			}
			width: Theme.geometry.briefPage.sidePanel.solarYield.width
		}
	}

	Column {
		id: generatorColumn

		width: parent.width
		spacing: Theme.geometry.briefPage.sidePanel.generator.columnSpacing
		visible: !!generatorQuantityLabel.dataObject

		Item {
			width: parent.width
			height: generatorQuantityLabel.y + generatorQuantityLabel.height

			WidgetHeader {
				id: generatorHeader

				//% "Generator"
				title: qsTrId("brief_generator")
				icon.source: "qrc:/images/generator.svg"
			}

			EnergyQuantityLabel {
				id: generatorQuantityLabel

				anchors.top: generatorHeader.bottom
				dataObject: Global.acInputs.generatorInput
				font.pixelSize: Theme.font.briefPage.quantityLabel.size
			}

			GeneratorIconLabel {
				anchors {
					right: parent.right
					bottom: generatorQuantityLabel.bottom
					bottomMargin: generatorQuantityLabel.bottomPadding
				}
				// In most cases there is only 1 generator, so don't worry about other ones here.
				generator: Global.generators.first
			}
		}
		Slider {
			enabled: false // not interactive
			width: parent.width
			height: Theme.geometry.briefPage.sidePanel.generator.slider.height
			value: Global.acInputs.generatorInput ? Global.acInputs.generatorInput.power : 0
			showHandle: false

			Behavior on value { NumberAnimation { duration: Theme.animation.briefPage.sidePanel.sliderValueChange.duration } }
		}
	}

	Column {
		width: parent.width
		spacing: Theme.geometry.briefPage.sidePanel.generator.columnSpacing
		visible: !generatorColumn.visible && (!!Global.acInputs.power || !!Global.dcInputs.power)

		Item {
			width: parent.width
			height: gridQuantityLabel.y + gridQuantityLabel.height

			WidgetHeader {
				id: gridHeader

				//% "Power"
				title: qsTrId("power")
				icon.source: root.gridIcon
			}

			EnergyQuantityLabel {
				id: gridQuantityLabel

				anchors.top: gridHeader.bottom
				value: Utils.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power)
				font.pixelSize: Theme.font.briefPage.quantityLabel.size
			}

			LoadGraph {
				id: gridGraph

				anchors {
					right: parent.right
					bottom: gridQuantityLabel.bottom
					bottomMargin: gridQuantityLabel.bottomPadding
				}
				initialModelValue: 0.5
				interval: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
				enableAnimation: root.opacity > 0
				warningThreshold: 0.5
				belowThresholdFillColor1: Theme.color.briefPage.background
				belowThresholdFillColor2: Theme.color.briefPage.background
				belowThresholdBackgroundColor1: Theme.color.briefPage.sidePanel.loadGraph.nominal.gradientColor1
				belowThresholdBackgroundColor2: Theme.color.briefPage.sidePanel.loadGraph.nominal.gradientColor2
				horizontalGradientColor1: Theme.color.briefPage.background
				horizontalGradientColor2: "transparent"

				Timer {
					interval: parent.interval
					running: root.opacity > 0
					repeat: true
					onTriggered: gridGraph.addValue(gridPower.normalizedValueAsRatio)
				}
			}
		}
		Slider {
			enabled: false // not interactive
			width: parent.width
			height: Theme.geometry.briefPage.sidePanel.generator.slider.height
			value: gridPower.normalizedValueAsRatio
			showHandle: false

			Behavior on value { NumberAnimation { duration: Theme.animation.briefPage.sidePanel.sliderValueChange.duration } }
		}
	}

	Column {
		width: parent.width
		spacing: Theme.geometry.briefPage.sidePanel.loads.columnSpacing

		Item {
			width: parent.width
			height: loadsQuantityLabel.y + loadsQuantityLabel.height

			WidgetHeader {
				id: loadsHeader

				//% "Loads"
				title: qsTrId("brief_loads")
				icon.source: "qrc:/images/consumption.svg"
			}

			EnergyQuantityLabel {
				id: loadsQuantityLabel

				anchors.top: loadsHeader.bottom
				dataObject: Global.system.loads
				font.pixelSize: Theme.font.briefPage.quantityLabel.size
			}

			LoadGraph {
				id: loadGraph

				anchors {
					right: parent.right
					bottom: loadsQuantityLabel.bottom
					bottomMargin: loadsQuantityLabel.bottomPadding
				}
				interval: loadGraphTimer.interval
				enableAnimation: root.opacity > 0

				Timer {
					id: loadGraphTimer

					interval: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
					running: root.opacity > 0
					repeat: true
					onTriggered: loadGraph.addValue(loadsPower.valueAsRatio)
				}
			}
		}

		Slider {
			enabled: false // not interactive
			width: parent.width
			height: Theme.geometry.briefPage.sidePanel.generator.slider.height
			value: loadsPower.valueAsRatio
			highlightColor: Theme.color.warning
			grooveColor: Theme.color.darkWarning
			showHandle: false

			Behavior on value { NumberAnimation { duration: Theme.animation.briefPage.sidePanel.sliderValueChange.duration } }
		}
	}

	ValueRange {
		id: loadsPower

		value: Global.system.loads.power
	}

	ValueRange {
		id: gridPower

		// If the current grid power is 0W, normalizedValueAsRatio equals 0.5, regardless of maximum / minimum seen power.
		// If the maximum seen power is 20W, and the minimum seen power is 10W, and the current power is 10W,
		// normalizedValueAsRatio equals 0.75.
		// If the maximum seen power is -10W, and the minimum seen power is -100W, and the current power is -20W,
		// normalizedValueAsRatio equals 0.4.
		readonly property real normalizedValueAsRatio: 0.5 + (value / normalizedRange)
		readonly property real normalizedRange: Math.abs(_max) > Math.abs(_min) ? 2*Math.abs(_max) : 2*Math.abs(_min)

		value: Utils.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power)
	}
}
