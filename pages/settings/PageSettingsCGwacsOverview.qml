/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
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

	DataPoint {
		id: deviceIds
		source: "com.victronenergy.settings/Settings/CGwacs/DeviceIds"
	}

	GradientListView {
		model: deviceIds.value ? deviceIds.value.split(',') : []
		delegate: ListNavigationItem {
			readonly property string devicePath: "com.victronenergy.settings/Settings/Devices/cgwacs_" + modelData

			text: getDescription(customNameItem.value, modelData)
			secondaryText: getMenuName(serviceType.value, l2ServiceType.value)
			onClicked: Global.pageManager.pushPage("qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsCGwacs.qml", { title: text, devicePath: devicePath })

			DataPoint {
				id: customNameItem
				source: devicePath + "/CustomName"
			}

			DataPoint {
				id: serviceType
				source: devicePath + "/ServiceType"
			}

			DataPoint {
				id: l2ServiceType
				source: devicePath + "/L2/ServiceType"
			}
		}
	}
}
