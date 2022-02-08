/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Column {
	id: root
	property int generatorPower: 874 // TODO - hook up to real data
	property int generatorMaxPower: 1000 // TODO - hook up to real data

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
	ListView {
		id: listView
		property var decorations: [solarYieldDecoration, generatorDecoration, loadsDecoration]
		width: parent.width
		height: Theme.geometry.briefPage.sidePanel.listView.height
		orientation: ListView.Vertical
		topMargin: Theme.geometry.briefPage.sidePanel.topSpacing
		spacing: Theme.geometry.briefPage.sidePanel.columnSpacing
		model: ListModel { // TODO: hook up to real data
			Component.onCompleted: {
				append({
						height: Theme.geometry.briefPage.sidePanel.solarYield.height,
						//% "Solar yield"
						labelText: qsTrId("brief_solar_yield"),
						value: 428,
						type: Units.Power,
						imageSource: "qrc:/images/solaryield.svg",
						decorationIndex: 0,
						topMargin: Theme.geometry.briefPage.sidePanel.solarYield.topMargin
					})
				append({
						height: Theme.geometry.briefPage.sidePanel.generator.height,
						//% "Generator"
						labelText: qsTrId("brief_generator"),
						value: 874,
						type: Units.Power,
						imageSource: "qrc:/images/generator.svg",
						decorationIndex: 1,
						topMargin: Theme.geometry.briefPage.sidePanel.generator.topMargin
					})
				append({
						height: Theme.geometry.briefPage.sidePanel.loads.height,
						//% "Loads"
						labelText: qsTrId("brief_loads"),
						value: 6.25,
						type: Units.Power,
						imageSource: "qrc:/images/consumption.svg",
						decorationIndex: 2,
						topMargin: Theme.geometry.briefPage.sidePanel.loads.topMargin
					})
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
				rightAligned: false
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
			Item {
				width: root.width
				height: Theme.geometry.briefPage.sidePanel.solarYield.height
				BarChart {
					anchors {
						right: parent.right
						rightMargin: Theme.geometry.briefPage.sidePanel.solarYield.rightMargin
						bottom: parent.bottom
						bottomMargin: Theme.geometry.briefPage.sidePanel.solarYield.bottomMargin
					}
					width: Theme.geometry.briefPage.sidePanel.solarYield.width

					model: [0.8, 1, 0.8, 0.5, 0.65, 0.3, 0.2, 0.8, 1, 0.85, 0.7] // TODO: hook up to real data
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
					state: Generators.GeneratorState.Running
					runtime: 25*60
					runningBy: Generators.GeneratorRunningBy.Soc
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
					value: 0.8 // TODO - hook up to real data
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

					Timer {		// TODO - data model
						id: timer
						interval: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
						running: PageManager.sidePanelActive
						repeat: true
						onTriggered: {
							loadGraph.addValue(Math.random())
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
					value: 0.7
					highlightColor: Theme.color.warning
					grooveColor: Theme.color.darkWarning
					showHandle: false
				}
			}
		}
	}
}
