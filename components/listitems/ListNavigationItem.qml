/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel

	signal clicked()

	down: mouseArea.containsPress
	enabled: userHasReadAccess

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			visible: text.length > 0
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_listItem_secondaryText
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignRight
		},

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			source: "qrc:/images/icon_back_32.svg"
			width: Theme.geometry_statusBar_button_icon_width
			height: Theme.geometry_statusBar_button_icon_height
			rotation: 180
			color: root.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
			fillMode: Image.PreserveAspectFit
			visible: root.enabled
		}
	]

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root.clicked()
	}
}
