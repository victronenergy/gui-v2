/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

/*
  Note that the size of the 'PressArea' is larger than the size of the parent ColorImage, which may cause unexpected behavior if you
  place multiple RemoveButtons next to each other.
*/

CP.ColorImage {
	id: root

	signal clicked()

	anchors.verticalCenter: parent.verticalCenter
	source: "qrc:/images/icon_minus.svg"
	color: Theme.color_ok

	PressArea {
		anchors.centerIn: parent
		height: Theme.geometry_listItem_height
		width: height
		onClicked: root.clicked()
	}
}
