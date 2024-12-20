/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListSwitch {
				//% "Audible alarm"
				text: qsTrId("settings_audible_alarm")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/Audible"
				allowed: defaultAllowed && buzzerStateDataItem.isValid

				VeQuickItem {
					id: buzzerStateDataItem
					uid: Global.system.serviceUid + "/Buzzer/State"
				}
			}

			ListSwitch {
				//% "Enable status LEDs"
				text: qsTrId("settings_enable_status_leds")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/LEDs/Enable"
				allowed: defaultAllowed && dataItem.isValid
			}
		}
	}
}
