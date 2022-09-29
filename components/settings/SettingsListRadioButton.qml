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
	property alias caption: caption

	signal clicked()

	implicitHeight: visible ? defaultImplicitHeight + (caption.text.length ? caption.implicitHeight : 0)  : 0
	down: mouseArea.containsPress

	content.children: [
		RadioButton {
			id: radioButton

			onClicked: root.clicked()
		}
	]

	SettingsLabel {
		id: caption

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry.settingsListItem.content.verticalMargin
		}
		topPadding: 0
		bottomPadding: 0
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root.clicked()
	}
}
