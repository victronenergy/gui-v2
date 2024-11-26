/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function getDescription(customName, productName) {
		return customName || productName || "--"
	}

	function getMenuName(serviceType, l2ServiceType) {
		let result = Global.acInputs.roleName(serviceType)
		if (l2ServiceType !== undefined && l2ServiceType.length > 0) {
			result += " + " + Global.acInputs.roleName(l2ServiceType)
		}
		return result
	}

	VeQuickItem {
		id: deviceIds
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/DeviceIds"
	}

	GradientListView {
		id: energyMeterList
		model: deviceIds.value ? deviceIds.value.split(',') : []

		header: PrimaryListLabel {
			allowed: energyMeterList.count === 0
			//% "No energy meters found\n\n"
			//% "Note that this menu only shows Carlo Gavazzi meters connected over RS485. "
			//% "For any other meter, including Carlo Gavazzi meters connected over ethernet, "
			//% "see the Modbus TCP/UDP devices menu instead."
			text: qsTrId("settings_cgwacs_no_energy_meters")
		}

		delegate: ListNavigation {
			readonly property string devicePath: Global.systemSettings.serviceUid + "/Settings/Devices/cgwacs_" + modelData

			text: getDescription(customNameItem.value, modelData)
			secondaryText: getMenuName(serviceType.value, l2ServiceType.value)
			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsCGwacs.qml", { title: text, devicePath: devicePath })

			VeQuickItem {
				id: customNameItem
				uid: devicePath + "/CustomName"
			}

			VeQuickItem {
				id: serviceType
				uid: devicePath + "/ServiceType"
			}

			VeQuickItem {
				id: l2ServiceType
				uid: devicePath + "/L2/ServiceType"
			}
		}
	}
}
