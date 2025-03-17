/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Dialog for changing the charging mode for EVCS chargers

ModalDialog {
	id: root

	property int mode

	title: CommonWords.mode

	contentItem: SettingsColumn {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: Theme.geometry_modalDialog_content_horizontalMargin
		}

		Repeater {
			id: repeater
			model: Global.evChargers.modeOptionModel
			delegate: SettingsColumn {
				width: parent.width

				ListRadioButton {
					flat: true
					checked: modelData.value === root.mode
					text: modelData.display
					onClicked: root.mode = modelData.value
				}

				SeparatorBar {
					width: parent.width
					visible: model.index !== repeater.count - 1
				}
			}
		}
	}
}
