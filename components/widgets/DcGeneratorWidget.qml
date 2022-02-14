/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property string phaseValueProperty

	//% "DC Generator"
	title.text: qsTrId("overview_widget_dcgenerator_title")
	icon.source: "qrc:/images/generator.svg"

	extraContent.children: [
		ThreePhaseDisplay {
			anchors {
				fill: parent
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				rightMargin: Theme.geometry.overviewPage.widget.sideGauge.margins
			}

			visible: root.size >= OverviewWidget.Size.L
		}
	]
}
