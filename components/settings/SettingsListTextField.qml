/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.VirtualKeyboard
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias textField: textField
	property alias placeholderText: textField.placeholderText

	content.children: [
		TextField {
			id: textField

			width: Math.max(
					Theme.geometry.settingsListItem.textField.minimumWidth,
					Math.min(implicitWidth + leftPadding + rightPadding, Theme.geometry.settingsListItem.textField.maximumWidth))
			enabled: root.userHasWriteAccess

			EnterKeyAction.actionId: EnterKeyAction.Done
			onAccepted: textField.focus = false

			MouseArea {
				anchors.fill: parent
				onPressed: function(mouse) {
					// Intercept the event before the VKB opens and scroll the parent flickable to
					// ensure the whole textfield is visible.
					const textFieldVerticalMargin = root.height - textField.height
					const textFieldBottom = root.height - textFieldVerticalMargin/2
					Global.aboutToFocusTextField(textField,
							textFieldBottom,
							root.ListView ? root.ListView.view : null)
					mouse.accepted = false
				}
			}
		}
	]
}
