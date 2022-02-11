/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property string phaseValueProperty

	//% "AC Loads"
	title.text: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/acloads.svg"
	interactive: false

	extraContent.children: [
		ThreePhaseDisplay {
			anchors {
				fill: parent
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				rightMargin: Theme.geometry.overviewPage.widget.sideGauge.margins
			}

			visible: root.size >= OverviewWidget.Size.L
			model: root.dataModel
			phaseValueProperty: root.phaseValueProperty
		}
	]
}
