/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.VenusOS

/*
	A scrolling list of the cards declared inside it, laid out as in the Controls pane, which fills
	its parent. The cards stand side by side, and scroll sideways. In portrait layout, they stand
	one above the other, and scroll up and down.

	Declare the cards as direct children of it, for example:

		PluginCardListView {
			PluginCard { title: "Pump" }
			PluginCard { title: "Tank" }
		}

	The cards are fixed when the list is created. The list sets the width and height of each card,
	as in the Controls pane: do not set them on the card.

	Key navigation works as in the Controls pane. The Left and Right keys move the key focus to the
	previous or next card. In portrait layout, the Up and Down keys do, from the first or last item
	in a card.
*/
FocusScope {
	id: root

	// The cards, in order.
	default property list<PluginCard> cards

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	focus: true

	// The same layout as ControlCardsPage.
	BaseListView {
		id: listView

		readonly property real cardWidth: orientation === ListView.Vertical ? width
				: root.cards.length > 2 ? Theme.geometry_controlCard_minimumWidth : Theme.geometry_controlCard_maximumWidth

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
			bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: Theme.screenSize === Theme.Portrait ? ListView.Vertical : ListView.Horizontal
		highlightMoveVelocity: Theme.animation_cards_highlightMoveVelocity
		highlightMoveDuration: -1

		model: ObjectModel {
			id: cardModel
		}

		WheelHandler {
			// A vertical list scrolls with the wheel already.
			enabled: (Qt.platform.os === "wasm" || Global.isDesktop) && listView.orientation === ListView.Horizontal
			onWheel: (wheel) => {
				// Each step of the wheel (120) adds 2/3 of a second of flick velocity. A flick has
				// the opposite sign to the view's velocity, hence the minus.
				listView.flick(listView.flickDeceleration * wheel.angleDelta.y / 180
						- listView.horizontalVelocity, 0)
				wheel.accepted = true
			}
		}
	}

	Component.onCompleted: {
		// Fill the model once, when every card exists. The model is not bound to 'cards', as the
		// cards are fixed when the list is created.
		for (let i = 0; i < root.cards.length; ++i) {
			const card = root.cards[i]
			card.width = Qt.binding(() => listView.cardWidth)
			card.height = Qt.binding(() => listView.orientation === ListView.Vertical
					? card.implicitHeight : listView.height)
			cardModel.append(card)
		}
	}
}
