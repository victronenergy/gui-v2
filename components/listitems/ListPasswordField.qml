/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a text field and a "Confirm" button.

	The text is only validated when the button is clicked, and not when it loses focus.
*/
ListTextField {
	id: root

	readonly property ListItemButton confirmButton: ListItemButton {
		//: Confirm password, and verify it if possible
		//% "Confirm"
		text: qsTrId("settings_radio_button_group_confirm")
		visible: root.interactive
		focusPolicy: Qt.NoFocus
		onClicked: root.runValidation(VenusOS.InputValidation_ValidateAndSave)
	}

	//% "Enter password"
	placeholderText: qsTrId("settings_radio_button_enter_password")
	echoMode: TextInput.Password
	validateOnFocusLost: false

	content.children: [
		defaultContent,
		confirmButton
	]
}
