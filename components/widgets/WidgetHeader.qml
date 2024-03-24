/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Row {
	id: root

	property alias title: titleLabel.text
	property alias secondaryText: secondaryLabel.text
	property alias icon: icon

	width: parent ? parent.width : 0
	spacing: Theme.geometry_widgetHeader_spacing

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: titleLabel.verticalCenter
		width: Theme.geometry_widgetHeader_icon_size
		height: Theme.geometry_widgetHeader_icon_size
		fillMode: Image.Pad
		color: titleLabel.color
	}

	Label {
		id: titleLabel
		width: parent.width - icon.width - secondaryLabel.implicitWidth - (2 * Theme.geometry_widgetHeader_spacing)
		elide: Text.ElideRight
	}

	Label {
		id: secondaryLabel
		color: Theme.color_font_secondary
	}
}

