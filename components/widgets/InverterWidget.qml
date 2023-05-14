/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property int systemState

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_Inverter

	quantityLabel.visible: false

	extraContent.children: [
		Label {
			id: statusLabel
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}
			font.pixelSize: Theme.font.overviewPage.widget.quantityLabel.maximumSize

			text: Global.inverters.inverterStateToText(root.systemState)
		}
	]
}
