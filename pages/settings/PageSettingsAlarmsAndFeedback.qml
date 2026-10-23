/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				//% "Audible alarm"
				text: qsTrId("settings_audible_alarm")
				dataItem.uid: Services.settings.serviceUid + "/Settings/Alarm/Audible"
				preferredVisible: buzzerStateDataItem.valid

				VeQuickItem {
					id: buzzerStateDataItem
					uid: Services.system.serviceUid + "/Buzzer/State"
				}
			}

			ListSwitch {
				//% "Enable status LEDs"
				text: qsTrId("settings_enable_status_leds")
				dataItem.uid: Services.settings.serviceUid + "/Settings/LEDs/Enable"
				preferredVisible: dataItem.valid
			}
		}
	}
}
