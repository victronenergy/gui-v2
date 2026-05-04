/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

AcWidget {
	id: root

	readonly property ObjectAcConnection measurements: Global.system.load.acOut

	//% "Essential Loads"
	title: qsTrId("overview_widget_essential_loads_title")
	type: VenusOS.OverviewWidget_Type_EssentialLoads
	quantitySourceType: VenusOS.ElectricalQuantity_Source_Ac
	quantityDataObject: measurements
	phaseModel: measurements.phases.count > 1 || measurements.l2AndL1OutSummed ? measurements.phases : null

	// AC meters with Position=0 (AC output) are considered as "Essential Loads", so they are
	// accessible from this AC Loads widget.
	// For 3-phase systems, the drilldown is always enabled.
	// For 1-phase systems, only enable the drilldown if there are devices to be shown.
	enabled: measurements.phaseCount > 1 || essentialLoadDevices.count > 0

	contentItem: AcWidgetContent {
		widget: root
		iconSource: "qrc:/images/icon_CL_24.svg"
		gaugeValueType: VenusOS.Gauges_ValueType_RisingPercentage
		gaugeMaximumValue: Global.system.load.maximumAcCurrent
	}

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
