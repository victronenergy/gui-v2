/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: enableItem
		uid: Global.systemSettings.serviceUid + "/Settings/LEDs/Enable"
	}

	GradientListView {
		id: settingsListView

		model: DelegateComponentModel {
			DelegateComponent {
				id: buzzerStateDataItemDC
				dataItem: VeQuickItem { uid: Global.system.serviceUid + "/Buzzer/State" }
				preferredVisible: buzzerStateDataItemDC.dataItem.valid
				ListSwitch {
					//% "Audible alarm"
					text: qsTrId("settings_audible_alarm")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/Audible"

					VeQuickItem {
						id: buzzerStateDataItem
						uid: Global.system.serviceUid + "/Buzzer/State"
					}
				}
			}

			DelegateComponent {
				preferredVisible: enableItem.valid
				ListSwitch {
					//% "Enable status LEDs"
					text: qsTrId("settings_enable_status_leds")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/LEDs/Enable"
				}
			}
		}
	}
}
