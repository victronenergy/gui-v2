/*53 Victron Energy B.V.
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

	contentItem: Item {
		id: passwordEntryItem

		// The current ListTextField behavior is that the validation happens as you type.
		// This validation also happens as you type, so there is no need for onAccepted, onFocusChanged, or on[Confirm]Clicked.

		// The firstPassword is checked only for length;
		// the secondPassword is checked only for matching the firstPassword
		// Note: the length check of the secondPassword is implicit
		// in that it must match the firstPassword which must meet minimum length

		readonly property bool passwordLengthTooShort: firstPassword.length < 8
		readonly property bool passwordMismatch: firstPassword.text !== secondPassword.text
		readonly property bool passwordInvalid: passwordLengthTooShort || passwordMismatch

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

				//% "Enter new password"
				placeholderText: qsTrId("settings_security_profile_enter_new_password")
				echoMode: TextInput.Password

				borderColor: length > 0 && passwordEntryItem.passwordLengthTooShort ? Theme.color_critical : Theme.color_ok
			}

			TextField {
				id: secondPassword

				Layout.fillWidth: true

				//% "Confirm new password"
				placeholderText: qsTrId("settings_security_profile_confirm_new_password")
				echoMode: TextInput.Password

				borderColor: !passwordEntryItem.passwordLengthTooShort &&
							 passwordEntryItem.passwordMismatch ? Theme.color_critical : Theme.color_ok
			}

			Label {
				id: passwordErrorCaption

				//% "Password needs to be at least 8 characters long"
				text: passwordEntryItem.passwordLengthTooShort ? qsTrId("settings_security_profile_password_incorrect_length") :
																 //% "Passwords do not match, please check"
																 passwordEntryItem.passwordMismatch ? qsTrId("settings_security_profile_password_mismatch") : ""
				visible: passwordEntryItem.passwordInvalid

				Layout.fillWidth: true
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_red
				horizontalAlignment: Label.AlignHCenter
				wrapMode: Text.Wrap
			}
		}
	}

	tryAccept: function() {
		return !passwordEntryItem.passwordInvalid
	}
}
