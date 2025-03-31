/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	required property int pendingProfile
	required property string currentPassword

	title: root.currentPassword.length ?
			   //% "Changing the security profile to"
			   qsTrId("settings_security_profile_change_title") :
			   //% "Changing the security profile not possible"
			   qsTrId("settings_security_profile_unable_to_change_title")

	secondaryTitle: {
		if (root.currentPassword.length) {
			switch (root.pendingProfile) {
			case VenusOS.Security_Profile_Secured:
				//% "Secured"
				return qsTrId("settings_security_profile_secured_title")
			case VenusOS.Security_Profile_Weak:
				//% "Weak"
				return qsTrId("settings_security_profile_weak_title")
			case VenusOS.Security_Profile_Unsecured:
				//% "Unsecured"
				return qsTrId("settings_security_profile_unsecured_title")
			default:
				return ""
			}
		}
		// no secondary title in this case;
		// the title will be shown in a larger font
		// To avoid this, set the return value to " " (space)
		return ""
	}

	acceptText: root.currentPassword.length ?
					//% "Confirm"
					qsTrId("modaldialog_confirm") :
					//% "Close"
					qsTrId("modaldialog_close")

	dialogDoneOptions: root.currentPassword.length ?
						   VenusOS.ModalDialog_DoneOptions_OkAndCancel :
						   VenusOS.ModalDialog_DoneOptions_OkOnly

	contentItem: Label {
		verticalAlignment: Label.AlignVCenter
		horizontalAlignment: Label.AlignHCenter
		font.pixelSize: Theme.font_size_body2
		wrapMode: Text.Wrap
		fontSizeMode: Text.Fit
		text: {
			if (root.currentPassword.length) {
				switch (root.pendingProfile) {
				case VenusOS.Security_Profile_Secured:
					//% "\u2022 Local network services are password protected\n• The network communication is encrypted\n• A secure connection with VRM is enabled\n• Insecure settings cannot be enabled"
					return qsTrId("settings_security_profile_secured_description")
				case VenusOS.Security_Profile_Weak:
					//% "\u2022 Local network services are password protected\n• Unencrypted access to local websites is enabled as well (HTTP/HTTPS)"
					return qsTrId("settings_security_profile_weak_description")
				case VenusOS.Security_Profile_Unsecured:
					//% "\u2022 Local network services do not need a password\n• Unencrypted access to local websites is enabled as well (HTTP/HTTPS)"
					return  qsTrId("settings_security_profile_unsecured_description")
				default:
					return ""
				}
			}
			//% "No GX Password has been assigned yet.\nPlease set one before changing the security profile."
			return  qsTrId("settings_security_profile_no_password_set")
		}
	}
}
