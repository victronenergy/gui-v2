/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItemButton {
	id: root

	property string serviceUid

	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)
	readonly property int writeAccessLevel: VenusOS.User_AccessType_User
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool modeAdjustable: modeIsAdjustable.value !== 0

	text: serviceType !== "inverter" || isInverterChargerItem.value === 1
			? Global.inverterChargers.inverterChargerModeToText(modeItem.value)
			: Global.inverterChargers.inverterModeToText(modeItem.value)

	// TODO need to show a different indicator (like in settings pages) when a control is disabled
	// due to reduced user access level. This is different from when the control is disabled due to
	// the mode not being adjustable.
	enabled: userHasWriteAccess
	showEnabled: modeAdjustable

	onClicked: {
		if (!modeAdjustable) {
			if (dmc.isValid) {
				Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByDmc,
											 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
			} else if (bmsMode.isValid) {
				Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByBms,
											 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
			} else {
				//% "The mode is fixed in the system configuration. It cannot be adjusted."
				Global.showToastNotification(VenusOS.Notification_Info, qsTrId("inverter_mode_not_adjustable"),
											 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
			}
			return
		}

		Global.dialogLayer.open(modeDialogComponent, { mode: modeItem.value })
	}

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.serviceUid + "/IsInverterCharger"
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

	Component {
		id: modeDialogComponent

		InverterChargerModeDialog {
			serviceUid: root.serviceUid
			onAccepted: modeItem.setValue(mode)
		}
	}
}
