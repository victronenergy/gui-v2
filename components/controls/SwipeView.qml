/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.SwipeView {
	id: control

	readonly property alias flicking: listView.flicking
	readonly property alias dragging: listView.dragging
	readonly property bool moving: listView.moving || scrollingTimer.running

	property int focusEdgeHint

	function pageInView(pageXStart, pageWidth, threshold) {
		const pageXEnd = pageXStart + pageWidth
		const visibleXStart = listView.contentX + threshold
		const visibleXEnd = listView.contentX + pageWidth - threshold

		return visibleXStart >= pageXStart && visibleXStart <= pageXEnd
				|| visibleXEnd >= pageXStart && visibleXEnd <= pageXEnd
	}

	function getCurrentPage() {
		return listView.currentItem
	}

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
							contentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
							 contentHeight + topPadding + bottomPadding)

	contentItem: ListView {
		id: listView

		model: control.contentModel
		interactive: control.interactive
		currentIndex: control.currentIndex
		onCurrentIndexChanged: scrollingTimer.restart()	// 'listView.moving' stays false when we are moving to a different page due to clicking on the nav bar.
														// The scrolling timer is needed to tell us when the listView is in motion due to a nav bar click.
		focus: control.focus
		keyNavigationEnabled: false

		spacing: control.spacing
		orientation: control.orientation
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.StopAtBounds

		highlightRangeMode: ListView.StrictlyEnforceRange
		preferredHighlightBegin: 0
		preferredHighlightEnd: 0
		highlightMoveDuration: Global.allPagesLoaded ? 250 : 0 // don't animate when loading initial page
		maximumFlickVelocity: 4 * (control.orientation === Qt.Horizontal ? width : height)

		Timer {
			id: scrollingTimer
			interval: listView.highlightMoveDuration
		}
	}
}
