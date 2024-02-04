/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int mode

	//% "Inverter mode"
	title: qsTrId("controlcard_inverter_mode")

	contentItem: Column {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.geometry_modalDialog_content_horizontalMargin
		}

		Repeater {
			id: repeater
			width: parent.width
			model: [
				{ value: VenusOS.Inverter_Mode_On },
				{ value: VenusOS.Inverter_Mode_Eco },
				{ value: VenusOS.Inverter_Mode_Off },
			]
			delegate: buttonStyling
		}
	}

	Component {
		id: buttonStyling

		RadioButtonControlValue {
			button.checked: modelData.value === root.mode
			label.text: Global.inverterChargers.inverterModeToText(modelData.value)
			onClicked: root.mode = modelData.value
		}
	}
}
