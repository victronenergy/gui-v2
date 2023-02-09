/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlValue {
	id: root

	property alias button: button

	implicitHeight: Theme.geometry.controlCard.mediumItem.height

	signal clicked()

	contentRow.children: RadioButton {
		id: button

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font.size.body2
		down: mouseArea.containsPress || pressed

		onClicked: root.clicked()
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: {
			button.clicked()
		}
	}
}
