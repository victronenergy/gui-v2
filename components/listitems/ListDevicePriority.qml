/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	required property int index
	required property string serviceType
	required property int deviceInstance
	required property string uniqueIdentifier

	readonly property string pageSource: pageData.item?.pageSource || ""
	readonly property ListModel _model: ListView.view.model
	property Device _device: AllDevicesModel.findDeviceWithTypeAndInstance(serviceType, deviceInstance)

	function click() {
		if (interactive) {
			Global.pageManager.pushPage(root.pageSource, { "title": root.text, "device": root._device })
		}
	}

	component Arrow: Button {
		radius: Theme.geometry_opportunityLoad_button_radius
		flat: false
		icon.source: "qrc:/images/icon_arrow.svg"
		defaultBackgroundWidth: Theme.geometry_listItem_height - 2*Theme.geometry_opportunityLoad_margin
		defaultBackgroundHeight: Theme.geometry_listItem_height - 2*Theme.geometry_opportunityLoad_margin
	}

	component PageData : QtObject {
		required property bool interactive
		required property string pageSource
	}

	Component {
		id: batteryData

		PageData {
			interactive: true
			pageSource: "/pages/settings/PageControllableLoadsBattery.qml"
		}
	}

	Component {
		id: s2ResourceManagedData

		// 'S2' is a communication standard for energy flexibility in homes and buildings, see
		// https://s2standard.org. The /S2/... interface basically makes the service controllable as
		// a flexible load through an energy management system.
		// According to that standard, the service thereby exposes a "Resource Manager", short "RM",
		// which is an abstract, high-level description and controller for that service. The
		// "RMSettings" are custom settings the resource manager needs to understand how to control
		// that service/device/resource.

		PageData {
			property VeQuickItem powerSetting: VeQuickItem {
				uid: root._device ? root._device.serviceUid + "/S2/0/RmSettings/PowerSetting" : ""
			}

			property VeQuickItem offHysteresis: VeQuickItem {
				uid: root._device ? root._device.serviceUid + "/S2/0/RmSettings/OffHysteresis" : ""
			}

			property VeQuickItem onHysteresis: VeQuickItem {
				uid: root._device ? root._device.serviceUid + "/S2/0/RmSettings/OnHysteresis" : ""
			}

			interactive: powerSetting.valid || offHysteresis.valid || onHysteresis.valid
			pageSource: "/pages/settings/PageControllableLoadsS2Rm.qml"
		}
	}

	Component {
		id: evcsData

		PageData {
			property VeQuickItem maxChargePower: VeQuickItem {
				uid: root._device? root._device.serviceUid + "/S2/0/RmSettings/MaxChargePower" : ""
			}

			property VeQuickItem rememberEvPhases: VeQuickItem {
				uid: root._device? root._device.serviceUid + "/S2/0/RmSettings/RememberEvPhases" : ""
			}

			interactive: maxChargePower.valid || rememberEvPhases.valid
			pageSource: "/pages/settings/PageControllableLoadsEVCS.qml"
		}
	}

	text: root.serviceType === "battery" ? CommonWords.battery
			: root._device?.name || root.uniqueIdentifier || ""
	interactive: pageData.item?.interactive ?? false

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width

		RowLayout {
			anchors {
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			spacing: 0

			Arrow {
				id: upArrow
				enabled: root.index !== 0
				onClicked: {
					root._model.move(index, index - 1, 1)
					root._model.writeToBackEnd()
				}
				Layout.rightMargin: Theme.geometry_opportunityLoad_margin
			}

			Arrow {
				enabled: index !== (root._model.count - 1)
				rotation: 180
				onClicked: {
					root._model.move(index + 1, index, 1)
					root._model.writeToBackEnd()
				}
				Layout.rightMargin: Theme.geometry_listItem_flat_content_horizontalMargin
			}

			ThreeLabelLayout {
				primaryText: root.text
				primaryLabel.font: root.font
				primaryLabel.elide: Text.ElideRight
				primaryLabel.maximumLineCount: 1
				//% "No control"
				secondaryText: deviceActive.value === 0 ? qsTrId("list_device_priority_no_control") : ""
				secondaryLabel.elide: Text.ElideRight
				secondaryLabel.maximumLineCount: 1
				stretchSecondaryText: true
			}

			ForwardIcon {
				visible: root.interactive
				Layout.leftMargin: root.spacing
			}
		}
	}

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive
			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: click()
	Keys.onRightPressed: click()

	Connections {
		enabled: !root._device && root.deviceInstance >= 0
		target: AllDevicesModel

		function onDeviceAdded(device) {
			if (device.serviceType === root.serviceType && device.deviceInstance === root.deviceInstance) {
				root._device = device
			}
		}
	}

	Loader {
		id: pageData
		sourceComponent: {
			switch (root.serviceType) {
			case "battery":
				return batteryData
			case "evcharger":
				return evcsData
			default:
				return s2ResourceManagedData
			}
		}
	}

	VeQuickItem {
		id: deviceActive

		uid: root._device ? root._device.serviceUid + "/S2/0/Active" : ""
	}
}
