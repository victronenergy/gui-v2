/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property var input: Global.acInputs.connectedInput
	property var phaseModel: input && input.connected ? input.phases : null

	rightPadding: sideGauge.visible ? Theme.geometry.overviewPage.widget.sideGauge.margins : 0
	quantityLabel.dataObject: input && input.connected ? input : null
	extraContent.children: phaseModel && phaseModel.count > 1 ? phaseDisplay : []

	VerticalGauge {
		id: sideGauge

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry.overviewPage.widget.sideGauge.margins
		}
		width: Theme.geometry.overviewPage.widget.sideGauge.width
		radius: Theme.geometry.overviewPage.widget.sideGauge.radius
		backgroundColor: Theme.color.overviewPage.widget.sideGauge.background
		foregroundColor: Theme.color.overviewPage.widget.sideGauge.highlight
		animationEnabled: visible && root.animationEnabled
		value: valueRange.valueAsRatio
		visible: root.type !== VenusOS.OverviewWidget_Type_AcGenerator

		ValueRange {
			id: valueRange

			value: sideGauge.visible ? root.quantityLabel.value : NaN
		}
	}

	property list<ThreePhaseDisplay> phaseDisplay: [
		ThreePhaseDisplay {
			anchors {
				left: parent ? parent.left : undefined
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent ? parent.right : undefined
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin + root.rightPadding
				bottom: parent ? parent.bottom : undefined
				bottomMargin: Theme.geometry.overviewPage.widget.extraContent.bottomMargin
			}

			visible: model != null && root.size >= VenusOS.OverviewWidget_Size_L
			model: root.phaseModel && root.phaseModel.count > 1 ? root.phaseModel : null
		}
	]
}
