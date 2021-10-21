/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property alias model: buttonRepeater.model

	signal buttonClicked(buttonIndex: int)

	anchors.horizontalCenter: parent.horizontalCenter
	height: 100

	Repeater {
		id: buttonRepeater

		delegate: NavButton {
			text: model.text
			icon.source: model.icon

			onClicked: root.buttonClicked(model.index)
		}
	}
}
