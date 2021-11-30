/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property bool isTopPage
	property alias controlsButton: controlsButton

	color: Theme.backgroundColor

	Button {
		id: controlsButton

		anchors {
			left: parent.left
			leftMargin: 26
			top: parent.top
			topMargin: 10
		}

		height: 26
		color: Theme.okColor
		icon.source: controlsDialogContainer.visible ? "qrc:/images/controls-toggled.svg" : "qrc:/images/controls.svg"
		onClicked: {
			if (!controlsDialogContainer.visible) {
				controlsDialogContainer.show()
			} else {
				controlsDialogContainer.hide()
			}
		}
	}
}
