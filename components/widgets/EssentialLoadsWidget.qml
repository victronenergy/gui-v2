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
	enabled: false
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		model: Global.system.load.acOut.phases
		widgetSize: root.size
		valueType: VenusOS.Gauges_ValueType_RisingPercentage
		phaseModelProperty: "current"
		maximumValue: Global.system.load.maximumAcCurrent
	}
	extraContentLoader.active: root.phaseCount > 1 || Global.system.load.acOut.l2AndL1OutSummed
}