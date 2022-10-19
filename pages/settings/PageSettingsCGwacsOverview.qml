/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	function getDescription(customName, productName) {
		if (customName !== undefined && customName.length > 0) {
			return customName
		}
		if (productName !== undefined && productName.length > 0) {
			return productName
		}
		return '--'
	}

	function getModeName(serviceType) {
		switch (serviceType)
		{
		case "grid":
			//% "Grid meter"
			return qsTrId("settings_grid_meter")
		case "pvinverter":
			//% "PV inverter"
			return qsTrId("settings_pv_inverter")
		case "genset":
			//% "Generator"
			return qsTrId("settings_generator")
		case "acload":
			//% "AC load"
			return qsTrId("settings_ac_load")
		default:
			return '--'
		}
	}

	function getMenuName(serviceType, l2ServiceType)
	{
		var result = getModeName(serviceType)
		if (l2ServiceType !== undefined && l2ServiceType.length > 0) {
			result += " + " + getModeName(l2ServiceType)
		}
		return result
	}

	DataPoint {
		id: deviceIds
		source: "com.victronenergy.settings/Settings/CGwacs/DeviceIds"
	}

	SettingsListView {
		model: Utils.stringToArray(deviceIds.value)
		delegate: SettingsListNavigationItem {

			readonly property string devicePath: "com.victronenergy.settings/Settings/Devices/cgwacs_" + modelData

			text: getDescription(customNameItem.value, modelData)
			secondaryText: getMenuName(serviceType.value, l2ServiceType.value)
			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsCGwacs.qml", { title: text, devicePath: devicePath })

			DataPoint {
				id: customNameItem
				source: (devicePath + "/CustomName")
			}

			DataPoint {
				id: serviceType
				source: (devicePath + "/ServiceType")
			}

			DataPoint {
				id: l2ServiceType
				source: (devicePath + "/L2/ServiceType")
			}
		}
	}
}
