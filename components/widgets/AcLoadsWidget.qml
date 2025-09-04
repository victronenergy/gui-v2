/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	readonly property ObjectAcConnection measurements: Global.system.showInputLoads
			? Global.system.load.acIn
			: Global.system.load.ac

	//% "AC Loads"
	title: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/acloads.svg"
	type: VenusOS.OverviewWidget_Type_AcLoads
	quantityLabel.dataObject: root.measurements
	phaseCount: root.measurements.phases.count
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		model: root.measurements.phases
		widgetSize: root.size
		valueType: VenusOS.Gauges_ValueType_RisingPercentage
		maximumValue: Global.system.load.maximumAcCurrent
	}
	extraContentLoader.active: root.phaseCount > 1 || root.measurements.l2AndL1OutSummed

	// AC meters with Position=1 (AC input) are considered as "AC Loads", so they are
	// accessible from this AC Loads widget.
	// For 3-phase systems, the drilldown is always enabled.
	// For 1-phase systems, only enable the drilldown if there are devices to be shown.
	enabled: root.measurements.phaseCount > 1 || inputLoadDevices.count > 0

	onClicked: {
		Global.pageManager.pushPage("/pages/loads/AcLoadListPage.qml", {
			title: root.title,
			measurements: root.measurements,
			model: Global.system.showInputLoads ? inputLoadDevices : allLoadDevices
		})
	}

	// TODO when #2371 is fixed, use a single FilteredDeviceModel instead of choosing between this
	// ServiceDeviceModel vs an AggregateDeviceModel.
	ServiceDeviceModel {
		id: allLoadDevices
		serviceTypes: ["acload", "evcharger", "heatpump"]
	}

	AggregateDeviceModel {
		id: inputLoadDevices
		sourceModels: [
			acLoadInputDevices,
			evChargerInputDevices,
			heatPumpInputDevices,
		]
	}

	AcMeterModel {
		id: acLoadInputDevices
		position: VenusOS.AcPosition_AcInput
		serviceTypes: ["acload"]
		modelId: "acload-input"
	}

	AcMeterModel {
		id: evChargerInputDevices
		position: VenusOS.AcPosition_AcInput
		serviceTypes: ["evcharger"]
		modelId: "evcharger-input"
	}

	AcMeterModel {
		id: heatPumpInputDevices
		position: VenusOS.AcPosition_AcInput
		serviceTypes: ["heatpump"]
		modelId: "heatpump-input"
	}
}
