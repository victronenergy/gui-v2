/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP

ControlCard {
	id: root

	icon.source: "qrc:/images/ess.svg"
	title.text: CommonWords.ess

	SettingsColumn {
		anchors {
			top: root.title.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}
		width: parent.width

		C.ButtonGroup {
			id: stateRadioButtonGroup
		}

		Repeater {
			id: repeater

			width: parent.width
			model: Global.ess.stateModel
			delegate: SettingsColumn {
				width: parent.width

				ListRadioButton {
					text: modelData.display
					flat: true
					checked: Global.ess.state === modelData.value
					C.ButtonGroup.group: stateRadioButtonGroup
					onClicked: Global.ess.setStateRequested(modelData.value)
				}

				FlatListItemSeparator {}
			}
		}

		ListButton {
			//% "Minimum SOC"
			text: qsTrId("ess_card_minimum_soc")
			flat: true
			secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Percentage, Global.ess.minimumStateOfCharge)
			onClicked: Global.dialogLayer.open(minSocDialogComponent)

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog {
					minimumStateOfCharge: Global.ess.minimumStateOfCharge
					onAccepted: Global.ess.setMinimumStateOfChargeRequested(minimumStateOfCharge)
				}
			}
		}

		FlatListItemSeparator { visible: batteryLifeLimitWarning.visible}

		ListItem {
			id: batteryLifeLimitWarning

			visible: Global.ess.state === VenusOS.Ess_State_OptimizedWithBatteryLife
			//% "Battery life limit: %1%"
			text: qsTrId("ess_battery_life_limit").arg(Math.max(Global.ess.minimumStateOfCharge, Global.ess.stateOfChargeLimit))
			flat: true
			content.children: [
				CP.IconImage {
					source: "qrc:/images/information.svg"
					color: Theme.color_blue
				}
			]
		}
	}
}
