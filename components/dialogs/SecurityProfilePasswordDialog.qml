/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ModalDialog {
	id: root

	property string password

	function validate() {
		root.password = ""

		if (firstPassword.text.length < 8) {
			// First, validate that the firstPassword is at least 8 characters long.
			//% "Password needs to be at least 8 characters long"
			passwordHint.text = qsTrId("settings_security_profile_password_incorrect_length")
			return Utils.validationResult(VenusOS.InputValidation_Result_Error)
		}

		resetValidation()
		root.password = firstPassword.text

		return Utils.validationResult(VenusOS.InputValidation_Result_OK)
	}

	function resetValidation() {
		passwordHint.text = ""
	}

	//% "Change the GX Password"
	title: qsTrId("settings_security_profile_change_password_title")

	//% "Confirm"
	acceptText: qsTrId("modaldialog_confirm")

	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

	// Since the text field is the only visible item in this dialog, allow it to receive focus as
	// soon as the dialog is opened.
	focus: true

	Component.onCompleted: resetValidation()

	contentItem: ModalDialog.FocusableContentItem {
		implicitHeight: contentColumn.implicitHeight

		ColumnLayout {
			id: contentColumn

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_modalDialog_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_modalDialog_content_horizontalMargin
			}
			spacing: Theme.geometry_modalDialog_content_spacing

			Label {
				id: description

				Layout.fillWidth: true

				//% "Please enter a new GX password:"
				text: qsTrId("settings_security_profile_change_password_description")

				font.pixelSize: Theme.font_size_body2
				horizontalAlignment: Label.AlignHCenter
				wrapMode: Text.Wrap
			}

			TextValidationField {
				id: firstPassword

				Layout.fillWidth: true

				focus: true

				//% "Enter new password"
				placeholderText: qsTrId("settings_security_profile_enter_new_password")
				echoMode: TextInput.Password
				validateInput: root.validate

				// As soon as the input changes, remove the password hint.
				onTextEdited: root.resetValidation()
			}

			Label {
				id: passwordHint

				Layout.fillWidth: true
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_red
				horizontalAlignment: Label.AlignHCenter
				wrapMode: Text.Wrap
				opacity: text.length > 0 ? 1 : 0
			}
		}
	}

	tryAccept: function() {
		// When “Confirm” is tapped the passwords shall be validated
		return root.validate().status === VenusOS.InputValidation_Result_OK
	}
}
