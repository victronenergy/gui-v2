/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "DC Loads"
	title: qsTrId("overview_widget_dcloads_title")
	icon.source: "qrc:/images/dcloads.svg"
	type: VenusOS.OverviewWidget_Type_DcLoads
	enabled: systemLoadDevices.count > 1 || nonSystemLoadDevices.count > 0

	quantityLabel.dataObject: Global.system.dc

	onClicked: {
		Global.pageManager.pushPage("/pages/loads/DcLoadListPage.qml", {
			title: root.title,
			systemModel: systemLoadDevices,
			nonSystemModel: nonSystemLoadDevices
		})
	}

	FilteredDeviceModel {
		id: systemLoadDevices
		serviceTypes: ["dcsystem"]
	}

	FilteredDeviceModel {
		id: nonSystemLoadDevices
		serviceTypes: ["dcload", "dcdc"]
	}
}
