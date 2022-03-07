/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int mode

	function modeText(m) {
		switch (m) {
		case Inverters.InverterMode.On:
			//% "On"
			return qsTrId("inverter_charger_mode_charger_on")
		case Inverters.InverterMode.ChargerOnly:
			//% "Charger only"
			return qsTrId("inverter_charger_mode_charger_only")
		case Inverters.InverterMode.InverterOnly:
			//% "Inverter only"
			return qsTrId("inverter_charger_mode_inverter_only")
		case Inverters.InverterMode.Off:
			//% "Off"
			return qsTrId("inverter_charger_mode_off")
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
				Inverters.InverterMode.On,
				Inverters.InverterMode.ChargerOnly,
				Inverters.InverterMode.InverterOnly,
				Inverters.InverterMode.Off,
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
