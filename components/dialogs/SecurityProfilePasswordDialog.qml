/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ModalDialog {
	id: root

	//% "Changing the GX Password"
	title: qsTrId("settings_security_profile_change_password_title")

	//% "Confirm"
	acceptText: qsTrId("modaldialog_confirm")

	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

	Component.onCompleted: resetValidation()

	property string password

	function validate() : bool {

		root.password = ""

		if (firstPassword.length < 8) {

			// First, validate that the firstPassword is at least 8 characters long.
			// If not, the border of both firstPassword AND secondPassword turn red and
			// the passwordHint warning about length, becomes visible.

			firstPassword.borderColor = Theme.color_critical
			secondPassword.borderColor = Theme.color_critical
			passwordHint.visible = true
			//% "Password needs to be at least 8 characters long"
			passwordHint.text = qsTrId("settings_security_profile_password_incorrect_length")

			return false
		}

		if (firstPassword.text !== secondPassword.text) {
			// Secondly, validate that the passwords in both firstPassword AND secondPassword are equal.
			// If not, the border of both firstPassword AND secondPassword turn red and
			// the passwordHint warning about mismatch, becomes visible.

			firstPassword.borderColor = Theme.color_critical
			secondPassword.borderColor = Theme.color_critical
			passwordHint.visible = true
			//% "Passwords do not match, please check"
			passwordHint.text = qsTrId("settings_security_profile_password_mismatch")

			return false
		}

		resetValidation()

		root.password = firstPassword.text

		return true
	}

	function resetValidation() {

		// As soon as the input in any input field changes,
		// the borderColor turns back to blue and the red passwordHint turns invisible.
		// This is also this is ths default "validated" state

		firstPassword.borderColor = Theme.color_ok
		secondPassword.borderColor = Theme.color_ok
		passwordHint.visible = false
		passwordHint.text = ""
	}

	contentItem: Item {
		id: passwordEntryItem

		ColumnLayout {
			anchors {
				top: parent.top
				topMargin: Theme.geometry_modalWarningDialog_title_spacing
				horizontalCenter: parent.horizontalCenter
			}

			spacing: Theme.geometry_modalWarningDialog_title_spacing

			Label {
				id: description

				Layout.fillWidth: true

				//% "Please assign a new GX password\nby entering it twice:"
				text: qsTrId("settings_security_profile_change_password_description")

				font.pixelSize: Theme.font_size_body2
				horizontalAlignment: Label.AlignHCenter
				wrapMode: Text.Wrap
			}

			TextField {
				id: firstPassword

				Layout.fillWidth: true

				focus: true

				//% "Enter new password"
				placeholderText: qsTrId("settings_security_profile_enter_new_password")
				echoMode: TextInput.Password

				// As soon as the input in any input field changes,
				// the borderColors turns back to blue and the red passwordHint turns invisible.
				onTextEdited: root.resetValidation()
			}

			TextField {
				id: secondPassword

				Layout.fillWidth: true

				//% "Confirm new password"
				placeholderText: qsTrId("settings_security_profile_confirm_new_password")
				echoMode: TextInput.Password

				// As soon as the input in any input field changes,
				// the borderColors turns back to blue and the red passwordHint turns invisible.
				onTextEdited: root.resetValidation()
			}

			Label {
				id: passwordHint

				Layout.fillWidth: true
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_red
				horizontalAlignment: Label.AlignHCenter
				wrapMode: Text.Wrap
			}
		}
	}

	tryAccept: function() {
		// When “Confirm” is tapped the passwords shall be validated
		return root.validate()
	}
}
