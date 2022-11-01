/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property int mode

	function modeText(m) {
		switch (m) {
		case VenusOS.Inverters_Mode_On:
			return Utils.qsTrIdOnOff(1)
		case VenusOS.Inverters_Mode_ChargerOnly:
			//% "Charger only"
			return qsTrId("inverter_charger_mode_charger_only")
		case VenusOS.Inverters_Mode_InverterOnly:
			//% "Inverter only"
			return qsTrId("inverter_charger_mode_inverter_only")
		case VenusOS.Inverters_Mode_Off:
			return Utils.qsTrIdOnOff(0)
		default:
			return ""
		}
	}

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
				VenusOS.Inverters_Mode_On,
				VenusOS.Inverters_Mode_ChargerOnly,
				VenusOS.Inverters_Mode_InverterOnly,
				VenusOS.Inverters_Mode_Off,
			]
			delegate: buttonStyling
		}
	}

	Component {
		id: buttonStyling

		RadioButtonControlValue {
			button.checked: modelData === root.mode
			label.text: root.modeText(modelData)
			onClicked: root.mode = modelData
		}
	}
}
