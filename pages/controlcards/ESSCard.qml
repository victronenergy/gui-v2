/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

ControlCard {
	id: root

	implicitHeight: contentLayout.y + contentLayout.implicitHeight
	icon.source: "qrc:/images/ess.svg"
	title.text: CommonWords.ess

	SettingsColumn {
		id: contentLayout

		anchors {
			top: root.title.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}
		bottomPadding: Theme.geometry_controlCard_contentMargins
		width: parent.width

		ButtonGroup {
			id: stateRadioButtonGroup
		}

		Repeater {
			id: repeater

			width: parent.width
			model: Services.settings.ess.stateModel
			delegate: SettingsColumn {
				width: parent.width

				ListRadioButton {
					writeAccessLevel: VenusOS.User_AccessType_User
					text: modelData.display
					flat: true
					checked: Services.settings.ess.state === modelData.value
					ButtonGroup.group: stateRadioButtonGroup
					onClicked: Services.settings.ess.setState(modelData.value)
				}

				FlatListItemSeparator {}
			}
		}

		ListButton {
			id: minSocLimit

			//% "Minimum SOC"
			text: qsTrId("ess_card_minimum_soc")
			flat: true
			secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Percentage, Services.settings.ess.minimumStateOfCharge)
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: Global.dialogLayer.open(minSocDialogComponent)

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog {
					minimumStateOfCharge: Services.settings.ess.minimumStateOfCharge
					onAccepted: Services.settings.ess.setMinimumStateOfCharge(minimumStateOfCharge)
				}
			}

			VeQuickItem {
				id: batteryLifeState
				uid: Services.settings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
			}

			VeQuickItem {
				id: essMode
				uid: Services.settings.serviceUid + "/Settings/CGwacs/Hub4Mode"
			}
		}

		FlatListItemSeparator { visible: minSocLimit.visible && activeSocLimit.visible}

		ListInfoLabel {
			id: activeSocLimit

			preferredVisible: Services.settings.ess.state === VenusOS.Ess_State_OptimizedWithBatteryLife
			//% "Active SOC Limit: %1%"
			text: qsTrId("ess_active_soc_limit").arg(Math.max(Services.settings.ess.minimumStateOfCharge, Services.settings.ess.stateOfChargeLimit))
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
