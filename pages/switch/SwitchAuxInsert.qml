/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root



	property int spacing: Theme.geometry_controlCardsPage_spacing
	property SwitchesCardModel model: null
	implicitWidth: cards.implicitWidth

	Row {
		id:cards
		height: parent.height
		spacing: root.spacing

		Repeater {
			model: root.model
			delegate: SwitchAuxCard {
				title.text: cardName
				model: viewModel
			}
		}
	}
}
