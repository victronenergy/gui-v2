/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "DC Loads"
	title: qsTrId("overview_widget_dcloads_title")
	type: VenusOS.OverviewWidget_Type_DcLoads
	enabled: systemLoadDevices.count > 1 || nonSystemLoadDevices.count > 0

	contentItem: ColumnLayout {
		WidgetHeader {
			text: root.title
			icon.source: "qrc:/images/dcloads.svg"
			Layout.fillWidth: true
		}

		OverviewElectricalQuantityLabel {
			widgetSize: root.size
			dataObject: Global.system.dc
			sourceType: VenusOS.ElectricalQuantity_Source_Dc
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}

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
		serviceTypes: ["dcload", "dcdc", "motordrive"]
	}
}
