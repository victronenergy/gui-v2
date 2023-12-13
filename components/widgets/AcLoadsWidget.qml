/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import Victron.VenusOS

OverviewWidget {
	id: root

	//% "AC Loads"
	title: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/acloads.svg"
	type: Enums.OverviewWidget_Type_AcLoads
	enabled: false

	quantityLabel.dataObject: Global.system.ac.consumption

	extraContent_children: [
		ThreePhaseDisplay {
			anchors {
				left: parent ? parent.left : undefined
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent ? parent.right : undefined
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				bottom: parent ? parent.bottom : undefined
				bottomMargin: Theme.geometry.overviewPage.widget.extraContent.bottomMargin
			}

			visible: model != null && root.size >= Enums.OverviewWidget_Size_L
			model: Global.system.ac.consumption.phases.count > 1 ? Global.system.ac.consumption.phases : null
		}
	]
}
