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

		// When using key navigation to move between items in the grid view, auto-scroll the parent
		// ListView to ensure the focused control can be seen. Otherwise, if the group card is wider
		// than a single screen, the focused control may remain off-screen, as the ListView auto-
		// scroll behaviour simply scrolls to the beginning of each group card.
		function scrollToControl(item) {
			const itemContentX = contentItem.mapFromItem(item, 0, 0).x
			let distance
			if (itemContentX + item.width > contentX + width) {
				// Scroll to the right (distance is positive)
				distance = (itemContentX + item.width) - (contentX + width)
			} else if (itemContentX < contentX) {
				// Scroll to the left (distance is negative)
				distance = (itemContentX - contentX)
			} else {
				return
			}
			if (Math.abs(distance) > width * 2) {
				// The item is far away, so jump to the new contentX, instead of flicking.
				contentX += distance
				returnToBounds()
			} else {
				let velocity = Math.sqrt(2 * Math.abs(distance) * flickDeceleration)
				if (distance > 0) {
					velocity = -velocity
				}
				flick(velocity, 0)
			}
		}

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal

		// Allow scrollToControl() to auto-scroll the view without interference from the built-in
		// ListView scroll behaviour.
		highlightFollowsCurrentItem: false

		model: SortedSwitchableOutputGroupModel { sourceModel: Global.switches.groups }
		delegate: SwitchableOutputGroupCard {
			height: cardsView.height
			onCurrentItemChanged: {
				if (currentItem) {
					cardsView.scrollToControl(currentItem)
				}
			}
		}
		WheelHandler {
			enabled: Qt.platform.os == "wasm" || Global.isDesktop
			onWheel: (event)=>{cardsView.flick(event.angleDelta.y*event.y, 0)}
		}
	}

}
