/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property alias optionModel: repeater.model
	property int currentIndex
	property string currentPassword

	// need signals for changing the securityProfile and changing the password
	signal accepted()

	GradientListView {

		model: VisibleItemModel {

			SettingsListHeader {
				//% "Selected Profile"
				text: qsTrId("settings_security_profile_selected_profile_header")
			}

			SettingsColumn {

				width: parent ? parent.width : 0

				Repeater {
					id: repeater

					ListRadioButton {

						required property int index
						required property var modelData

						checked: root.currentIndex === modelData.value

						text: modelData.display
						caption: modelData.caption

						onClicked: {
							if(!checked) {
								Global.dialogLayer.open(securityProfileIndexConfirmationdDialogComponent, { pendingProfile: modelData.value, password: root.currentPassword })
							}
						}

						Component {
							id: securityProfileIndexConfirmationdDialogComponent

							SecurityProfileConfirmationDialog {
								id: securityProfileConfirmationdDialog

								// pendingProfile is required
								// password is required

								onAccepted: {
									if(root.currentPassword.length) {
										root.currentIndex = securityProfileConfirmationdDialog.pendingProfile
										root.accepted()
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

						onAccepted: {
							// TODO: actually set the password
						}
					}
				}
			}
		}
	}
}
