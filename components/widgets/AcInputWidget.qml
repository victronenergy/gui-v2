/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property var input
	property var phaseModel
	property string phaseModelProperty

	value: input ? input.power : NaN
	physicalQuantity: Units.Power
	phaseModel: input ? input.phases : null
	phaseModelProperty: "power"

	extraContent.children: phaseModel && phaseModel.count > 1 ? _phases : []

	property list<ThreePhaseDisplay> _phases: [
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
