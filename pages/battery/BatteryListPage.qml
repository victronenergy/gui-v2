/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: Global.batteries.model
		spacing: Theme.geometry.gradientList.spacing
		delegate: ListItemBackground {
			height: Theme.geometry.batteryListPage.item.height

			Column {
				anchors {
					left: parent.left
					leftMargin: Theme.geometry.listItem.content.horizontalMargin
					right: arrowIcon.left
					verticalCenter: parent.verticalCenter
				}
				spacing: Theme.geometry.batteryListPage.item.verticalSpacing

				Row {
					id: topRow
					width: parent.width

					Label {
						id: nameLabel

						width: parent.width - socLabel.width - Theme.geometry.listItem.content.spacing
						elide: Text.ElideRight
						text: modelData.name
						font.pixelSize: Theme.font.size.body2
					}

					QuantityLabel {
						id: socLabel

						height: nameLabel.height
						value: modelData.stateOfCharge
						unit: VenusOS.Units_Percentage
						font.pixelSize: Theme.font.size.body2
					}
				}

				Row {
					id: bottomRow
					width: parent.width

					Row {
						id: measurementsRow

						anchors.verticalCenter: parent.verticalCenter
						spacing: Theme.geometry.listItem.content.spacing

						QuantityRepeater {
							model: [
								{ value: modelData.voltage, unit: VenusOS.Units_Volt },
								{ value: modelData.current, unit: VenusOS.Units_Amp },
								{ value: modelData.power, unit: VenusOS.Units_Watt },
								{
									value: Global.systemSettings.convertTemperature(modelData.temperature_celsius),
									unit: Global.systemSettings.temperatureUnit.value
								}
							]
						}
					}

					Label {
						anchors.verticalCenter: parent.verticalCenter
						width: parent.width - measurementsRow.width - Theme.geometry.listItem.content.spacing
						elide: Text.ElideRight
						font.pixelSize: Theme.font.size.body2
						color: Theme.color.listItem.secondaryText
						text: {
							const modeText = Global.batteries.modeToText(modelData.mode)
							if (modelData.mode === VenusOS.Battery_Mode_Discharging) {
								return modeText + " - " + Global.batteries.timeToGoText(modelData, VenusOS.Battery_TimeToGo_LongFormat)
							}
							return modeText
						}
						horizontalAlignment: Text.AlignRight
					}

				}
			}

			ColorImage {
				id: arrowIcon

				anchors {
					right: parent.right
					rightMargin: Theme.geometry.listItem.content.horizontalMargin
					verticalCenter: parent.verticalCenter
				}
				source: "/images/icon_back_32.svg"
				width: Theme.geometry.statusBar.button.icon.width
				height: Theme.geometry.statusBar.button.icon.height
				rotation: 180
				color: mouseArea.containsPress ? Theme.color.listItem.down.forwardIcon : Theme.color.listItem.forwardIcon
				fillMode: Image.PreserveAspectFit
			}

			MouseArea {
				id: mouseArea

				anchors.fill: parent
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml",
							{ "title": text, "bindPrefix": modelData })
				}
			}
		}
	}
}
