/*
** Copyright (C) 2022 Victron Energy B.V.
*/
import QtQuick
import Victron.VenusOS

Label {
	width: parent ? parent.width : 0
	topPadding: Theme.geometry.settingsListItem.content.verticalMargin
	bottomPadding: Theme.geometry.settingsListItem.content.verticalMargin
	leftPadding: Theme.geometry.settingsListItem.content.horizontalMargin
	rightPadding: Theme.geometry.settingsListItem.content.horizontalMargin
	font.pixelSize: Theme.font.size.body1
	wrapMode: Text.Wrap
}

