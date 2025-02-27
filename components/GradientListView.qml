/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

ListView {
	id: root

	readonly property Page parentPage: Utils.findParentPage(root)
	property int _lastCurrentIndex

	width: parent.width
	height: parent.height
	bottomMargin: Theme.geometry_gradientList_bottomMargin
	leftMargin: Theme.geometry_page_content_horizontalMargin
	rightMargin: Theme.geometry_page_content_horizontalMargin
	boundsBehavior: Flickable.StopAtBounds
	spacing: Theme.geometry_gradientList_spacing
	focus: true

	onCurrentIndexChanged: {
		const lastIndex = _lastCurrentIndex
		_lastCurrentIndex = currentIndex

		// If the current item is not enabled, skip it and set curretIndex to the next/prev item.
		const item = itemAtIndex(currentIndex)
		if (item && !item.enabled) {
			if (currentIndex < lastIndex) {
				// User is navigating up the list, so skip backwards
				if (currentIndex > 0) {
					currentIndex--
				}
			} else {
				// User is navigating down the list, or the list is at the top, so skip forward
				if (currentIndex < count - 1) {
					currentIndex++
				}
			}
		}
	}

	ViewGradient {
		anchors.bottom: root.bottom
	}

	maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
	flickDeceleration: Theme.geometry_flickable_flickDeceleration

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry_gradientList_topMargin
		bottomPadding: Theme.geometry_gradientList_bottomMargin
	}
}
