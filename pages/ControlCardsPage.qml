/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.Velib
import Victron.VenusOS

Page {
	id: root

	isControlCardsPage: true

	ListView {
		anchors {
			left: parent.left
			leftMargin: 24 // TODO - handle 7" size if it is different
			right: parent.right
			top: parent.top
			topMargin: 42 // TODO - handle 7" size if it is different
			bottom: parent.bottom
			bottomMargin: 8 // TODO - handle 7" size if it is different
		}
		spacing: 16
		orientation: ListView.Horizontal
		model: ControlCardsModel
		delegate: Loader {
			source: url
		}
	}
}
