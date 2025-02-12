/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

OverviewWidget {
	id: root

	function _showSettingsPage(device) {
		if (BackendConnection.serviceTypeFromUid(device.serviceUid) === "dcdc") {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcDcConverter.qml",
					{ "bindPrefix": device.serviceUid })
		} else {
			  Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
					{ "bindPrefix": device.serviceUid })
		}
	}

	//% "DC Loads"
	title: qsTrId("overview_widget_dcloads_title")
	icon.source: "qrc:/images/dcloads.svg"
	type: VenusOS.OverviewWidget_Type_DcLoads
	enabled: Global.allDevicesModel.combinedDcLoadDevices.count > 0

	quantityLabel.dataObject: Global.system.dc

	onClicked: {
		if (Global.allDevicesModel.combinedDcLoadDevices.count > 1) {
			Global.pageManager.pushPage(deviceListPageComponent, { "title": root.title })
		} else {
			root._showSettingsPage(Global.allDevicesModel.combinedDcLoadDevices.firstObject)
		}
	}

	Component {
		id: deviceListPageComponent

		Page {
			GradientListView {
				model: Global.allDevicesModel.combinedDcLoadDevices

				delegate: ListQuantityGroupNavigation {
					id: deviceDelegate

					required property var device

					text: device.name
					quantityModel: QuantityObjectModel {
						QuantityObject { object: dcDevice; key: "voltage"; unit: VenusOS.Units_Volt_DC }
						QuantityObject { object: dcDevice; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: dcDevice; key: "power"; unit: VenusOS.Units_Watt }
					}

					onClicked: root._showSettingsPage(device)

					DcDevice {
						id: dcDevice
						serviceUid: deviceDelegate.device.serviceUid
					}
				}
			}
		}
	}
}
