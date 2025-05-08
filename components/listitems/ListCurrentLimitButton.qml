/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	required property string serviceUid
	required property int inputNumber // note this is 1-based, i.e. first AC input has inputNumber=1, not 0
	required property int inputType

	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)
	readonly property bool limitAdjustable: currentLimitIsAdjustable.value !== 0

	function _currentLimitNotAdjustableText() {
		if (serviceType !== "acsystem") {
			if (dmc.valid) {
				return CommonWords.noAdjustableByDmc
			} else if (bmsMode.valid) {
				return CommonWords.noAdjustableByBms
			}
		}
		//% "This current limit is fixed in the system configuration. It cannot be adjusted."
		return qsTrId("rs_current_limit_not_adjustable")
	}

	text: Global.acInputs.currentLimitTypeToText(inputType)
	secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Amp, currentLimitItem.value)
	button.showEnabled: limitAdjustable
	writeAccessLevel: VenusOS.User_AccessType_User

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
			productId: productIdItem.valid ? productIdItem.value : 0
			title: Global.acInputs.currentLimitTypeToText(root.inputType)
			secondaryTitle: CommonWords.acInputFromNumber(root.inputNumber)
			onAccepted: currentLimitItem.setValue(value)
		}
	}
}
