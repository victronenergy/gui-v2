/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	width: parent.width
	anchors {
		top: parent.top
		bottom: parent.bottom
		bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
	}

	BaseListView {
		id: cardsView
		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal
		model: Global.switches.groups
		delegate: SwitchableOutputGroupCard {
			height: cardsView.height
		}
	}

}
