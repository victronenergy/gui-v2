/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ControlCard {
	id: root

	property string serviceUid

	readonly property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)

	icon.source: "qrc:/images/icon_charging_station_24.svg"

	//: %1 = the EVCS name
	//% "EVCS (%1)"
	title.text: qsTrId("controlcard_evcs_title").arg(device.name)
	status.text: Global.evChargers.chargerStatusToText(statusItem.value)

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
		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		ListButton {
			id: modeListButton
			text: CommonWords.mode
			secondaryText: Global.evChargers.chargerModeToText(modeItem.value)
			flat: true
			interactive: modeItem.valid
			onClicked: Global.dialogLayer.open(modeDialogComponent, { mode: modeItem.value })
		}

		FlatListItemSeparator {
			visible: modeListButton.visible
		}

		ListSpinBox {
			id: chargeCurrentSpinBox

			text: CommonWords.charge_current
			flat: true
			suffix: Units.defaultUnitString(VenusOS.Units_Amp)
			from: 0
			stepSize: 1
			dataItem.uid: root.serviceUid + "/SetCurrent"
			preferredVisible: dataItem.valid
			interactive: dataItem.valid && modeItem.value === VenusOS.Evcs_Mode_Manual

			VeQuickItem {
				id: maxCurrent
				uid: root.serviceUid + "/MaxCurrent"
				onValueChanged: {
					if (valid) {
						chargeCurrentSpinBox.to = value
					}
				}
			}
		}

		FlatListItemSeparator {
			visible: chargeCurrentSpinBox.visible
		}

		ListSwitch {
			text: CommonWords.charging
			flat: true
			dataItem.uid: root.serviceUid + "/StartStop"
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
