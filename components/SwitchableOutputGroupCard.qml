/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	required property string name
	required property list<string> outputUids

	implicitWidth: outputGrid.width
	icon.source: "qrc:/images/icon_switch_24.svg"
	title.text: name

	GridView {
		id: outputGrid

		readonly property int rowCount: Math.floor(height / cellHeight)
		readonly property int columnCount: Math.ceil(root.outputUids.length / rowCount)

		anchors {
			top: root.title.bottom
			bottom: parent.bottom
			topMargin: Theme.geometry_switchableoutput_topMargin
		}
		width: cellWidth * columnCount
		cellWidth: Theme.geometry_controlCard_minimumWidth
		cellHeight: (height - Theme.geometry_controlCard_contentMargins) / Theme.geometry_switchableoutput_row_count
		interactive: false
		flow: GridView.FlowTopToBottom
		focus: Global.keyNavigationEnabled
		keyNavigationEnabled: Global.keyNavigationEnabled

		// Model is a simple string list rather than a model, as we assume the model changes are
		// rare and especially unlikely while the card is visible.
		model: root.outputUids

		delegate: SwitchableOutputDelegate {
			required property string modelData

			width: outputGrid.cellWidth
			height: outputGrid.cellHeight
			outputUid: modelData
		}
	}
}
