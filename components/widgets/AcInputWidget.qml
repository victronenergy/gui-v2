/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property var input: Global.acInputs.connectedInput
	property var phaseModel: input && input.connected ? input.phases : null

	quantityLabel.dataObject: input && input.connected ? input : null
	extraContent.children: phaseModel && phaseModel.count > 1 ? phaseDisplay : []

	property list<ThreePhaseDisplay> phaseDisplay: [
		ThreePhaseDisplay {
			anchors {
				left: parent ? parent.left : undefined
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent ? parent.right : undefined
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				bottom: parent ? parent.bottom : undefined
				bottomMargin: Theme.geometry.overviewPage.widget.extraContent.bottomMargin
			}

			visible: model != null && root.size >= VenusOS.OverviewWidget_Size_L
			model: root.phaseModel && root.phaseModel.count > 1 ? root.phaseModel : null
		}
	]
}
