/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias checked: radioButton.checked
	property alias radioButton: radioButton

	signal clicked()

	down: mouseArea.containsPress

	content.children: [
		RadioButton {
			id: radioButton

			onClicked: root.clicked()
		}
	]

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root.clicked()
	}
}
