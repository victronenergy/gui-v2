/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	width: parent ? parent.width : 0
	height: visible ? implicitHeight : 0
	topPadding: visible ? Theme.geometry.listItem.content.verticalMargin : 0
	bottomPadding: visible ? Theme.geometry.listItem.content.verticalMargin : 0
	leftPadding: Theme.geometry.listItem.content.horizontalMargin
	rightPadding: Theme.geometry.listItem.content.horizontalMargin
	font.pixelSize: Theme.font.size.body1
	wrapMode: Text.Wrap
}
