/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	width: parent.width
	height: Theme.geometry_controlCard_height

	title: CommonWords.switches

	BaseListView {
		id: cardsView

		// When using key navigation to move between items in the grid view, auto-scroll the parent
		// ListView to ensure the focused control can be seen. Otherwise, if the group card is wider
		// than a single screen, the focused control may remain off-screen, as the ListView auto-
		// scroll behaviour simply scrolls to the beginning of each group card.
		function scrollToControl(item) {
			const itemContentPos = contentItem.mapFromItem(item, 0, 0)
			const distance = orientation === ListView.Horizontal
					? _scrollDistance(itemContentPos.x, item.width, contentX, width)
					: _scrollDistance(itemContentPos.y, item.height, contentY, height)
			if (distance === 0) {
				return
			}

			// If item is far away, jump to the new content pos, instead of flicking.
			if (orientation === ListView.Horizontal && Math.abs(distance) > width * 2) {
				contentX += distance
				returnToBounds()
			} else if (orientation === ListView.Vertical && Math.abs(distance) > height * 2) {
				contentY += distance
				returnToBounds()
			} else {
				// The item is close by, so just scroll to it.
				let velocity = Math.sqrt(2 * Math.abs(distance) * flickDeceleration)
				if (distance > 0) {
					velocity = -velocity
				}
				flick(orientation === ListView.Horizontal ? velocity : 0,
					  orientation === ListView.Vertical ? velocity : 0)
			}
		}

		function _scrollDistance(itemContentPos, itemSize, contentPos, viewSize) {
			if (itemContentPos + itemSize > contentPos + viewSize) {
				// Scroll right or scroll down (return a positive distance)
				return (itemContentPos + itemSize) - (contentPos + viewSize)
			} else if (itemContentPos < contentPos) {
				// Scroll left or scroll up (return a negative distance)
				return (itemContentPos - contentPos)
			} else {
				return 0
			}
		}

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
			bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: Theme.screenSize === Theme.Portrait ? ListView.Vertical : ListView.Horizontal

		// Allow scrollToControl() to auto-scroll the view without interference from the built-in
		// ListView scroll behaviour.
		highlightFollowsCurrentItem: false

		model: SortedSwitchableOutputGroupModel { sourceModel: Global.switches.groups }
		delegate: SwitchableOutputGroupCard {
			onCurrentItemChanged: {
				if (currentItem) {
					cardsView.scrollToControl(currentItem)
				}
			}
		}
	}

}
