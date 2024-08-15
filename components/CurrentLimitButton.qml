/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItemButton {
	id: root

	property string serviceUid
	property int inputNumber

	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)
	readonly property int writeAccessLevel: VenusOS.User_AccessType_User
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)

	text: Units.getCombinedDisplayText(VenusOS.Units_Amp, currentLimitItem.value)
	enabled: userHasWriteAccess

	onClicked: {
		if (!currentLimitIsAdjustable.isValid || !currentLimitIsAdjustable.value) {
			if (serviceType === "acsystem") {
				//% "This current limit is configured as fixed, not user changeable."
				Global.showToastNotification(VenusOS.Notification_Info, qsTrId("rs_current_limit_not_adjustable"), 5000)
			} else if (dmc.isValid) {
				Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByDmc,
											 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
			} else if (bmsMode.isValid) {
				Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByBms,
											 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
			} else {
				Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableTextByConfig,
											 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
			}
			return
		}
		Global.dialogLayer.open(currentLimitDialogComponent, { value: currentLimitItem.value })
	}

	VeQuickItem {
		id: currentLimitItem
		uid: root.serviceUid + "/Ac/In/" + root.inputNumber + "/CurrentLimit"
	}

	VeQuickItem {
		id: currentLimitIsAdjustable
		uid: root.serviceUid + "/Ac/In/" + root.inputNumber + "/CurrentLimitIsAdjustable"
	}

	VeQuickItem {
		id: bmsMode
		uid: root.serviceUid + "/Devices/Bms/Version"
	}

	VeQuickItem {
		id: dmc
		uid: root.serviceUid + "/Devices/Dmc/Version"
	}

	VeQuickItem {
		id: productIdItem
		uid: root.serviceUid + "/ProductId"
	}

	Component {
		id: currentLimitDialogComponent

		CurrentLimitDialog {
			productId: productIdItem.isValid ? productIdItem.value : 0
			secondaryTitle: CommonWords.acInput(root.inputNumber)
			onAccepted: currentLimitItem.setValue(value)
		}
	}
}
