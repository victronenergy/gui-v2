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

	leftPadding: icon.width + Theme.geometry_widgetHeader_spacing
	elide: Text.ElideRight
	verticalAlignment: Text.AlignVCenter

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_widgetHeader_icon_size
		height: Theme.geometry_widgetHeader_icon_size
		fillMode: Image.Pad
		color: parent.color
	}
}
