/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root
	required property CanbusProfile canbusProfile

	VeQuickItem {
		id: _N2kGatewayEnabled
		uid: Global.systemSettings.serviceUid + "/Settings/Vecan/" + canbusProfile.gateway + "/N2kGatewayEnabled"
	}
	
	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				id: n2kGateway
				//% "NMEA2000-out"
                                text: qsTrId("settings_canbus_nmea2000out")
				checked: (_N2kGatewayEnabled.value & 1)
				onClicked: {
					if (checked) {
						_N2kGatewayEnabled.setValue(1)
					} else {
						_N2kGatewayEnabled.setValue(0)
					}
				}
			}


			ListSwitch {
				id: alarmEnable
				//% "NMEA2000-out-Alarm"
                                text: qsTrId("settings_canbus_nmea2000out_alarm")
				preferredVisible: n2kGateway.checked
				checked: (_N2kGatewayEnabled.value & (1<<1))
             		   	onClicked: {           
					if (checked) {                 
						_N2kGatewayEnabled.setValue(_N2kGatewayEnabled.value | (1<<1))
					} else {
						_N2kGatewayEnabled.setValue(_N2kGatewayEnabled.value & ~(1<<1))
					}
				}
			}
		}
	}
}
