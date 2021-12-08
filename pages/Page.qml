/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import Victron.VenusOS

Item {
	id: root

	signal controlsButtonClicked(bool wasToggled)
	property bool isControlCardsPage
	property alias controlsButton: controlsButton

	Button {
		id: controlsButton

		anchors {
			left: parent.left
			leftMargin: 26
			top: parent.top
			topMargin: 10
		}

		height: 32
		width: height
		display: C.AbstractButton.IconOnly
		color: Theme.okColor
		icon.source: isControlCardsPage ? "qrc:/images/controls-toggled.svg" : "qrc:/images/controls.svg"
		icon.width: 28
		icon.height: 28
		onClicked: root.controlsButtonClicked(isControlCardsPage)
	}
}
