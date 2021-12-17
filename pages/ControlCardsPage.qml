/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.Velib
import Victron.VenusOS

Page {
	id: root

	ListView {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCardsPage.leftMargin
			right: parent.right
			top: parent.top
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCardsPage.bottomMargin
		}
		spacing: Theme.geometry.controlCardsPage.spacing
		orientation: ListView.Horizontal
		model: ControlCardsModel
		delegate: Loader {
			height: parent ? parent.height : 0
			source: url
		}
	}
}
