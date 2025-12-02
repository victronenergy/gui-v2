/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
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

		ButtonGroup {
			id: stateRadioButtonGroup
		}

		Repeater {
			id: repeater

			width: parent.width
			model: Global.systemSettings.ess.stateModel
			delegate: SettingsColumn {
				width: parent.width

				ListRadioButton {
					writeAccessLevel: VenusOS.User_AccessType_User
					text: modelData.display
					flat: true
					checked: Global.systemSettings.ess.state === modelData.value
					ButtonGroup.group: stateRadioButtonGroup
					onClicked: Global.systemSettings.ess.setState(modelData.value)
				}

				FlatListItemSeparator {}
			}
		}

		ListButton {
			id: minSocLimit

			//% "Minimum SOC"
			text: qsTrId("ess_card_minimum_soc")
			flat: true
			secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Percentage, Global.systemSettings.ess.minimumStateOfCharge)
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: Global.dialogLayer.open(minSocDialogComponent)

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog {
					minimumStateOfCharge: Global.systemSettings.ess.minimumStateOfCharge
					onAccepted: Global.systemSettings.ess.setMinimumStateOfCharge(minimumStateOfCharge)
				}
			}

			VeQuickItem {
				id: batteryLifeState
				uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
			}

			VeQuickItem {
				id: essMode
				uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/Hub4Mode"
			}
		}

		FlatListItemSeparator { visible: minSocLimit.visible && activeSocLimit.visible}

		ListInfoLabel {
			id: activeSocLimit

			preferredVisible: Global.systemSettings.ess.state === VenusOS.Ess_State_OptimizedWithBatteryLife
			//% "Active SOC Limit: %1%"
			text: qsTrId("ess_active_soc_limit").arg(Math.max(Global.systemSettings.ess.minimumStateOfCharge, Global.systemSettings.ess.stateOfChargeLimit))
			flat: true

			PressArea {
				anchors.fill: parent
				onClicked: {
					//% "BatteryLife dynamically adjusts the minimum battery state of charge to prevent deep discharges and ensure regular full charges, helping to prolong battery life and maintain system reliability."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("ess_active_soc_limit_info"), 10000)
				}
			}
		}
	}
}
