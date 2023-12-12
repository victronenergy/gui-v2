/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

ModalDialog {
	id: root

	property int mode
	property bool isMulti

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
				{ value: Enums.VeBusDevice_Mode_On, enabled: true },
				{ value: Enums.VeBusDevice_Mode_ChargerOnly, enabled: root.isMulti },
				{ value: Enums.VeBusDevice_Mode_InverterOnly, enabled: root.isMulti },
				{ value: Enums.VeBusDevice_Mode_Off, enabled: true },
			]
			delegate: buttonStyling
		}
	}

	Component {
		id: buttonStyling

		RadioButtonControlValue {
			enabled: modelData.enabled
			button.checked: modelData.value === root.mode
			label.text: Global.veBusDevices.modeToText(modelData.value)
			onClicked: root.mode = modelData.value
		}
	}
}
