/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string startStopBindPrefix
	property string gensetService

	GradientListView {
		model: ObjectModel {
			ListSwitch {
				id: manualSwitch
				//% "Start generator"
				text: qsTrId("settings_page_relay_generator_start_generator")
				dataItem.uid: root.startStopBindPrefix + "/ManualStart"
				writeAccessLevel: VenusOS.User_AccessType_User
				enabled: !root.gensetService || remoteStartMode.value === 1
				onCheckedChanged: {
					if (root.isCurrentPage) {
						if (!checked) {
							//% "Stopping, generator will continue running if other conditions are reached"
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_stop_info"), 3000)
						}
						if (checked && stopTimer.value == 0) {
							//% "Starting, generator won't stop till user intervention"
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_start_info"), 5000)
						}
						if (checked && stopTimer.value > 0) {
							//: %1 = time until generator is stopped
							//% "Starting. The generator will stop in %1, unless other conditions keep it running"
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_start_timer").arg(Utils.secondsToString(stopTimer.value)), 5000)
						}
					}
				}

				VeQuickItem {
					id: remoteStartMode
					uid: root.gensetService ? gensetService + "/AutoStart" : ""
				}

				VeQuickItem {
					id: stopTimer
					uid: root.startStopBindPrefix + "/ManualStartTimer"
				}
			}

			ListTimeSelector {
				//% "Run for (hh:mm)"
				text: qsTrId("settings_page_relay_generator_run_for_hh_mm")
				enabled: !manualSwitch.checked && (remoteStartMode.isValid && remoteStartMode.value === 1)
				dataItem.uid: root.startStopBindPrefix + "/ManualStartTimer"
				writeAccessLevel: VenusOS.User_AccessType_User

				bottomContentChildren: [
					ListLabel {
						allowed: remoteStartMode.isValid && remoteStartMode.value !== 1
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						//% "The remote start functionality is disabled on the genset. The GX will not be able to start or stop the genset now. Enable it on the genset control panel."
						text: qsTrId("settings_page_relay_generator_remote_start_disabled")
					}
				]
			}
		}
	}
}
