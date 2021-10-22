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

		property int activeIndex: 0

		delegate: NavButton {
			text: model.text
			icon.source: model.icon
			color: buttonRepeater.activeIndex === model.index ? Theme.primaryButtonColor : Theme.secondaryButtonColor
			onClicked: {
				buttonRepeater.activeIndex = model.index
				root.buttonClicked(model.index)
			}
		}
	}
}
