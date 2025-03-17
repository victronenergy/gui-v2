/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Dialog for changing the ESS mode on acsystem services, that is Multi-RS
// and HS-19 systems.

ModalDialog {
	id: root

	property int essMode

	//% "ESS mode"
	title: qsTrId("controlcard_inverter_charger_ess_mode")
	contentItem: SettingsColumn {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.geometry_modalDialog_content_horizontalMargin
		}

		Repeater {
			id: repeater
			model: Global.ess.stateModel
			delegate: SettingsColumn {
				width: parent.width

				ListRadioButton {
					flat: true
					checked: modelData.value === root.essMode
					text: modelData.display
					onClicked: root.essMode = modelData.value
				}

				SeparatorBar { 
					width: parent.width
					visible: model.index !== repeater.count - 1 
				}
			}
		}
	}
}
