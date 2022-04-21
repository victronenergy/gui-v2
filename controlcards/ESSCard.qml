/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls
import QtQuick.Controls.impl as CP

ControlCard {
	id: root

	property int state
	property int minimumStateOfCharge
	property int stateOfChargeLimit

	signal changeState(newState: int)
	signal changeMinimumStateOfCharge(newMinSoc: int)

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
			model: [
				VenusOS.Ess_State_KeepBatteriesCharged,
				VenusOS.Ess_State_OptimizedWithBatteryLife,
				VenusOS.Ess_State_OptimizedWithoutBatteryLife,
			]
			delegate: RadioButtonControlValue {
				button.checked: root.state === modelData
				label.text: {
					switch (modelData) {
					case VenusOS.Ess_State_OptimizedWithBatteryLife:
						//% "Optimized with battery life"
						return qsTrId('ess_card_optimized_with_battery_life')
					case VenusOS.Ess_State_KeepBatteriesCharged:
						//% "Keep batteries charged"
						return qsTrId('ess_card_keep_batteries_charged')
					case VenusOS.Ess_State_OptimizedWithoutBatteryLife:
						//% "Optimized without battery life"
						return qsTrId('ess_card_optimized_without_battery_life')
					default:
						return ""
					}
				}

				onClicked: root.changeState(modelData)
			}
		}

		ButtonControlValue {
			id: minimumSocRow

			//% "Minimum SOC"
			label.text: qsTrId("ess_card_minimum_soc")
			button.text: qsTrId("%1%").arg(root.minimumStateOfCharge)
			onClicked: {
				dialogManager.essMinimumSOCDialog.minimumStateOfCharge = root.minimumStateOfCharge
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
				visible: root.state === VenusOS.Ess_State_OptimizedWithBatteryLife
				color: Theme.color.font.tertiary
				font.family: VenusFont.normal.name
				font.pixelSize: Theme.font.size.s
				//% "Battery life limit: %1%"
				text: qsTrId("ess_battery_life_limit").arg(root.stateOfChargeLimit)
			}

			CP.IconImage {
				visible: warning.visible
				anchors {
					right: parent.right
					rightMargin: Theme.geometry.controlCard.contentMargins
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/information.svg"
				color: Theme.color.ok
			}
		}
	}

	Connections {
		target: dialogManager.essMinimumSOCDialog
		function onAccepted() {
			root.changeMinimumStateOfCharge(dialogManager.essMinimumSOCDialog.minimumStateOfCharge)
		}
	}
}
