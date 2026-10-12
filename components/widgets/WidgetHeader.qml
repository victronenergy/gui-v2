/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Label {
	id: root

	property alias icon: icon

	leftPadding: icon.width + Theme.geometry_size_4
	elide: Text.ElideRight
	verticalAlignment: Text.AlignVCenter
	font.pixelSize: Theme.font_control_title

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_size_24
		height: Theme.geometry_size_24
		fillMode: Image.Pad
		color: parent.color
	}
}
