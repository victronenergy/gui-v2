/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property var veBusDevice
	property alias model: currentLimitRepeater.model

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
					if (dmc.isValid) {
						//% "This setting is disabled when a Digital Multi Control is connected. If it was recently disconnected execute 'Redetect system' that is available below on this menu."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_current_limits_dms"), 5000)
						return
					}
					if (bmsMode.isValid) {
						//% "This setting is disabled when a VE.Bus BMS is connected. If it was recently disconnected execute 'Redetect system' that is available below on this menu."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_current_limits_bms"), 5000)
						return
					}
					Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableTextByConfig, 5000)
					return
				}

				Global.dialogLayer.open(currentLimitDialogComponent,
						{ inputType: modelData.inputType, inputIndex: model.index, value: modelData.currentLimit })
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
