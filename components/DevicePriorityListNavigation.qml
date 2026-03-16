/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
	id: root

	property string serviceType
	property int deviceInstance: -1
	property string uniqueIdentifier
	readonly property Device _device: devices && deviceInstance >= 0 ? devices.deviceForDeviceInstance(deviceInstance) : null
	readonly property string pageSource: pageData.item?.pageSource || ""
	property alias text: primary.text
	readonly property ListModel _model: ListView.view.model

	component Arrow: Button {
		radius: Theme.geometry_opportunityLoad_button_radius
		flat: false
		icon.source: "qrc:/images/icon_arrow.svg"
		width: Theme.geometry_opportunityLoad_button_height
		height: Theme.geometry_opportunityLoad_button_height
	}

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

	anchors {
		left: parent.left
		leftMargin: Theme.geometry_priorityLabel_width
		right: parent.right
	}

	onClicked: Global.pageManager.pushPage(root.pageSource,
										   ({
												"title": root.text,
												"device": root._device
											})
										   )
	interactive: pageData.item?.interactive
	secondaryText: deviceActive.value === 0 ? CommonWords.disabled : ""

	Loader {
		id: pageData
		sourceComponent: {
			switch (root.serviceType) {
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
		}
		onLoaded: item.device = Qt.binding(function() { return root._device })
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
			root._model.move(index, index - 1, 1)
			root._model.writeToBackEnd()
		}
	}

	Arrow {
		id: downArrow

		anchors {
			left: upArrow.right
			leftMargin: Theme.geometry_opportunityLoad_margin
			verticalCenter: parent.verticalCenter
		}
		enabled: index !== (root._model.count - 1)
		rotation: 180
		onClicked: {
			root._model.move(index + 1, index, 1)
			root._model.writeToBackEnd()
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
		text: root.serviceType === "battery" ? CommonWords.battery
											 : root._device?.name || root.uniqueIdentifier || ""
	}

	VeQuickItem {
		id: deviceActive

		uid: root._device ? root._device.serviceUid + "/S2/0/Active" : ""
	}

	FilteredDeviceModel {
		id: devices

		serviceTypes: [root.serviceType]
	}
}
