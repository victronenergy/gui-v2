/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

ListItem {
	id: root

	property alias checked: radioButton.checked
	property alias radioButton: radioButton

	signal clicked()

	down: pressArea.containsPress || radioButton.down
	enabled: userHasWriteAccess

	content.children: [
		RadioButton {
			id: radioButton

			// Alternative to binding "enabled: !checked". No clicked() signal
			// got emitted when the button was disabled on checked=false.
			onClicked: if (root.checked) root.clicked()
		}
	]

	ListPressArea {
		id: pressArea

		enabled: !root.checked
		radius: backgroundRect.radius
		anchors {
			fill: parent
			bottomMargin: root.spacing
		}

		onClicked: root.clicked()
	}
}
