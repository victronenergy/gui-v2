/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ControlCard {
	id: root

	// can only assume this is a Device because there could be Energy Meters in the Global.evChargers.model
	// as well as EvCharger
	property Device evCharger

	readonly property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)

	icon.source: "qrc:/images/icon_charging_station_24.svg"

	//: %1 = the EVCS name
	//% "EVCS (%1)"
	title.text: qsTrId("controlcard_evcs_title").arg(evCharger.name)
	status.text: Global.evChargers.chargerStatusToText(evCharger.status)

	// do not show this card if not an EvCharger
	visible: modeItem.isValid

	VeQuickItem {
		id: modeItem
		uid: root.evCharger.serviceUid + "/Mode"
	}

	Column {
		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		ListItem {
			id: modeListItem

			text: CommonWords.mode
			flat: true
			enabled: root.userHasWriteAccess && modeItem.isValid

			content.children: ListItemButton {
				width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
				text: Global.evChargers.chargerModeToText(modeItem.value)
				onClicked: Global.dialogLayer.open(modeDialogComponent, { mode: modeItem.value })
			}
		}

		FlatListItemSeparator {
			visible: modeListItem.visible
		}

		ListSpinBox {
			id: chargeCurrentSpinBox

			text: CommonWords.charge_current
			flat: true
			suffix: Units.defaultUnitString(VenusOS.Units_Amp)
			from: 0
			to: root.evCharger.maxCurrent
			stepSize: 1
			dataItem.uid: root.evCharger.serviceUid + "/SetCurrent"
			allowed: defaultAllowed && dataItem.isValid
			enabled: modeItem.value === VenusOS.Evcs_Mode_Manual
		}

		FlatListItemSeparator {
			visible: chargeCurrentSpinBox.visible
		}

		ListSwitch {
			text: CommonWords.charging
			flat: true
			dataItem.uid: root.evCharger.serviceUid + "/StartStop"
			allowed: defaultAllowed && dataItem.isValid
		}
	}

	Component {
		id: modeDialogComponent

		EvcsChargerModeDialog {
			onAccepted: modeItem.setValue(mode)
		}
	}
}