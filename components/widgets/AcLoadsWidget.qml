/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	objectName: "AcLoadsWidgetWidget"
	property var phaseModel
	property string phaseModelProperty

	//% "AC Loads"
	title.text: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/acloads.svg"
	type: VenusOS.OverviewWidget_Type_AcLoads
	enabled: false

	extraContent.children: [
		ThreePhaseDisplay {
			anchors {
				left: parent ? parent.left : undefined
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent ? parent.right : undefined
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				bottom: parent ? parent.bottom : undefined
				bottomMargin: Theme.geometry.overviewPage.widget.content.verticalMargin
			}

			visible: model != null && root.size >= VenusOS.OverviewWidget_Size_L
			model: root.phaseModel && root.phaseModel.count > 1 ? root.phaseModel : null
			phaseModelProperty: root.phaseModelProperty
		}
	]
}
