/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property string serviceUid

	readonly property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	property var clickableSiblings: [ modeListButton.button, chargeCurrentSpinBox.button ]

	icon.source: "qrc:/images/icon_charging_station_24.svg"

	//: %1 = the EVCS name
	//% "EVCS (%1)"
	title.text: qsTrId("controlcard_evcs_title").arg(device.name)
	status.text: Global.evChargers.chargerStatusToText(statusItem.value)
	objectName: "EVCSCard" // TODO: remove

	Device {
		id: device
		serviceUid: root.serviceUid
	}

	VeQuickItem {
		id: statusItem
		uid: root.serviceUid + "/Status"
	}

	VeQuickItem {
		id: modeItem
		uid: root.serviceUid + "/Mode"
	}

	SettingsColumn {

		objectName: root.objectName + ".SettingsColumn"// TODO: remove
		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		ListButton {
			id: modeListButton
			siblings: clickableSiblings
			objectName: root.objectName + ".modeListButton" // TODO: remove
			text: CommonWords.mode
			secondaryText: Global.evChargers.chargerModeToText(modeItem.value)
			flat: true
			interactive: modeItem.valid
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: Global.dialogLayer.open(modeDialogComponent, { mode: modeItem.value })
		}

		FlatListItemSeparator {
			visible: modeListButton.visible
		}

		ListEvcsSetCurrentSpinBox {
			id: chargeCurrentSpinBox

			objectName: root.objectName + ".chargeCurrentSpinBox" // TODO: remove
			siblings: clickableSiblings
			serviceUid: root.serviceUid
			flat: true
			interactive: dataItem.valid && modeItem.value === VenusOS.Evcs_Mode_Manual
		}

		FlatListItemSeparator {
			visible: chargeCurrentSpinBox.visible
		}

		ListSwitch {
			text: CommonWords.charging
			flat: true
			dataItem.uid: root.serviceUid + "/StartStop"
			writeAccessLevel: VenusOS.User_AccessType_User
			preferredVisible: dataItem.valid
		}
	}

	Component {
		id: modeDialogComponent

		EvcsChargerModeDialog {
			onAccepted: modeItem.setValue(mode)
		}
	}
}
