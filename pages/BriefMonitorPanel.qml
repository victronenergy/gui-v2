/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Utils
import Victron.Units

Column {
	id: root

	property bool animationEnabled
	property string inputsIconSource

	spacing: Theme.geometry_briefPage_sidePanel_columnSpacing

	// TODO connect weather forecast to data backend
	Column {
		width: parent.width
		spacing: Theme.geometry_briefPage_sidePanel_header_spacing

		Row {
			width: parent.width

			Label {
				id: todayTemperature

				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: Theme.font_briefPage_sidePanel_forecastRow_today_temperature_size
				text: "10°"
			}
			CP.ColorImage {
				id: todayIcon

				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/images/cloud.svg"
				color: Theme.color_font_primary
			}
			Label {
				anchors.baseline: todayTemperature.baseline
				width: parent.width - todayTemperature.width - todayIcon.width
				horizontalAlignment: Text.AlignRight
				font.pixelSize: Theme.font_briefPage_sidePanel_forecastRow_today_date_size
				text: Qt.formatDate(ClockTime.currentDateTime, "ddd d MMM")
			}
		}

		SeparatorBar {
			width: parent.width
			height: Theme.geometry_briefPage_sidePanel_separatorBar_height
			color: Theme.color_briefPage_sidePanel_forecast_separator
		}

		Row {
			spacing: Theme.geometry_briefPage_sidePanel_forecastRow_spacing

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
		visible: Global.solarChargers.model.count || Global.pvInverters.model.count

		WidgetHeader {
			id: solarHeader

			//% "Solar yield"
			title: qsTrId("brief_solar_yield")
			icon.source: "qrc:/images/solaryield.svg"
		}

		ElectricalQuantityLabel {
			id: solarQuantityLabel

			anchors.top: solarHeader.bottom
			dataObject: Global.system.solar
			font.pixelSize: Theme.font_briefPage_quantityLabel_size
		}

		Loader {
			anchors {
				right: parent.right
				top: parent.top
				bottom: solarQuantityLabel.bottom
				bottomMargin: solarQuantityLabel.bottomPadding
			}
			active: Global.solarChargers.model.count > 0 && Global.pvInverters.model.count === 0
			width: Theme.geometry_briefPage_sidePanel_solarYield_width
			sourceComponent: SolarYieldGraph {}
		}
	}

	Column {
		id: generatorColumn

		width: parent.width
		spacing: Theme.geometry_briefPage_sidePanel_generator_columnSpacing
		visible: !!generatorQuantityLabel.dataObject

		Item {
			width: parent.width
			height: generatorQuantityLabel.y + generatorQuantityLabel.height

			WidgetHeader {
				id: generatorHeader

				title: CommonWords.generator
				icon.source: "qrc:/images/generator.svg"
			}

			ElectricalQuantityLabel {
				id: generatorQuantityLabel

				anchors.top: generatorHeader.bottom
				dataObject: Global.acInputs.generatorInput
				font.pixelSize: Theme.font_briefPage_quantityLabel_size
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
			height: Theme.geometry_briefPage_sidePanel_generator_slider_height
			value: Global.acInputs.generatorInput ? Global.acInputs.generatorInput.power : 0
			showHandle: false
			animationEnabled: root.animationEnabled
		}
	}

	Column {
		width: parent.width
		spacing: Theme.geometry_briefPage_sidePanel_generator_columnSpacing
		visible: !generatorColumn.visible && !(isNaN(Global.acInputs.power) && isNaN(Global.dcInputs.power))

		Item {
			width: parent.width
			height: gridQuantityLabel.y + gridQuantityLabel.height

			WidgetHeader {
				id: gridHeader

				//% "Power"
				title: qsTrId("power")
				icon.source: root.inputsIconSource
			}

			ElectricalQuantityLabel {
				id: gridQuantityLabel

				anchors.top: gridHeader.bottom
				value: root.visible ? Units.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power) : 0
				font.pixelSize: Theme.font_briefPage_quantityLabel_size
			}

			LoadGraph {
				id: gridGraph

				/*
				   Graph A
				   <Power>
		1000W     1.0 |
				  0.9 |
				  0.8 |
				  0.7 |
				  0.6 |
				  0.5 |
				  0.4 |      ___________
				  0.3 |     /           \_________        (only shows imported power. 'graphShowsExportPower' is false)
				  0.2 |____/
imported power ^  0.1 |
			 0W   0.0 |---------------------------> <Time>



				   Graph B
				   <Power>
		1000 W	  1.0 |
				  0.9 |
				  0.8 |       ___________ (e.g. +600W)
				  0.7 |      /           \_______
imported power ^  0.6 |     /
			  0W  0.5 |..../.......................       (shows imported and exported power. 'graphShowsExportPower' is true)
exported power v  0.4 |   /
				  0.3 |__/  (e.g. -400W)
				  0.2 |
				  0.1 |
		-1000W	  0.0 |----------------------------> <Time>

				  */

				// If we have ever seen power exported to the grid, the graph shows imported and exported power, as in Graph B.
				// Otherwise, we only show imported power, as in Graph A.
				property bool graphShowsExportPower: false

				property real _oldGraphPowerRange: NaN

				function addNewValue() {
					graphShowsExportPower = inputsPower.minimumSeen < 0

					// If we show export power, the minimum scale of the y axis goes from -1000W to +1000W
					// If we don't show export power, the minimum scale of the y axis goes from 0W to +1000W
					const minimumRangeWatts = graphShowsExportPower
							? Theme.animation_loadGraph_minimumRange_watts * 2
							: Theme.animation_loadGraph_minimumRange_watts
					const peakPowerImportedOrExported = Math.max(Math.abs(inputsPower.maximumSeen), Math.abs(inputsPower.minimumSeen))
					const graphPowerRange =  graphShowsExportPower // This represents the difference in power between y=0 and y=1 on the graph
							? Math.max(2 * peakPowerImportedOrExported, minimumRangeWatts)
							: Math.max(inputsPower.maximumSeen, minimumRangeWatts)

					// in Graph A, when the graph is at y=0.0, power is zero.
					// in Graph B, when the graph is at y=0.5, power is zero.
					const normalizedZeroPowerPoint = graphShowsExportPower ? 0.5 : 0.0
					const normalizedPower = (inputsPower.value / graphPowerRange) + normalizedZeroPowerPoint

					if (_oldGraphPowerRange != graphPowerRange) {
						if (!isNaN(_oldGraphPowerRange)) {
							const scalingFactor = graphPowerRange / _oldGraphPowerRange
							scaleHistoricalData(scalingFactor, normalizedZeroPowerPoint)
						}
						_oldGraphPowerRange = graphPowerRange
					}
					addValue(normalizedPower)
					normalizedPowerSlider.value = normalizedPower
				}

				function scaleHistoricalData(scalingFactor, normalizedZeroPowerPoint) {
					// If our historical power data was like this: [-1000, 1000, -1000, 1000, ...], and inputsPower.minimumSeen === -1000,
					// and inputsPower.maximumSeen === 1000, our graph 'y' values would be like this: [-1, 0, -1, 1, ...]
					// If we then got a new power import reading of 5000W, we need to scale down all of the historical data by
					// a factor of 5, eg. [-0.2, 0.2, -0.2, 0.2, ...]
					for (let i = 0; i < model.length; ++i) {
						model[i] = normalizedZeroPowerPoint + (model[i] - normalizedZeroPowerPoint) / scalingFactor
					}
				}

				onGraphShowsExportPowerChanged: {
					// This can only ever change from false to true.
					// If the system has never exported power, the graph values start at 0 (importing 0 power)
					// and go to 1 (peak power import).
					// The first time the system exports power, we need to scale and offset the historical power values.
					// E.g. An old value of 0 (meaning importing 0 power) has to be changed to 0.5
					// An old value of 0.2 (meaning importing 20% of peak power) has to be changed to 0.6,
					// as the range has doubled, and the zero-point has changed from 0 to 0.5.
					for (let i = 0; i < model.length; ++i) {
						if (model[i] < 0.5) {
							model[i] = model[i]/2 + 0.5
						}
					}
				}

				anchors {
					right: parent.right
					bottom: gridQuantityLabel.bottom
					bottomMargin: gridQuantityLabel.bottomPadding
				}

				// For a system that sometimes exports power, 0.5 represents 0 power.
				// For a system that only imports power, 0 represents 0 power.
				initialModelValue: graphShowsExportPower ? 0.5 : 0.0
				warningThreshold: 0.5
				belowThresholdFillColor1: graphShowsExportPower
										  ? Theme.color_briefPage_background
										  : Theme.color_briefPage_sidePanel_loadGraph_nominal_gradientColor1
				belowThresholdFillColor2: graphShowsExportPower
										  ? Theme.color_briefPage_background
										  : Theme.color_briefPage_sidePanel_loadGraph_nominal_gradientColor2
				belowThresholdBackgroundColor1: graphShowsExportPower
												? Theme.color_briefPage_sidePanel_loadGraph_nominal_gradientColor1
												: Theme.color_briefPage_background
				belowThresholdBackgroundColor2: graphShowsExportPower
												? Theme.color_briefPage_sidePanel_loadGraph_nominal_gradientColor2
												: Theme.color_briefPage_background
				horizontalGradientColor1: Theme.color_briefPage_background
				horizontalGradientColor2: "transparent"

				SequentialAnimation {
					loops: Animation.Infinite
					running: root.animationEnabled
					NumberAnimation {
						target: gridGraph
						property: "offsetFraction"
						from: 0.0
						to: 1.0
						duration: Theme.geometry_briefPage_sidePanel_loadGraph_intervalMs
					}
					ScriptAction {
						script: gridGraph.addNewValue()
					}
				}
			}
		}
		Slider {
			id: normalizedPowerSlider

			enabled: false // not interactive
			width: parent.width
			height: Theme.geometry_briefPage_sidePanel_generator_slider_height
			value: gridGraph.normalizedPower || 0
			showHandle: false
			animationEnabled: root.animationEnabled
		}
	}

	Column {
		width: parent.width
		spacing: Theme.geometry_briefPage_sidePanel_loads_columnSpacing

		Item {
			width: parent.width
			height: loadsQuantityLabel.y + loadsQuantityLabel.height

			WidgetHeader {
				id: loadsHeader

				//% "Loads"
				title: qsTrId("brief_loads")
				icon.source: "qrc:/images/consumption.svg"
			}

			ElectricalQuantityLabel {
				id: loadsQuantityLabel

				anchors.top: loadsHeader.bottom
				dataObject: Global.system.loads
				font.pixelSize: Theme.font_briefPage_quantityLabel_size
			}

			LoadGraph {
				id: loadGraph

				anchors {
					right: parent.right
					bottom: loadsQuantityLabel.bottom
					bottomMargin: loadsQuantityLabel.bottomPadding
				}

				SequentialAnimation {
					loops: Animation.Infinite
					running: root.animationEnabled
					NumberAnimation {
						target: loadGraph
						property: "offsetFraction"
						from: 0.0
						to: 1.0
						duration: Theme.geometry_briefPage_sidePanel_loadGraph_intervalMs
					}
					ScriptAction {
						script: loadGraph.addValue(loadsPower.valueAsRatio)
					}
				}
			}
		}

		Slider {
			enabled: false // not interactive
			width: parent.width
			height: Theme.geometry_briefPage_sidePanel_generator_slider_height
			value: loadsPower.valueAsRatio
			highlightColor: Theme.color_warning
			grooveColor: Theme.color_darkWarning
			showHandle: false
			animationEnabled: root.animationEnabled
		}
	}

	ValueRange {
		id: loadsPower

		value: root.visible ? Global.system.loads.power : NaN
	}

	ValueRange {
		id: inputsPower

		value: root.visible ? Units.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power) : NaN
	}
}
