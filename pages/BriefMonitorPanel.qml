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

	Item {
		height: Theme.geometry.briefPage.sidePanel.header.height
		width: parent.width
		Label {
			id: temperature

			anchors.verticalCenter: parent.verticalCenter

			font.pixelSize: Theme.font.size.l
			text: "10°"
		}
		CP.ColorImage {
			id: image

			anchors {
				verticalCenter: parent.verticalCenter
				left: temperature.right
				leftMargin: Theme.geometry.briefPage.sidePanel.header.image.leftMargin
			}
			source: "qrc:/images/cloud.svg"
			color: Theme.color.font.primary
		}
		Label {
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: Theme.geometry.briefPage.sidePanel.header.date.rightMargin
			}
			font.pixelSize: Theme.font.size.m
			text: "Sun 3 Oct"
		}
	}
	SeparatorBar {
		width: parent.width
		height: Theme.geometry.briefPage.sidePanel.separatorBar.height
	}
	Row {
		topPadding: Theme.geometry.briefPage.sidePanel.forecastRow.topPadding
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

	Binding {
		id: solarUpdate
		property: "value"
		value: solarChargers ? solarChargers.power : 0
	}

	Binding {
		id: generatorUpdate
		property: "value"
		value: systemTotals.generatorPower
	}

	Binding {
		id: loadsUpdate
		property: "value"
		value: systemTotals.loadPower
	}

	ListView {
		id: listView
		property var decorations: [solarYieldDecoration, generatorDecoration, loadsDecoration]
		width: parent.width
		height: Theme.geometry.briefPage.sidePanel.listView.height
		orientation: ListView.Vertical
		topMargin: Theme.geometry.briefPage.sidePanel.topSpacing
		spacing: Theme.geometry.briefPage.sidePanel.columnSpacing
		model: ListModel {
			Component.onCompleted: {
				append({
						height: Theme.geometry.briefPage.sidePanel.solarYield.height,
						//% "Solar yield"
						labelText: qsTrId("brief_solar_yield"),
						value: 0,
						type: Units.Power,
						imageSource: "qrc:/images/solaryield.svg",
						decorationIndex: 0,
						topMargin: Theme.geometry.briefPage.sidePanel.solarYield.topMargin
					})
				solarUpdate.target = get(count - 1)

				append({
						height: Theme.geometry.briefPage.sidePanel.generator.height,
						//% "Generator"
						labelText: qsTrId("brief_generator"),
						value: 0,
						type: Units.Power,
						imageSource: "qrc:/images/generator.svg",
						decorationIndex: 1,
						topMargin: Theme.geometry.briefPage.sidePanel.generator.topMargin
					})
				generatorUpdate.target = get(count - 1)

				append({
						height: Theme.geometry.briefPage.sidePanel.loads.height,
						//% "Loads"
						labelText: qsTrId("brief_loads"),
						value: 0,
						type: Units.Power,
						imageSource: "qrc:/images/consumption.svg",
						decorationIndex: 2,
						topMargin: Theme.geometry.briefPage.sidePanel.loads.topMargin
					})
				loadsUpdate.target = get(count - 1)
			}
		}
		delegate: Item {
			width: root.width
			height: model.height
			ValueDisplay {
				id: valueDisplay

				anchors {
					top: parent.top
					topMargin: model.topMargin
				}
				title.text: model.labelText
				physicalQuantity: model.type
				value: model.value
				icon.source: model.imageSource
				fontSize: Theme.font.size.l
			}
			Loader {
				anchors{
					right: parent.right
					bottom: parent.bottom
				}
				sourceComponent: listView.decorations[decorationIndex]
			}
		}
		Component {
			id: solarYieldDecoration

			SolarYieldGraph {
				width: Theme.geometry.briefPage.sidePanel.solarYield.width
				height: Theme.geometry.briefPage.sidePanel.solarYield.height

				anchors {
					right: parent.right
					rightMargin: Theme.geometry.briefPage.sidePanel.solarYield.rightMargin
					bottom: parent.bottom
					bottomMargin: Theme.geometry.briefPage.sidePanel.solarYield.bottomMargin
				}

				history: solarChargers ? solarChargers.yieldHistory: []
			}
		}
		Component {
			id: generatorDecoration

			Item {
				width: root.width
				height: Theme.geometry.briefPage.sidePanel.generator.height

				GeneratorIconLabel {
					anchors {
						right: parent.right
						bottom: parent.bottom
						bottomMargin: Theme.geometry.briefPage.sidePanel.generator.label.bottomMargin
					}
					spacing: Theme.geometry.briefPage.sidePanel.generator.label.spacing
					state: generators ? generators.generator.state : Generators.GeneratorState.Stopped
					runtime: generators ? generators.generator.runtime : 0
					runningBy: generators ? generators.generator.runningBy : Generators.GeneratorRunningBy.Stopped

				}
				Slider {
					id: slider

					anchors {
						right: parent.right
						bottom: parent.bottom
					}
					grooveVerticalPadding: 0
					enabled: false // not interactive
					width: parent.width
					height: Theme.geometry.briefPage.sidePanel.generator.slider.height
					value: systemTotals.generatorPower
					showHandle: false
				}
			}
		}
		Component {
			id: loadsDecoration
			Item {
				width: root.width
				height: Theme.geometry.briefPage.sidePanel.loads.height
				LoadGraph {
					id: loadGraph

					anchors {
						right: parent.right
						top: parent.top
						topMargin: Theme.geometry.briefPage.sidePanel.loadGraph.topMargin
						bottom: parent.bottom
						bottomMargin: Theme.geometry.briefPage.sidePanel.loadGraph.bottomMargin
					}
					interval: timer.interval
					enableAnimation: PageManager.sidePanelActive

					Timer {
						id: timer
						interval: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
						running: PageManager.sidePanelActive && !!systemAc
						repeat: true
						onTriggered: {
							let loadValue = systemTotals.loadPower / Utils.maximumValue("systemTotals.loadPower")
							loadGraph.addValue(loadValue)
						}
					}
				}

				Slider {
					id: slider

					anchors {
						right: parent.right
						bottom: parent.bottom
					}
					grooveVerticalPadding: 0
					enabled: false // not interactive
					width: parent.width
					height: Theme.geometry.briefPage.sidePanel.generator.slider.height
					value: systemTotals.loadPower / Utils.maximumValue("systemTotals.loadPower")
					highlightColor: Theme.color.warning
					grooveColor: Theme.color.darkWarning
					showHandle: false
				}
			}
		}
	}
}
