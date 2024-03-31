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

	function pageInView(pageXStart, pageWidth, threshold) {
		const pageXEnd = pageXStart + pageWidth
		const visibleXStart = listView.contentX + listView.originX + threshold
		const visibleXEnd = listView.contentX + listView.originX + pageWidth - threshold

		return visibleXStart >= pageXStart && visibleXStart <= pageXEnd
				|| visibleXEnd >= pageXStart && visibleXEnd <= pageXEnd
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
		focus: control.focus

		spacing: control.spacing
		orientation: control.orientation
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.StopAtBounds

		highlightRangeMode: Global.allPagesLoaded ? ListView.StrictlyEnforceRange : ListView.NoHighlightRange
		preferredHighlightBegin: 0
		preferredHighlightEnd: 0
		highlightMoveDuration: 250
		maximumFlickVelocity: 4 * (control.orientation === Qt.Horizontal ? width : height)
	}
}
