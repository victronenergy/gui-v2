/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

ControlCard {
	id: root

	property int essModeIndex: 0
	property int minimumSOC: 90
	property int batteryLifeLimit: 80

	title.icon.source: "qrc:/images/ess.svg"
	//% "ESS"
	title.text: qsTrId("controlcard_ess")

	Column {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.controlCard.mediumItem.height
		}
		width: parent.width
		Repeater {
			id: repeater

			width: parent.width
			model: ControlCardsModel.essModeStrings
			delegate: Item {
				width: parent.width
				height: Theme.geometry.controlCard.mediumItem.height
				RadioButton {
					id: button

					anchors {
						verticalCenter: parent.verticalCenter
						left: parent.left
						leftMargin: Theme.geometry.controlCard.contentMargins
						right: parent.right
						rightMargin: Theme.geometry.controlCard.contentMargins
					}
					label.font.pixelSize: 18
					label.topPadding: 1
					checked: root.essModeIndex === index
					text: qsTrId(modelData)
					onClicked: root.essModeIndex = index
				}
				SeparatorBar {
					anchors {
						bottom: parent.bottom
						left: parent.left
						right: parent.right
						leftMargin: Theme.geometry.controlCard.itemSeparator.margins
						rightMargin: Theme.geometry.controlCard.itemSeparator.margins
					}
				}
			}
		}
		Item {
			id: minimumSocRow
			height: 72
			width: parent.width

			Label {
				id: minimumSocLabel
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Theme.geometry.controlCard.contentMargins
				}

				//% "Minimum SOC"
				text: qsTrId("ess_card_minimum_soc")
			}
			Button {
				id: minimumSocButton
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Theme.geometry.controlCard.contentMargins
				}
				height: Theme.geometry.essCard.minimumSocButton.height
				width: Theme.geometry.essCard.minimumSocButton.width

				flat: false
				color: Theme.color.font.primary
				font.pixelSize: Theme.font.size.m

				text: qsTrId("%1%").arg(root.minimumSOC)

				onClicked: {
					dialogManager.essMinimumSOCDialog.newMinimumSOC = root.minimumSOC
					dialogManager.essMinimumSOCDialog.open()
				}
			}
			SeparatorBar {
				anchors {
					bottom: parent.bottom
					left: parent.left
					right: parent.right
					leftMargin: Theme.geometry.controlCard.itemSeparator.margins
					rightMargin: Theme.geometry.controlCard.itemSeparator.margins
				}
			}
		}
		Item {
			id: warningRow
			height: Theme.geometry.controlCard.mediumItem.height
			width: parent.width

			Label {
				id: warning
				anchors {
					left: parent.left
					leftMargin: Theme.geometry.controlCard.contentMargins
					verticalCenter: parent.verticalCenter
				}
				visible: root.minimumSOC < root.batteryLifeLimit
				color: Theme.color.font.tertiary
				font.family: VenusFont.normal.name
				font.pixelSize: Theme.font.size.s
				//% "Battery life limit: %1%"
				text: qsTrId("ess_battery_life_limit").arg(root.batteryLifeLimit)
			}
			CP.IconImage {
				visible: warning.visible
				anchors {
					right: parent.right
					rightMargin: Theme.geometry.essCard.warningIcon.rightMargin
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/information.svg"
				color: Theme.color.font.primary
			}
		}
	}
	Connections {
		target: dialogManager.essMinimumSOCDialog
		function onSetMinimumSOC(newValue) {
			root.minimumSOC = newValue
		}
	}
}
