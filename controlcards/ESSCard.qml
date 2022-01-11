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
			delegate: SwitchControlValue {
				button.checked: root.essModeIndex === index
				label.text: qsTrId(modelData)
				onClicked: root.essModeIndex = index
			}
		}
		ButtonControlValue {
			id: minimumSocRow

			//% "Minimum SOC"
			label.text: qsTrId("ess_card_minimum_soc")
			button.text: qsTrId("%1%").arg(root.minimumSOC)
			onClicked: {
				dialogManager.essMinimumSOCDialog.newMinimumSOC = root.minimumSOC
				dialogManager.essMinimumSOCDialog.open()
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
