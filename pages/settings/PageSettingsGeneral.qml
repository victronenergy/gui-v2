/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	readonly property bool pulledDown: settingsListView.contentY < -60

	onIsCurrentPageChanged: {
		if (isCurrentPage) {
			keyEvents.repeatCount = 0
			keyEvents.upCount = 0
			keyEvents.downCount = 0
		}
	}

	Connections {
		id: keyEvents

		property int repeatCount
		property int upCount
		property int downCount

		target: Global

		function onKeyPressed(event) {
			if (!root.isCurrentPage) {
				repeatCount = 0
				return
			}
			if (event.key === Qt.Key_Right) {
				// change to super user mode if the right button is pressed for a while
				if (Global.systemSettings.accessLevel.value !== VenusOS.User_AccessType_SuperUser && ++repeatCount > 60) {
					Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_SuperUser)
					repeatCount = 0
				}
			} else if (event.key === Qt.Key_Up) {
				if (upCount < 5) ++upCount
				if (downCount > 0) upCount = 0
				downCount = 0
			} else if (event.key === Qt.Key_Down) {
				if (downCount < 5) ++downCount;
				if (upCount === 5 && downCount === 5) {
					Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_Service)
					upCount = 0
				}
			}
		}
	}

	Timer {
		running: root.pulledDown
		interval: 5000
		onTriggered: {
			if (Global.systemSettings.accessLevel.value >= VenusOS.User_AccessType_Installer) {
				Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_SuperUser)
			}
		}
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListRadioButtonGroup {
				//% "Access level"
				text: qsTrId("settings_access_level")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/AccessLevel"
				writeAccessLevel: VenusOS.User_AccessType_User

				optionModel: [
					//% "User"
					{ display: qsTrId("settings_access_user"), value: VenusOS.User_AccessType_User, password: "ZZZ" },
					//% "User & Installer"
					{ display: qsTrId("settings_access_user_installer"), value: VenusOS.User_AccessType_Installer, password: "ZZZ" },
					//% "Superuser"
					{ display: qsTrId("settings_access_superuser"), value: VenusOS.User_AccessType_SuperUser, readOnly: true },
					//% "Service"
					{ display: qsTrId("settings_access_service"), value: VenusOS.User_AccessType_Service, readOnly: true },
				]
			}

			ListTextField {
				//% "Set root password"
				text: qsTrId("settings_set_root_password")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				placeholderText: "* * * * * *"

				onAccepted: {
					// TODO implement via platform helpers
					Global.showToastNotification(VenusOS.Notification_Info, "not yet implemented!")
				}
			}

			ListSwitch {
				id: sshOnLan

				//% "SSH on LAN"
				text: qsTrId("settings_ssh_on_lan")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/SSHLocal"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			ListSwitch {
				id: remoteSupportOnOff

				//% "Remote support"
				text: qsTrId("settings_remote_support")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupport"
			}

			ListTextItem {
				//% "Remote support tunnel"
				text: qsTrId("settings_remote_support_tunnel")
				secondaryText: remotePort.secondaryText.length > 0 ? CommonWords.online : CommonWords.offline
				visible: defaultVisible && remoteSupportOnOff.checked
			}

			ListTextItem {
				id: remotePort

				//% "Remote support IP and port"
				text: qsTrId("settings_remote_ip_and_support")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupportIpAndPort"
				visible: defaultVisible && remoteSupportOnOff.checked
			}

			ListButton {
				text: CommonWords.reboot
				//% "Reboot now"
				button.text: qsTrId("settings_reboot_now")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: Global.venusPlatform.reboot()
			}

			ListSwitch {
				//% "Audible alarm"
				text: qsTrId("settings_audible_alarm")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/Audible"
				visible: defaultVisible && buzzerStateDataItem.isValid

				VeQuickItem {
					id: buzzerStateDataItem
					uid: Global.system.serviceUid + "/Buzzer/State"
				}
			}
			ListRadioButtonGroup {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
				height: implicitHeight + demoModeCaption.height
				primaryLabel.anchors.verticalCenterOffset: -(demoModeCaption.height / 2)
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/DemoMode"
				popDestination: undefined // don't pop page automatically.
				updateOnClick: false // handle option clicked manually.
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					//% "ESS demo"
					{ display: qsTrId("page_settings_demo_ess"), value: 1 },
					//% "Boat/Motorhome demo 1"
					{ display: qsTrId("page_settings_demo_1"), value: 2 },
					//% "Boat/Motorhome demo 2"
					{ display: qsTrId("page_settings_demo_2"), value: 3 },
				]
				ListLabel {
					id: demoModeCaption

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry_listItem_content_verticalMargin
					}
					//% "Starting demo mode will change some settings and the user interface will be unresponsive for a moment."
					text: qsTrId("settings_demo_mode_caption")
				}
				onOptionClicked: function(index) {
					Qt.callLater(Global.main.rebuildUi)
					dataItem.setValue(index)
				}
			}
		}
	}
}
