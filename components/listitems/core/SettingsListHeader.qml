/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	property alias text: label.text

	height: 32
	implicitWidth: Math.max(label.width, 1)

	Label {
		id: label

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_listItem_content_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		font.pixelSize: Theme.font_size_body1
		wrapMode: Text.Wrap
		color: Theme.color_font_secondary
	}
}
