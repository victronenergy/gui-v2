/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItemButton {
	id: root

	property string serviceUid

	readonly property int writeAccessLevel: VenusOS.User_AccessType_User
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)

	text: Global.inverterChargers.inverterChargerModeToText(modeItem.value)
	enabled: userHasWriteAccess

	onClicked: {
		if (modeIsAdjustable.isValid && !modeIsAdjustable.value) {
			if (dmc.isValid) {
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

		const properties = {
			mode: modeItem.value,
			isMulti: numberOfAcInputs.isValid && numberOfAcInputs.value > 0,
			hasPassthroughSupport: hasAcPassthroughSupport.value === 1
		}
		Global.dialogLayer.open(modeDialogComponent, properties)
	}

	VeQuickItem {
		id: modeItem
		uid: root.serviceUid + "/Mode"
	}

	VeQuickItem {
		id: modeIsAdjustable
		uid: root.serviceUid + "/ModeIsAdjustable"
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
		id: numberOfAcInputs
		uid: root.serviceUid + "/Ac/NumberOfAcInputs"
	}

	VeQuickItem {
		id: hasAcPassthroughSupport
		uid: root.serviceUid + "/Capabilities/HasAcPassthroughSupport"
	}

	Component {
		id: modeDialogComponent

		InverterChargerModeDialog {
			onAccepted: modeItem.setValue(mode)
		}
	}
}
