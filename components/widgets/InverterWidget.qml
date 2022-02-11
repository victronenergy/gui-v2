/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Inverter"
	title.text: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/solaryield.svg"

	sideGaugeVisible: true
	sideGaugeValue: 0.7 // TODO: data model

	extraContent.children: [
		Label {
			id: statusLabel
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}

			text: "Absorption" // TODO: data model
		}
	]
}
