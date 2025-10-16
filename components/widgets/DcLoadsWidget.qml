/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
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
	enabled: nonSystemLoadDevices.count > 0

	quantityLabel.dataObject: Global.system.dc

	onClicked: {
		Global.pageManager.pushPage("/pages/loads/DcLoadListPage.qml", {
			title: root.title,
			model: nonSystemLoadDevices
		})
	}

	FilteredDeviceModel {
		id: nonSystemLoadDevices
		serviceTypes: ["dcload", "dcdc"]
	}
}
