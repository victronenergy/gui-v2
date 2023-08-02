/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		// Allow AccessLevelRadioButtonGroup to get key events
		focus: true

		model: ObjectModel {
			AccessLevelRadioButtonGroup {}

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
				dataSource: "com.victronenergy.settings/Settings/System/SSHLocal"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			ListSwitch {
				id: remoteSupportOnOff

				//% "Remote support"
				text: qsTrId("settings_remote_support")
				dataSource: "com.victronenergy.settings/Settings/System/RemoteSupport"
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
				dataSource: "com.victronenergy.settings/Settings/System/RemoteSupportIpAndPort"
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
				dataSource: "com.victronenergy.settings/Settings/Alarm/Audible"
				visible: defaultVisible && buzzerStateDataPoint.valid

				DataPoint {
					id: buzzerStateDataPoint
					source: "com.victronenergy.system/Buzzer/State"
				}
			}
			ListRadioButtonGroup {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
				height: implicitHeight + demoModeCaption.height
				primaryLabel.anchors.verticalCenterOffset: -(demoModeCaption.height / 2)
				dataSource: "com.victronenergy.settings/Settings/Gui/DemoMode"
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
						bottomMargin: Theme.geometry.listItem.content.verticalMargin
					}
					//% "Starting demo mode will change some settings and the user interface will be unresponsive for a moment."
					text: qsTrId("settings_demo_mode_caption")
				}
				onOptionClicked: function(index) {
					Qt.callLater(Global.main.rebuildUi)
					setDataValue(index)
				}
			}
		}
	}
}
