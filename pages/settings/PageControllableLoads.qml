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
		radius: Theme.geometry_opportunityLoad_button_radius
		flat: false
		icon.source: "qrc:/images/icon_arrow.svg"
		width: Theme.geometry_opportunityLoad_button_height
		height: Theme.geometry_opportunityLoad_button_height
	}

	component DevicePriorityListNavigation: ListNavigation {
		id: devicePriorityDelegate

		property string serviceType
		property int deviceInstance: -1
		property string uniqueIdentifier
		readonly property FilteredDeviceModel devices: serviceType === "acload" ? acLoadDevices
				: serviceType === "evcharger" ? evcsDevices
				: null
		readonly property Device _device: devices && deviceInstance >= 0 ? devices.deviceForDeviceInstance(deviceInstance) : null
		readonly property string pageSource: pageData.item?.pageSource || ""
		property alias text: primary.text

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_priorityLabel_width
			right: parent.right
		}

		onClicked: Global.pageManager.pushPage(devicePriorityDelegate.pageSource,
											   ({
													"title": devicePriorityDelegate.text,
													"device": devicePriorityDelegate._device
												})
											   )
		interactive: pageData.item?.interactive
		secondaryText: disabled.value === 0 ? CommonWords.disabled : ""

		Loader {
			id: pageData
			sourceComponent: {
				{
					switch (devicePriorityDelegate.serviceType) {
					case "battery":
						return batteryData
					case "acload":
						return acLoadData
					case "evcharger":
						return evcsData
					default:
						console.warn("Controllable Loads: Invalid service type.")
						return undefined
					}
				};
				device: _device
			}
		}

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
			text: devicePriorityDelegate.serviceType === "battery" ? CommonWords.battery
				: devicePriorityDelegate.device?.name ||devicePriorityDelegate.device?.productName || devicePriorityDelegate.uniqueIdentifier || ""
		}

		VeQuickItem {
			id: disabled

			uid: _device ? _device.serviceUid + "/S2/0/RmSettings/PowerSetting" : ""
		}
	} // component DevicePriorityListNavigation

	component PageData : QtObject {
		required property bool interactive
		required property string pageSource
		property Device device
	}

	Component {
		id: batteryData

		PageData {
			interactive: true
			pageSource: "/pages/settings/PageControllableLoadsBattery.qml"
		}
	}

	Component {
		id: acLoadData

		PageData {
			id: acLoadData

			property VeQuickItem powerSetting: VeQuickItem {
				uid: acLoadData.device ? acLoadData.device.serviceUid + "/S2/0/RmSettings/PowerSetting" : ""
			}

			property VeQuickItem offHysteresis: VeQuickItem {
				uid: acLoadData.device? acLoadData.device.serviceUid + "/S2/0/RmSettings/OffHysteresis" : ""
			}

			property VeQuickItem onHysteresis: VeQuickItem {
				uid: acLoadData.device? acLoadData.device.serviceUid + "/S2/0/RmSettings/OnHysteresis" : ""
			}

			interactive: powerSetting.valid || offHysteresis.valid || onHysteresis.valid
			pageSource: "/pages/settings/PageControllableLoadsAcLoad.qml"
		}
	}

	Component {
		id: evcsData

		PageData {
			id: evcsData

			property VeQuickItem maxChargePower: VeQuickItem {
				uid: evcsData.device? evcsData.device.serviceUid + "/S2/0/RmSettings/MaxChargePower" : ""
			}

			interactive: maxChargePower.valid
			pageSource: "/pages/settings/PageControllableLoadsEVCS.qml"
		}
	}

	VeQuickItem {
		id: mode

		uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
	}

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0
			bottomPadding: spacing

			ListSwitch {
				dataItem.uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
				text: CommonWords.enabled
			}

			SettingsListHeader {
				text: mode.value && loads.valid ?
						  //% "Devices and Priorities"
						  qsTrId("pagecontrollableloads_devices_and_priorities") :
						  //% "Starting, this may take a few seconds..."
						  qsTrId("pagecontrollableloads_starting")
				visible: mode.value
			}
		}

		model: mode.value && loads.valid ? opportunityLoadsModel : []
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

		footer: SettingsColumn {
			width: parent?.width ?? 0

			SettingsListHeader {
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
				visible: mode.value
			}

			ListItem {
				id: documentation

				//% "Documentation"
				text: qsTrId("pagecontrollableloads_documentation")
				//% "Access the documentation by scanning the QR code with your portable device.\nOr insert the link: http://ve4.nl/ol"
				captionLabel.text: qsTrId("pagecontrollableloads_access_the_documentation")
				content.children: [
					Image {
						readonly property int qrCodeHeight: documentation.height - 2*Theme.geometry_listItem_content_verticalMargin

						source: "image://QZXing/encode/" + "http://ve4.nl/ol" +
								"?correctionLevel=M" +
								"&format=qrcode"
						sourceSize: Qt.size(qrCodeHeight, qrCodeHeight)
					}
				]
			}
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
