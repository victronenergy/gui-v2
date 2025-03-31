/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property int currentProfile
	required property string currentPassword
	required property var optionModel
	property int pendingProfile
	property string pendingPassword

	signal updateProfile(profile: int, password: string)

	GradientListView {

		model: VisibleItemModel {

			SettingsListHeader {
				//% "Selected Profile"
				text: qsTrId("settings_security_profile_selected_profile_header")
			}

			SettingsColumn {

				width: parent ? parent.width : 0

				Repeater {
					model: root.optionModel

					ListRadioButton {

						required property var modelData

						// checked uses the value, not the index which is safer
						checked: root.currentProfile === modelData.value

						text: modelData.display
						caption: modelData.caption

						onClicked: {
							if (!checked) {
								Global.dialogLayer.open(securityProfileConfirmationdDialogComponent, { pendingProfile: modelData.value })
							}
						}

						Component {
							id: securityProfileConfirmationdDialogComponent

							SecurityProfileConfirmationDialog {
								id: securityProfileConfirmationdDialog

								currentPassword: root.currentPassword

								onAccepted: {
									if (root.currentPassword.length) {
										root.updateProfile(pendingProfile, currentPassword)
										// This page is popped only when the profile is changed,
										// not when the password is changed.
										Global.pageManager.popPage()
									}
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
					Global.dialogLayer.open(securityProfilePasswordDialogComponent)
				}

				Component {
					id: securityProfilePasswordDialogComponent

					SecurityProfilePasswordDialog {
						id: securityProfilePasswordDialog

						onAccepted: {
							root.updateProfile(root.currentProfile, password)
							// Note: we don't pop the page here
						}
					}
				}
			}
		}
	}
}
