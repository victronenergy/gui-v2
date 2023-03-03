/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

ListItem {
	id: root

	property alias checked: radioButton.checked
	property alias radioButton: radioButton
	property alias caption: caption

	signal clicked()

	implicitHeight: visible ? defaultImplicitHeight + (caption.text.length ? caption.implicitHeight : 0)  : 0
	down: mouseArea.containsPress
	enabled: userHasWriteAccess

	content.children: [
		RadioButton {
			id: radioButton

			onClicked: root.clicked()
		}
	]

	ListLabel {
		id: caption

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry.listItem.content.verticalMargin
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
