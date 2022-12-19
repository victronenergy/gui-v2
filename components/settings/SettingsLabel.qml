/*
** Copyright (C) 2022 Victron Energy B.V.
*/
import QtQuick
import Victron.VenusOS

Label {
	width: parent ? parent.width : 0
	height: visible ? implicitHeight : 0
	topPadding: visible ? Theme.geometry.settingsListItem.content.verticalMargin : 0
	bottomPadding: visible ? Theme.geometry.settingsListItem.content.verticalMargin : 0
	leftPadding: Theme.geometry.settingsListItem.content.horizontalMargin
	rightPadding: Theme.geometry.settingsListItem.content.horizontalMargin
	font.pixelSize: Theme.font.size.body1
	wrapMode: Text.Wrap
}
