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
		width: parent.width
		spacing: Theme.geometry.briefPage.sidePanel.generator.columnSpacing

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
				interval: timer.interval
				enableAnimation: Global.pageManager.sidePanelActive

				Timer {
					id: timer

					interval: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
					running: Global.pageManager.sidePanelActive
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
}
