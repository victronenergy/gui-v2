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
	height: 72

	spacing: 8 // TODO: 16 in 7inch mode

	Repeater {
		id: buttonRepeater

		height: parent.height
		property int currentIndex: 0

		delegate: NavButton {
			height: parent.height
			width: 144 // TODO: 176 in 7inch mode
			text: model.text
			icon.source: model.icon
			icon.width: model.iconWidth
			icon.height: model.iconHeight
			checked: buttonRepeater.currentIndex === model.index
			color: checked ? Theme.okColor : Theme.secondaryFontColor

			onClicked: {
				buttonRepeater.currentIndex = model.index
				root.buttonClicked(model.index)
			}
		}
	}
}
