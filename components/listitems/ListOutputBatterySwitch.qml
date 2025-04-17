/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSwitch {
	property string bindPrefix

	//% "Output on auxiliary battery"
	text: qsTrId("output_aux_battery")
	dataItem.uid: bindPrefix + "/Settings/OutputBattery"
	preferredVisible: dataItem.valid
	onToggled: {
		const msg = checked
				  //% "%1 changed to DC-DC service"
				? qsTrId("output_aux_battery_service_changed_dcdc").arg(device.name)
				  //% "%1 changed to alternator service"
				: qsTrId("output_aux_battery_service_changed_alternator").arg(device.name)
		Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
	}

	Device {
		id: device
		serviceUid: root.bindPrefix
	}
}
