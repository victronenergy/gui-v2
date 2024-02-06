/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
			margins: Theme.geometry_modalDialog_content_horizontalMargin
		}

		Repeater {
			id: repeater
			width: parent.width
			model: [
				{ value: VenusOS.InverterCharger_Mode_On, enabled: true },
				{ value: VenusOS.InverterCharger_Mode_ChargerOnly, enabled: root.isMulti },
				{ value: VenusOS.InverterCharger_Mode_InverterOnly, enabled: root.isMulti },
				{ value: VenusOS.InverterCharger_Mode_Off, enabled: true },
			]
			delegate: buttonStyling
		}
	}

	Component {
		id: buttonStyling

		RadioButtonControlValue {
			enabled: modelData.enabled
			button.checked: modelData.value === root.mode
			label.text: Global.inverterChargers.inverterChargerModeToText(modelData.value)
			separator.visible: model.index !== repeater.count - 1
			onClicked: root.mode = modelData.value
		}
	}
}
