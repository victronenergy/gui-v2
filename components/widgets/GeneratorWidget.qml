/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Generator"
	title.text: qsTrId("overview_widget_generator_title")
	icon.source: "qrc:/images/solaryield.svg"

	extraContent.children: [
		ThreePhaseDisplay {
			anchors {
				fill: parent
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				rightMargin: Theme.geometry.overviewPage.widget.sideGauge.margins
			}

			visible: root.size >= OverviewWidget.Size.L

//            l1Value: root.dataModel != undefined ? root.dataModel.L1 : "--"
//            l2Value: root.dataModel != undefined ? root.dataModel.L2 : "--"
//            l3Value: root.dataModel != undefined ? root.dataModel.L3 : "--"
		}
	]
}
