/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
	id: root

	required property string activeBatteryName
	property string customServiceDescription

	function _summaryText(deviceName, deviceInstance) {
		return deviceName ? `${deviceName} [${deviceInstance}]` : ""
	}

	//% "Center details"
	text: qsTrId("settings_briefview_center_details")
	secondaryText: centerService.value === "none" ? CommonWords.none_option
			: centerService.value ? customServiceDescription
			: activeBatteryName

	onClicked: {
		const deviceModel = Global.environmentInputs.model
		let selectedIndex = centerService.value === "none" ? 0
				: centerService.value === "" ? 1
				: -1
		let deviceOptionModel = [
				{ display: CommonWords.none_option, value: "none", section: "" },
				//% "Active battery monitor"
				{ display: activeBatteryName, value: "", section: qsTrId("settings_briefview_center_active_battery_monitor") }]
		for (let i = 0; i < deviceModel.count; ++i) {
			const device = deviceModel.deviceAt(i)
			const portableServiceId = BackendConnection.serviceUidToPortableId(device.serviceUid, device.deviceInstance)
			deviceOptionModel.push({
				display: root._summaryText(device.name, device.deviceInstance),
				value: portableServiceId,
				//% "Temperature services"
				section: qsTrId("settings_briefview_center_temperature_services")
			})
			if (selectedIndex < 0 && portableServiceId === centerService.value) {
				selectedIndex = i+2 // allow for the none and prepended active battery options
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
			const idInfo = BackendConnection.portableIdInfo(value)
			if (idInfo.type === "temperature") {
				const device = Global.environmentInputs.model.deviceForDeviceInstance(idInfo.instance)
				if (device) {
					root.customServiceDescription = root._summaryText(device?.name, device?.deviceInstance)
				}
			} else {
				root.customServiceDescription = ""
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

			showAccessLevel: root.showAccessLevel
			writeAccessLevel: root.writeAccessLevel

			onOptionClicked: (index, serviceId) => {
				centerService.setValue(serviceId)
			}
		}
	}
}
