/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as C
import Victron.VenusOS

Rectangle {
	property var backgroundRect
	property var dialog

	// TODO: do this with shader, or with border image taking noise sample.
	anchors.fill: backgroundRect
	anchors.margins: -border.width
	color: "transparent"
	border.color: Qt.rgba(0.0, 0.0, 0.0, 0.7)
	border.width: Math.max(dialog.parent.width - parent.width, dialog.parent.height - parent.height)
	radius: backgroundRect.radius + border.width
}
