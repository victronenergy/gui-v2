/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias checked: radioButton.checked
	property alias radioButton: radioButton
	property var buttonGroup: QtObject {}

	signal clicked()

	down: mouseArea.containsPress

	content.children: [
		RadioButton {
			id: radioButton

			ButtonGroup.group: root.buttonGroup
			onClicked: root.clicked()
		}
	]

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root.clicked()
	}
}
