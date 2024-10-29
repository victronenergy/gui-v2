/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property string serviceUid
	property string name
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)

	icon.source: "qrc:/images/inverter_charger.svg"
	title.text: serviceType === "inverter"
		  //: %1 = the inverter name
		  //% "Inverter (%1)"
		? qsTrId("controlcard_inverter").arg(name)
		  //: %1 = the inverter/charger name
		  //% "Inverter / Charger (%1)"
		: qsTrId("controlcard_inverter_charger").arg(name)

	status.text: Global.system.systemStateToText(stateItem.value)

	VeQuickItem {
		id: stateItem
		uid: root.serviceUid + "/State"
	}

	Column {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		Repeater {
			model: AcInputSettingsModel {
				serviceUid: root.serviceUid
			}
			delegate: Column {
				width: parent.width

				ListItem {
					text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
					flat: true
					content.children: CurrentLimitButton {
						serviceUid: root.serviceUid
						inputNumber: modelData.inputNumber
						inputType: modelData.inputType
					}
				}

				FlatListItemSeparator {}
			}
		}

		ListItem {
			text: CommonWords.mode
			flat: true
			content.children: [
				InverterChargerModeButton {
					width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
					serviceUid: root.serviceUid
				}
			]
		}
	}
}
