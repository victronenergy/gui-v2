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

	icon.source: "qrc:/images/ess.svg"
	//% "ESS"
	title.text: qsTrId("controlcard_ess")

	Column {
		anchors {
			top: parent.top
			topMargin: 54
		}
		width: parent.width
		Repeater {
			id: repeater

			width: parent.width
			model: ControlCardsModel.essModeStrings
			delegate: Item {
				width: parent.width
				height: 56
				RadioButton {
					id: button

					anchors {
						top: parent.top
						topMargin: 10
						left: parent.left
						leftMargin: 12
						right: parent.right
						rightMargin: 14
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
						horizontalCenter: parent.horizontalCenter
					}
					width: parent.width - 16
				}
			}
		}
		ControlValue {
			anchors {
				left: parent.left
				leftMargin: 10
			}
			topPadding: 16
			spacing: 15
			rectangle.width: 112
			//% "Minimum SOC"
			label.text: qsTrId("ess_card_minimum_soc")
			displayValue.text: qsTrId("%1%").arg(root.minimumSOC)
			onClicked: {
				dialogManager.essMinimumSOCDialog.newMinimumSOC = root.minimumSOC
				dialogManager.essMinimumSOCDialog.open()
			}
		}
		CP.IconLabel {
			id: warning

			anchors {
				left: parent.left
				leftMargin: 18
			}
			topPadding: 17
			spacing: 135
			mirrored: true
			visible: root.minimumSOC < root.batteryLifeLimit
			icon.source: "qrc:/images/information.svg"
			color: Theme.weatherColor
			font.family: VenusFont.normal.name
			font.pixelSize: Theme.fontSizeMedium
			//% "Battery life limit: %1%"
			text: qsTrId("ess_battery_life_limit").arg(root.batteryLifeLimit)
		}
	}
	Connections {
		target: dialogManager.essMinimumSOCDialog
		function onSetMinimumSOC(newValue) {
			root.minimumSOC = newValue
		}
	}
}
