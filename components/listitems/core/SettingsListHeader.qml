/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	anchors {
		left: parent ? parent.left : undefined
		leftMargin: Theme.geometry_listItem_content_horizontalMargin
	}
	topPadding: Theme.geometry_settingsListHeader_verticalPadding
	bottomPadding: Theme.geometry_settingsListHeader_verticalPadding
	width: Math.max(implicitWidth, 1)
	font.pixelSize: Theme.font_size_body1
	wrapMode: Text.Wrap
	color: Theme.color_font_secondary
}
