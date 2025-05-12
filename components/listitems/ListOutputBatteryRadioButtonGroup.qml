/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	property string bindPrefix
	property Item settingsPage

	//% "Output battery"
	text: qsTrId("output_battery")
	dataItem.uid: bindPrefix + "/Settings/OutputBattery"
	preferredVisible: dataItem.valid
	optionModel: [
		//% "Alternator charging the main battery"
		{ display: qsTrId("alternator_charge_battery"), value: 0 },
		//% "Charging another battery from the main battery"
		{ display: qsTrId("charge_another_battery"), value: 1 }
	]

	onOptionClicked: (index) => {
		const msg = optionModel[index].value === 1
			  //% "%1 changed to DC-DC service"
			? qsTrId("output_aux_battery_service_changed_dcdc").arg(device.name)
			  //% "%1 changed to alternator service"
			: qsTrId("output_aux_battery_service_changed_alternator").arg(device.name)
		Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)

		// Changing this setting will change the service type from .dcdc to .alternator, or vice
		// versa, so return to the page prior to the settings page for the service.
		Global.pageManager.popToAbovePage(settingsPage)
	}

	Device {
		id: device
		serviceUid: root.bindPrefix
	}
}
