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
		phaseModelProperty: "current"
		maximumValue: Global.system.load.maximumAcCurrent
	}
	extraContentLoader.active: root.phaseCount > 1 || root.measurements.l2AndL1OutSummed

	// Heat pumps with Position=1 (AC input) are considered as "AC Loads", so they are
	// accessible from this AC Loads widget.
	enabled: Global.allDevicesModel.heatPumpInputDevices.count > 0
	onClicked: openDevicePageOrList(Global.allDevicesModel.heatPumpInputDevices)
}
