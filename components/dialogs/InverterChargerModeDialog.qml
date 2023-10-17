/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property int mode

	//% "Inverter / Charger mode"
	title: qsTrId("controlcard_inverter_charger_mode")

	contentItem: Column {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.geometry.modalDialog.content.horizontalMargin
		}

		Repeater {
			id: repeater
			width: parent.width
			model: [
				VenusOS.VeBusDevice_Mode_On,
				VenusOS.VeBusDevice_Mode_ChargerOnly,
				VenusOS.VeBusDevice_Mode_InverterOnly,
				VenusOS.VeBusDevice_Mode_Off,
			]
			delegate: buttonStyling
		}
	}

	Component {
		id: buttonStyling

		RadioButtonControlValue {
			button.checked: modelData === root.mode
			label.text: Global.veBusDevices.modeToText(modelData)
			onClicked: root.mode = modelData
		}
	}
}
