/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

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
		model: deviceIds.value ? deviceIds.value.split(',') : []
		delegate: ListNavigationItem {
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
