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
				left: parent ? parent.left : undefined
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent ? parent.right : undefined
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				bottom: parent ? parent.bottom : undefined
				bottomMargin: Theme.geometry.overviewPage.widget.content.verticalMargin
			}

			visible: model != null && root.size >= OverviewWidget.Size.L
			model: root.phaseModel && root.phaseModel.count > 1 ? root.phaseModel : null
			phaseModelProperty: root.phaseModelProperty
		}
	]
}
