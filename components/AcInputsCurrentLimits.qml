/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

Column {
	id: root

	property var veBusDevice
	property alias model: currentLimitRepeater.model
	property var _currentLimitDialog
	//% "This setting is disabled. Possible reasons are \"Overruled by remote\" is not enabled or an assistant is preventing the adjustment. Please, check the inverter configuration with VEConfigure."
	readonly property string noAdjustableTextByConfig: qsTrId("vebus_device_setting_disabled")
	readonly property bool _readOnly: !currentLimitIsAdjustable.isValid || !currentLimitIsAdjustable.value


	VeQuickItem {
		id: dmc

		uid: root.veBusDevice.serviceUid + "/Devices/Dmc/Version"
	}

	VeQuickItem {
		id: bmsMode

		uid: veBusDevice.serviceUid + "/Devices/Bms/Version"
	}

	VeQuickItem {
		id: currentLimitIsAdjustable
		uid: veBusDevice.serviceUid + "/Ac/ActiveIn/CurrentLimitIsAdjustable"
	}

	width: parent ? parent.width : 0

	Repeater {
		id: currentLimitRepeater

		delegate: ListButton {
			text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
			writeAccessLevel: VenusOS.User_AccessType_User
			button.width: Theme.geometry_vebusDeviceListPage_currentLimit_button_width
			button.text: {
				const quantity = Units.getDisplayText(VenusOS.Units_Amp, modelData.currentLimit)
				return quantity.number + quantity.unit
			}
			onClicked: {
				if (_readOnly) {
					if (dmc && dmc.isValid) {
						Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByDmc, 5000)
						return
					}
					if (bmsMode && bmsMode.isValid) {
						Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByBms, 5000)
						return
					}
					Global.showToastNotification(VenusOS.Notification_Info, noAdjustableTextByConfig, 5000)
					return
				}

				if (!root._currentLimitDialog) {
					root._currentLimitDialog = currentLimitDialogComponent.createObject(Global.dialogLayer)
				}
				root._currentLimitDialog.openDialog(modelData, model.index)
			}
		}
	}
	Component {
		id: currentLimitDialogComponent

		CurrentLimitDialog {
			presets: root.veBusDevice.ampOptions
			onAccepted: root.veBusDevice.setCurrentLimit(inputIndex, value)
		}
	}
}
