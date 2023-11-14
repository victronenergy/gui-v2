/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Row {
	width: parent ? parent.width : 0
	topPadding: visible ? Theme.geometry.listItem.content.verticalMargin : 0
	bottomPadding: visible ? Theme.geometry.listItem.content.verticalMargin : 0
	leftPadding: Theme.geometry.listItem.content.horizontalMargin
	rightPadding: Theme.geometry.listItem.content.horizontalMargin
	spacing: Theme.geometry.listItem.content.horizontalMargin

	CP.IconImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		source: "qrc:/images/information.svg"
		color: Theme.color.font.primary
	}

	Label {
		//% "Reset history on the monitor itself"
		text: qsTrId("batteryhistory_reset_history_on_the_monitor_itself")
		width: Math.min(parent.width - icon.width - parent.spacing - parent.leftPadding - parent.rightPadding, implicitWidth)
		font.pixelSize: Theme.font.size.body1
		wrapMode: Text.Wrap
	}
}
