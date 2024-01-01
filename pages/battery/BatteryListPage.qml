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
		spacing: Theme.geometry_gradientList_spacing
		delegate: ListItemBackground {
			height: Theme.geometry_batteryListPage_item_height

			Column {
				anchors {
					left: parent.left
					leftMargin: Theme.geometry_listItem_content_horizontalMargin
					right: arrowIcon.left
					verticalCenter: parent.verticalCenter
				}
				spacing: Theme.geometry_batteryListPage_item_verticalSpacing

				Row {
					id: topRow
					width: parent.width

					Label {
						id: nameLabel

						width: parent.width - socLabel.width - Theme.geometry_listItem_content_spacing
						elide: Text.ElideRight
						text: modelData.name
						font.pixelSize: Theme.font_size_body2
					}

					QuantityLabel {
						id: socLabel

						height: nameLabel.height
						value: modelData.stateOfCharge
						unit: VenusOS.Units_Percentage
						font.pixelSize: Theme.font_size_body2
					}
				}

				Row {
					id: bottomRow
					width: parent.width

					Row {
						id: measurementsRow

						anchors.verticalCenter: parent.verticalCenter
						spacing: Theme.geometry_listItem_content_spacing

						QuantityRepeater {
							model: [
								{ value: modelData.voltage, unit: VenusOS.Units_Volt },
								{ value: modelData.current, unit: VenusOS.Units_Amp },
								{ value: modelData.power, unit: VenusOS.Units_Watt },
								{
									value: Global.systemSettings.convertFromCelsius(modelData.temperature_celsius),
									unit: Global.systemSettings.temperatureUnit
								}
							]
						}
					}

					Label {
						anchors.verticalCenter: parent.verticalCenter
						width: parent.width - measurementsRow.width - Theme.geometry_listItem_content_spacing
						elide: Text.ElideRight
						font.pixelSize: Theme.font_size_body2
						color: Theme.color_listItem_secondaryText
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

			CP.ColorImage {
				id: arrowIcon

				anchors {
					right: parent.right
					rightMargin: Theme.geometry_listItem_content_horizontalMargin
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/icon_back_32.svg"
				width: Theme.geometry_statusBar_button_icon_width
				height: Theme.geometry_statusBar_button_icon_height
				rotation: 180
				color: mouseArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
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
