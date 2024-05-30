/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	//% "AC Loads"
	title: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/acloads.svg"
	type: VenusOS.OverviewWidget_Type_AcLoads
	quantityLabel.dataObject: Global.system.ac.consumption
	phaseCount: Global.system.ac.consumption.phases.count
	enabled: false
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		model: Global.system.ac.consumption.phases
		widgetSize: root.size
		valueType: VenusOS.Gauges_ValueType_RisingPercentage
		phaseModelProperty: "current"
		maximumValue: Global.system.ac.consumption.maximumCurrent
	}
	extraContentLoader.active: root.phaseCount > 1 || Global.system.ac.consumption.l2AndL1OutSummed
}
