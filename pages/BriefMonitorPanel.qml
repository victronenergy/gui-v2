/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	controlsButton.visible: false

	Column {
		anchors {
			fill: parent
			topMargin: 22
		}

		Item {
			width: parent.width
			height: 22

			Label {
				anchors.left: parent.left
				text: "Sun 3 Oct"
			}
			Label {
				anchors.right: parent.right
				text: "12:23"
			}
		}
		Item { width: 1; height: 3 }
		Item {
			height: 41
			width: 50

			Label {
				id: temperature

				font.pixelSize: 34
				text: "12°"
			}
			CP.ColorImage {
				anchors {
					top: parent.top
					topMargin: 6
					left: temperature.right
					leftMargin: 5
				}
				source: "qrc:/images/cloud.svg"
				color: Theme.primaryFontColor
			}
		}
		Item { width: 1; height: 6 }
		Row {
			WeatherDetails {
				day: "Mon"
				temperature: "6°"
				source: "qrc:/images/rain.svg"
			}
			WeatherDetails {
				day: "Tue"
				temperature: "8°"
				source: "qrc:/images/scatteredcloud.svg"
			}
			WeatherDetails {
				day: "Wed"
				temperature: "13°"
				source: "qrc:/images/sunny.svg"
			}
			WeatherDetails {
				day: "Thu"
				temperature: "8°"
				source: "qrc:/images/scatteredcloud.svg"
			}
		}
		Item { width: 1; height: 33 }
		ListView {
			width: parent.width
			height: 300
			orientation: ListView.Vertical
			model: ListModel {
				ListElement {
					labelText: "Generator"
					valueText: "483 W"
					imageSource: "qrc:/images/generator.svg"
				}
				ListElement {
					labelText: "Grid"
					valueText: "Off"
					imageSource: "qrc:/images/grid.svg"
				}
				ListElement {
					labelText: "Solar yield"
					valueText: "80 W"
					imageSource: "qrc:/images/solaryield.svg"
				}
				ListElement {
					labelText: "Consum"
					valueText: "268 W"
					imageSource: "qrc:/images/consumption.svg"
				}
			}
			delegate: Item {
				width: parent.width
				height: 40
				CP.ColorImage {
					id: image

					anchors.verticalCenter: parent.verticalCenter
					width: implicitWidth
					height: implicitHeight
					source: imageSource
					color: Theme.primaryFontColor
				}
				Label {
					anchors {
						verticalCenter: parent.verticalCenter
						left: image.right
						leftMargin: 9
					}
					text: labelText
				}
				Label {
					anchors.right: parent.right
					font.pixelSize: 28
					text: valueText
				}
			}
		}
	}
}
