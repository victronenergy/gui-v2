/*
** Copyright (C) 2022 Victron Energy B.V.
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
