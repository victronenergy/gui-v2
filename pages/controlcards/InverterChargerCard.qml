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

		Column {
			width: parent ? parent.width : 0

			Repeater {
				model: AcInputSettingsModel {
					serviceUid: root.serviceUid
				}
				delegate: ControlValue {
					width: parent.width
					implicitHeight: Theme.geometry_controlCard_mediumItem_height
					label.text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
					contentRow.children: CurrentLimitButton {
						anchors.verticalCenter: parent.verticalCenter
						width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
						serviceUid: root.serviceUid
						inputNumber: modelData.inputNumber
					}
				}
			}
		}

		ControlValue {
			width: parent.width
			implicitHeight: Theme.geometry_controlCard_mediumItem_height
			label.text: CommonWords.mode
			separator.visible: false
			contentRow.children: InverterChargerModeButton {
				anchors.verticalCenter: parent.verticalCenter
				width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
				serviceUid: root.serviceUid
			}
		}
	}
}
