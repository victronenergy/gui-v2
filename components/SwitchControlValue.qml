/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
		font.pixelSize: Theme.font.size.body2

		onClicked: root.clicked()
	}
}
