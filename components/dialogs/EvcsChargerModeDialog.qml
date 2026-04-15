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
		implicitHeight: contentColumn.height

		SettingsColumn {
			id: contentColumn
			x: Theme.geometry_modalDialog_content_horizontalMargin
			width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin)
			bottomPadding: Theme.geometry_modalDialog_content_spacing

			Repeater {
				id: repeater
				model: Global.evChargers.modeOptionModel
				delegate: SettingsColumn {
					width: parent.width

					ListRadioButton {
						flat: true
						checked: modelData.value === root.mode
						text: modelData.display
						writeAccessLevel: VenusOS.User_AccessType_User
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
