/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSwitch {
	MouseArea {
		anchors.fill: parent
		enabled: securityProfile.value === VenusOS.Security_Profile_Indeterminate
		onClicked: {
			//% "A Security Profile must configured before the network services can be enabled, see Settings - General"
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_security_warning_profile_configuration_order"), 10000)
		}
	}

	VeQuickItem {
		id: securityProfile
		uid: Global.systemSettings.serviceUid + "/Settings/System/SecurityProfile"
	}
}
