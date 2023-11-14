/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

ControlCard {
	id: root

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
			model: Global.ess.stateModel
			delegate: RadioButtonControlValue {
				button.checked: Global.ess.state === modelData.value
				label.text: modelData.display

				onClicked: Global.ess.setStateRequested(modelData.value)
			}
		}

		ButtonControlValue {
			id: minimumSocRow

			property var _minSocDialog

			//% "Minimum SOC"
			label.text: qsTrId("ess_card_minimum_soc")
			//: State of charge as a percentage value
			//% "%1%"
			button.text: qsTrId("ess_card_minimum_soc_value").arg(Global.ess.minimumStateOfCharge)
			separator.visible: warningRow.visible

			onClicked: {
				if (!_minSocDialog) {
					_minSocDialog = minSocDialogComponent.createObject(Global.dialogLayer)
				}
				_minSocDialog.open()
			}

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog { }
			}
		}

		Item {
			id: warningRow
			height: Theme.geometry.controlCard.mediumItem.height
			width: parent.width
			visible: Global.ess.state === VenusOS.Ess_State_OptimizedWithBatteryLife

			Label {
				id: warning
				anchors {
					left: parent.left
					leftMargin: Theme.geometry.controlCard.contentMargins
					verticalCenter: parent.verticalCenter
				}
				color: Theme.color.font.secondary
				font.pixelSize: Theme.font.size.body1
				//% "Battery life limit: %1%"
				text: qsTrId("ess_battery_life_limit").arg(Math.max(Global.ess.minimumStateOfCharge, Global.ess.stateOfChargeLimit))
			}

			CP.IconImage {
				anchors {
					right: parent.right
					rightMargin: Theme.geometry.controlCard.contentMargins
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/information.svg"
				color: Theme.color.font.primary
			}
		}
	}
}
