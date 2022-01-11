/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlValue {
	id: root

	property alias button: button

	signal clicked()

	height: Theme.geometry.controlCard.mediumItem.height

	contentRow.children: Switch {
		id: button

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font.size.m

		onClicked: root.clicked()
	}
}
