/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	//% "Essential Loads"
	title: qsTrId("overview_widget_essential_loads_title")
	icon.source: "qrc:/images/icon_CL_24.svg"
	type: VenusOS.OverviewWidget_Type_EssentialLoads
	quantityLabel.dataObject: Global.system.load.acOut
	phaseCount: Global.system.load.acOut.phases.count
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		model: Global.system.load.acOut.phases
		widgetSize: root.size
		valueType: VenusOS.Gauges_ValueType_RisingPercentage
		maximumValue: Global.system.load.maximumAcCurrent
	}
	extraContentLoader.active: root.phaseCount > 1 || Global.system.load.acOut.l2AndL1OutSummed

	// AC meters with Position=0 (AC output) are considered as "Essential Loads", so they are
	// accessible from this AC Loads widget.
	// For 3-phase systems, the drilldown is always enabled.
	// For 1-phase systems, only enable the drilldown if there are devices to be shown.
	enabled: Global.system.load.acOut.phaseCount > 1 || essentialLoadDevices.count > 0
	onClicked: {
		Global.pageManager.pushPage("/pages/loads/AcLoadListPage.qml", {
			title: root.title,
			measurements: Global.system.load.acOut,
			model: essentialLoadDevices
		})
	}

	FilteredDeviceModel {
		id: essentialLoadDevices
		serviceTypes: ["acload", "evcharger", "heatpump"]
		childFilterIds: { "acload": ["Position"], "evcharger": ["Position"], "heatpump": ["Position"] }
		childFilterFunction: (device, childItems) => {
			return childItems["Position"]?.value === VenusOS.AcPosition_AcOutput
		}
	 }
}
