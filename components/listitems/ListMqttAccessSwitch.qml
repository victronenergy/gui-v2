/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	id: root

	//% "MQTT Access"
	text: qsTrId("settings_services_mqtt_access")
	dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/MqttLocal"

	optionModel: [
		{ display: CommonWords.off, value: 0 },
		//% "Paired devices only"
		{ display: qsTrId("settings_services_mqtt_access_paired_devices_only"), value: 2, readOnly: !tokenUsers.valid || tokenUsers.value === "[]"},
		{ display: CommonWords.on, value: 1 },
	]

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive
			onClicked: {
				if (securityProfile.value === VenusOS.Security_Profile_Indeterminate) {
					//% "A Security Profile must be configured before the network services can be enabled, see Settings - General"
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_security_warning_profile_configuration_order"), 10000)
					return
				}
				root.click()
			}
		}
	}

	onOptionClicked: function (index) {
		if (index == 0 && tokenUsers.valid && tokenUsers.value !== "[]") {
			//% "Turning MQTT Access off also disables paired MQTT devices until access is enabled again."
			Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("settings_services_mqtt_access_warning_paired_devices"), 10000)
		}
	}

	VeQuickItem {
		id: securityProfile
		uid: Global.systemSettings.serviceUid + "/Settings/System/SecurityProfile"
	}

	VeQuickItem {
		id: tokenUsers
		uid: Global.venusPlatform.serviceUid + "/Tokens/Users"
	}
}
