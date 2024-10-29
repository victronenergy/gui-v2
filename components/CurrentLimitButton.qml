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
	readonly property bool limitAdjustable: currentLimitIsAdjustable.isValid && !!currentLimitIsAdjustable.value

	function _currentLimitNotAdjustableText() {
		if (serviceType !== "acsystem") {
			if (dmc.isValid) {
				return CommonWords.noAdjustableByDmc
			} else if (bmsMode.isValid) {
				return CommonWords.noAdjustableByBms
			}
		}
		//% "This current limit is fixed in the system configuration. It cannot be adjusted."
		return qsTrId("rs_current_limit_not_adjustable")
	}

	text: Units.getCombinedDisplayText(VenusOS.Units_Amp, currentLimitItem.value)

	// TODO need to show a different indicator (like in settings pages) when a control is disabled
	// due to reduced user access level. This is different from when the control is disabled due to
	// the current limit not being adjustable.
	enabled: userHasWriteAccess
	showEnabled: limitAdjustable

	onClicked: {
		if (!limitAdjustable) {
			Global.showToastNotification(VenusOS.Notification_Info, root._currentLimitNotAdjustableText(),
										 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
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
