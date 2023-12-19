/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	width: parent ? parent.width : 0
	height: visible ? implicitHeight : 0
	topPadding: visible ? Theme.geometry_listItem_content_verticalMargin : 0
	bottomPadding: visible ? Theme.geometry_listItem_content_verticalMargin : 0
	leftPadding: Theme.geometry_listItem_content_horizontalMargin
	rightPadding: Theme.geometry_listItem_content_horizontalMargin
	font.pixelSize: Theme.font_size_body1
	wrapMode: Text.Wrap
}
