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

	down: pressArea.containsPress
	enabled: userHasWriteAccess

	content.children: [
		RadioButton {
			id: radioButton

			onClicked: root.clicked()
		}
	]

	PressArea {
		id: pressArea

		radius: backgroundRect.radius
		anchors {
			fill: parent
			bottomMargin: root.spacing
		}

		onClicked: root.clicked()
	}
}
