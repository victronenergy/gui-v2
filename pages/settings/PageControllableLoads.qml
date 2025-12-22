/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	component Arrow: Button {
		flat: false
		icon.source: "qrc:/images/icon_arrow.svg"
		width: Theme.geometry_button_height
		height: Theme.geometry_button_height
	}

	component DevicePriorityListNavigation: ListNavigation {
		id: devicePriorityDelegate

		property string serviceType
		property int deviceInstance: -1
		property string uniqueIdentifier
		readonly property FilteredDeviceModel devices: serviceType === "acload" ? acLoadDevices
				: serviceType === "evcharger" ? evcsDevices
				: null
		readonly property Device device: devices && deviceInstance >= 0 ? devices.deviceForDeviceInstance(deviceInstance) : null
		readonly property string pageSource: {
			switch (serviceType) {
			case "battery":
				return "/pages/settings/PageControllableLoadsBattery.qml"
			case "acload":
				return "/pages/settings/PageControllableLoadsAcLoad.qml"
			case "evcharger":
				return "/pages/settings/PageControllableLoadsEVCS.qml"
			default:
				console.warn("Controllable Loads: Invalid service type.")
				return ""
			}
		}

		property alias text: primary.text

		Label {
			id: priorityLabel

			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.left
				rightMargin: 2
			}

			horizontalAlignment: Text.AlignHCenter
			width: Theme.geometry_priorityLabel_width
			color: Theme.color_font_disabled
			font.pixelSize: Theme.font_size_body1
			text: index + 1
		}

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_priorityLabel_width
			right: parent.right
		}

		onClicked: Global.pageManager.pushPage(devicePriorityDelegate.pageSource,
											   ({
													"title": devicePriorityDelegate.text,
													"device": devicePriorityDelegate.device
												})
											   )
		interactive: serviceType !== "evcharger" // TODO: remove this once backend supports "evcs maximum charging power limit".

		Arrow {
			id: upArrow

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_opportunityLoad_margin
				verticalCenter: parent.verticalCenter
			}
			enabled: index !== 0
			onClicked: {
				opportunityLoadsModel.move(index, index - 1, 1)
				opportunityLoadsModel.writeToBackEnd()
			}
		}

		Arrow {
			id: downArrow

			anchors {
				left: upArrow.right
				leftMargin: Theme.geometry_opportunityLoad_margin
				verticalCenter: parent.verticalCenter
			}
			enabled: index !== (opportunityLoadsModel.count - 1)
			rotation: 180
			onClicked: {
				opportunityLoadsModel.move(index + 1, index, 1)
				opportunityLoadsModel.writeToBackEnd()
			}
		}

		Label {
			id: primary

			anchors {
				left: downArrow.right
				leftMargin: Theme.geometry_listItem_content_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			font.pixelSize: Theme.font_size_body2
			wrapMode: Text.Wrap
			text: devicePriorityDelegate?.serviceType === "battery" ? CommonWords.battery
				: devicePriorityDelegate?.device?.name || devicePriorityDelegate?.uniqueIdentifier || ""
		}
	}

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0
			bottomPadding: spacing

			ListSwitch {
				dataItem.uid: BackendConnection.serviceUidForType("platform") + "/OpportunityLoads/Mode"
				text: CommonWords.enabled
			}

			SettingsListHeader {
				//% "Devices and Priorities"
				text: qsTrId("pagecontrollableloads_devices_and_priorities")
			}
		}

		model: opportunityLoadsModel
		delegate: DevicePriorityListNavigation {
			serviceType: model.serviceType
			deviceInstance: model.deviceInstance
			uniqueIdentifier: model.uniqueIdentifier
		}
		move: Transition {
			enabled: Global.animationEnabled
			NumberAnimation {
				duration: Theme.animation_devicePriorityDelegateMove_duration
				properties: "x,y"
				easing.type: Easing.InOutQuad
			}
		}
		displaced: Transition {
			enabled: Global.animationEnabled
			NumberAnimation {
				duration: Theme.animation_devicePriorityDelegateMove_duration
				properties: "x,y"
				easing.type: Easing.InOutQuad
			}
		}

		footer: SettingsListHeader {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_priorityLabel_width
				right: parent.right
				rightMargin: Theme.geometry_priorityLabel_width
			}

			//% "Arrange the controllable devices according to their priority; the control algorithm will control them based on the currently available PV excess."
			text: qsTrId("pagecontrollableloads_arrange")
			font.pixelSize: Theme.font_size_caption
			width: parent?.width ?? 0
			wrapMode: Text.Wrap
		}
	}

	ListModel {
		id: opportunityLoadsModel

		function writeToBackEnd() {
			let newValue = []

			for (let i = 0; i < opportunityLoadsModel.count; ++i) {
				newValue.push(opportunityLoadsModel.get(i))
			}
			loads.setValue(JSON.stringify(newValue))
		}
	}

	VeQuickItem {
		id: loads

		uid: BackendConnection.serviceUidForType("opportunityloads") + "/AvailableServices"
		invalidate: true
		onValueChanged: {
			if (value === undefined || value === null || value === "") {
				return
			}

			let jsv
			try {
				jsv = (typeof value === "string") ? JSON.parse(value) : value
			} catch (e) {
				console.warn("AvailableServices JSON parse failed:", e, "value:", value)
				return
			}

			if (!Array.isArray(jsv)) {
				console.warn("AvailableServices is not an array:", jsv)
				return
			}

			for (let i = 0; i < jsv.length; ++i) {
				const newValue = jsv[i]
				const oldValue = (i < opportunityLoadsModel.count) ? opportunityLoadsModel.get(i) : null

				const changed =  !oldValue
							  || oldValue.uniqueIdentifier !== newValue.uniqueIdentifier
							  || oldValue.deviceInstance !== newValue.deviceInstance
							  || oldValue.serviceType !== newValue.serviceType
							  || oldValue.controllable !== newValue.controllable

				if (changed) {
					opportunityLoadsModel.set(i, newValue)
				}
			}

			if (opportunityLoadsModel.count > jsv.length) {
				opportunityLoadsModel.remove(jsv.length, opportunityLoadsModel.count - jsv.length)
			}
		}
	}

	FilteredDeviceModel {
		id: acLoadDevices
		serviceTypes: ["acload"]
	}

	FilteredDeviceModel {
		id: evcsDevices
		serviceTypes: ["evcharger"]
	}
}
