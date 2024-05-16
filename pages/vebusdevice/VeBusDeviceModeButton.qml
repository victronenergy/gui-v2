/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	'VeBusDeviceModeButton' allow the user to plug in any style of button via 'sourceComponent', and handles raising all of the toast notifications
	that might occur when attempting to change the mode.
*/
Loader {
	id: root

	property var veBusDevice
	readonly property bool isMulti: veBusDevice.numberOfAcInputs > 0

	//% "This setting is disabled when a Digital Multi Control is connected."
	readonly property string noAdjustableByDmc: qsTrId("vebus_no_adjustable_by_dmc")
	//% "This setting is disabled when a VE.Bus BMS is connected."
	readonly property string noAdjustableByBms: qsTrId("vebus_no_adjustable_by_bms")
	//% "This setting is disabled. Possible reasons are \"Overruled by remote\" is not enabled or an assistant is preventing the adjustment. Please, check the inverter configuration with VEConfigure."
	readonly property string noAdjustableTextByConfig: qsTrId("vebus_no_adjustable_text_by_config")

	sourceComponent: listButton
	width: parent ? parent.width : 0

	VeQuickItem {
		id: bmsMode

		uid: veBusDevice.serviceUid + "/Devices/Bms/Version"
	}

	VeQuickItem {
		id: dmc

		uid: root.veBusDevice.serviceUid + "/Devices/Dmc/Version"
	}

	Connections {
		target: root.item

		function onClicked() {
			if (!root.veBusDevice.modeAdjustable) {
				if (dmc.isValid)
					Global.showToastNotification(VenusOS.Notification_Info, root.noAdjustableByDmc,
												 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
				if (bmsMode.value !== undefined)
					Global.showToastNotification(VenusOS.Notification_Info, root.noAdjustableByBms,
												 Theme.animation_veBusDeviceModeNotAdjustable_toastNotication_duration)
				return
			}

			Global.dialogLayer.open(modeDialogComponent, {mode: root.veBusDevice.mode, hasPassthroughSupport: root.veBusDevice.hasPassthroughSupport})
		}
	}

	Component {
		id: listButton

		ListButton {
			text: CommonWords.mode
			button.width: Theme.geometry_vebusDeviceListPage_currentLimit_button_width
			button.text: Global.inverterChargers.inverterChargerModeToText(root.veBusDevice.mode)
			writeAccessLevel: VenusOS.User_AccessType_User
		}
	}

	Component {
		id: modeDialogComponent

		InverterChargerModeDialog {
			isMulti: root.isMulti
			onAccepted: root.veBusDevice.setMode(mode)
		}
	}
}

