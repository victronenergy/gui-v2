/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlValue {
	id: root

	property alias button: button

	implicitHeight: Theme.geometry_controlCard_mediumItem_height

	signal clicked()

	contentRow.children: RadioButton {
		id: button

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_size_body2
		down: mouseArea.containsPress || pressed
		checkable: false

		onClicked: root.clicked()
	}

	ListPressArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: {
			button.clicked()
		}
	}
}
