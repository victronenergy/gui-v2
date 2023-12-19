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

	implicitHeight: Theme.geometry_controlCard_mediumItem_height

	contentRow.children: ListItemButton {
		id: button

		anchors.verticalCenter: parent.verticalCenter

		onClicked: root.clicked()
	}
}
