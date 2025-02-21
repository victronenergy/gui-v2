/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
	id: root

	readonly property string activeBatteryName: availableBatteryServices.mapObject[activeBatteryService.value] ?? ""
	property string customServiceDescription

	function _summaryText(deviceName, deviceInstance) {
		return deviceName ? `${deviceName} [${deviceInstance}]` : ""
	}

	//% "Center details"
	text: qsTrId("settings_briefview_center_details")
	secondaryText: centerService.value ? customServiceDescription : activeBatteryName

	onClicked: {
		const deviceModel = Global.environmentInputs.model
		let selectedIndex = centerService.value ? -1 : 0
		//% "Active battery monitor"
		let deviceOptionModel = [{ display: activeBatteryName, value: "", section: qsTrId("settings_briefview_center_active_battery_monitor") }]
		for (let i = 0; i < deviceModel.count; ++i) {
			const device = deviceModel.deviceAt(i)
			deviceOptionModel.push({
				display: root._summaryText(device.name, device.deviceInstance),
				value: device.serviceUid,
				//% "Temperature services"
				section: qsTrId("settings_briefview_center_temperature_services")
			})
			if (selectedIndex < 0 && device.serviceUid === centerService.value) {
				selectedIndex = i
			}
		}
		Global.pageManager.pushPage(deviceOptionsComponent, {
			title: text,
			optionModel: deviceOptionModel,
			currentIndex: selectedIndex,
		})
	}

	VeQuickItem {
		id: centerService
		uid: Global.systemSettings.serviceUid + "/Settings/Gui2/BriefView/CenterService"
		onValueChanged: {
			const serviceUid = value
			const serviceType = BackendConnection.serviceTypeFromUid(serviceUid)
			if (serviceType === "temperature") {
				const deviceModel = Global.environmentInputs.model
				const device = deviceModel.deviceAt(deviceModel.indexOf(serviceUid))
				root.customServiceDescription = root._summaryText(device?.name, device?.deviceInstance)
			} else {
				root.customServiceDescription = ""
			}
		}
	}

	VeQuickItem {
		id: activeBatteryService
		uid: Global.system.serviceUid + "/ActiveBatteryService"
	}

	VeQuickItem {
		id: availableBatteryServices

		property var mapObject: ({})

		uid: Global.system.serviceUid + "/AvailableBatteryServices"
		onValueChanged: {
			try {
				mapObject = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse JSON:", value, "exception:", e)
			}
		}
	}

	Component {
		id: deviceOptionsComponent

		RadioButtonListPage {
			optionView.section.property: "section"
			optionView.section.delegate: SettingsListHeader {
				required property string section

				bottomPadding: Theme.geometry_gradientList_spacing
				text: section
			}

			onOptionClicked: (index, serviceUid) => {
				centerService.setValue(serviceUid)
			}
		}
	}
}
