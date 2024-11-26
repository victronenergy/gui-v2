/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	property bool allowed: true

	width: parent ? parent.width : 0
	height: allowed ? implicitHeight : 0
	visible: allowed
	topPadding: allowed ? Theme.geometry_listItem_content_verticalMargin : 0
	bottomPadding: allowed ? Theme.geometry_listItem_content_verticalMargin : 0
	leftPadding: Theme.geometry_listItem_content_horizontalMargin
	rightPadding: Theme.geometry_listItem_content_horizontalMargin
	font.pixelSize: Theme.font_size_body1
	wrapMode: Text.Wrap
}
