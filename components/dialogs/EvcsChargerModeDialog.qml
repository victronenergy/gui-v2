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

	contentItem: ModalDialog.FocusableContentItem {
		anchors {
			top: root.title.bottom
			left: parent.left
			right: parent.right
			leftMargin: Theme.geometry_modalDialog_content_horizontalMargin
			rightMargin: Theme.geometry_modalDialog_content_horizontalMargin
		}
		height: contentColumn.height

		SettingsColumn {
			id: contentColumn
			anchors.fill: parent

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
}
