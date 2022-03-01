/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property var phaseModel
	property string phaseModelProperty

	//% "Shore"
	title.text: qsTrId("overview_widget_shore_title")
	icon.source: "qrc:/images/shore.svg"

	sideGaugeVisible: true

	extraContent.children: [
		ThreePhaseDisplay {
			anchors {
				fill: parent
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				rightMargin: Theme.geometry.overviewPage.widget.sideGauge.margins
			}

			visible: model != null && root.size >= OverviewWidget.Size.L
			model: root.phaseModel && root.phaseModel.count > 1 ? root.phaseModel : null
			phaseModelProperty: root.phaseModelProperty
		}
	]
}
