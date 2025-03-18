/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


ControlCard {
	id: root
	property var model
	property alias title: root.title
	property int switchCol: (model.rowCount + 3)/4
	implicitWidth: Theme.geometry_controlCard_minimumWidth * switchCol
	width: Theme.geometry_controlCard_minimumWidth * switchCol

	icon.source: "qrc:/images/switches.svg"

	GridView {
		id: switchesView
		anchors {
			top: root.title.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
			bottom: parent.bottom
		}
		interactive: false
		flow: GridView.FlowTopToBottom
		cellHeight: switchesView.height/4
		cellWidth: switchesView.width / switchCol
		model: root.model

		delegate: SwitchDelegate {
			serviceUid: uid
			title: name
			width: switchesView.width / switchCol
			showSeparator: index < root.model.rowCount -1
			// Component.onCompleted: {
			// 	console.log("SwitchAuxCard count ",root.model.rowCount )
			// }
		}
	}
}
