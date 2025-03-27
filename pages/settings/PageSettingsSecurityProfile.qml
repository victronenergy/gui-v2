/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {

		model: VisibleItemModel {

			SettingsListHeader {
				//% "Selected Profile"
				text: qsTrId("settings_security_profile_selected_profile_header")
			}

			SettingsColumn {

				width: parent ? parent.width : 0

				Repeater {
					model: [
						{
							//% "Secured"
							display: qsTrId("settings_security_profile_secured"),
							value: VenusOS.Security_Profile_Secured,
							//% "Password protected and the network communication is encrypted"
							caption: qsTrId("settings_security_profile_secured_caption")
						},
						{
							//% "Weak"
							display: qsTrId("settings_security_profile_weak"),
							value: VenusOS.Security_Profile_Weak,
							//% "Password protected, but the network communication is not encrypted"
							caption: qsTrId("settings_security_profile_weak_caption")
						},
						{
							//% "Unsecured"
							display: qsTrId("settings_security_profile_unsecured"),
							value: VenusOS.Security_Profile_Unsecured,
							//% "No password and the network communication is not encrypted"
							caption: qsTrId("settings_security_profile_unsecured_caption")
						}
					]

					ListRadioButton {
						required property var modelData

						// TODO: all the currentIndex stuff so checked can bind to it.

						text: modelData.display
						caption: modelData.caption

						onClicked: {
							console.log("Clicked", modelData.display)
							// TODO: if we can't use onCheckedChanged, we need to use onClicked,
							// but not do anything if the currentIndex is me - need to know the currentIndex
							Global.dialogLayer.open(securityProfileConfirmationdDialog, { pendingProfile: modelData.value, password: "TODO" })
						}

						onCheckedChanged: {
							// FIXME: this doesn't fire
							// deliberately trying to not using onClicked so that if it is already
							// checked, it won't cause the dialog to open
							Global.dialogLayer.open(securityProfileConfirmationdDialog, { pendingProfile: modelData.value, password: "TODO" })
						}

						Component {
							id: securityProfileConfirmationdDialog

							SecurityProfileConfirmationDialog {
								// pendingProfile is required
								// password is required

								onAccepted: {
									// TODO: change to the selected profile
								}
							}
						}
					}
				}
			}

			SettingsListHeader {
				//% "Settings"
				text: qsTrId("settings_security_profile_settings_header")
			}

			ListButton {
				//% "Change GX Password"
				text: qsTrId("settings_security_profile_change_gx_password")
				//% "Change now"
				secondaryText: qsTrId("settings_security_profile_change_now")
				onClicked: {
					Global.dialogLayer.open(securityProfilePasswordDialog)
				}

				Component {
					id: securityProfilePasswordDialog

					SecurityProfilePasswordDialog {

						onAccepted: {
							// TODO: actually set the password
						}
					}
				}
			}
		}
	}
}
