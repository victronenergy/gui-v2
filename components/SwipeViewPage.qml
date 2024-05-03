/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Page {
	id: root

	required property string navButtonText
	required property url navButtonIcon
	required property string url
	required property SwipeView view

	// Allow animations if this is the current page, or when dragging between pages
	animationEnabled: defaultAnimationEnabled && visible

	// Only set visible=true when the page is within the visible area of the SwipeView.
	// (This also helps to avoid QTBUG-115468.)

	// On startup, the Settings page incorrectly has an 'x' value of 0 for about half a second (Qt bug).
	// If we use 'visible: Global.mainView && Global.mainView.swipeView.pageInView(x, width, Theme.geometry_page_content_horizontalMargin)', we
	// briefly see the Settings page displayed on top of the Brief page.
	visible: Global.mainView &&
			 (view.moving
			 ? Global.mainView.swipeView.pageInView(x, width, Theme.geometry_page_content_horizontalMargin)
			 : SwipeView.isCurrentItem) // 'SwipeView.isCurrentItem' correctly returns false for the Settings page on Startup.

	property alias contentItem: content
	default property alias children: content.data

	Connections {
		ignoreUnknownSignals: true
		target: Global.mainView.swipeView
		function onCurrentIndexChanged() {
			resetFocus()
		}
	}

	function resetFocus() {
		pageFocus.focus = true
	}

	FocusScope {
		id: content
		anchors.fill: parent
		Keys.onEscapePressed: pageFocus.focus = true
	}

	KeyNavigationHighlight {
		id: pageFocus

		z: 1
		focus: true
		active: activeFocus
		margin: 0
		anchors {
			leftMargin: Theme.geometry_page_content_horizontalMargin
			rightMargin: Theme.geometry_page_content_horizontalMargin
			fill: parent
		}

		Keys.onReturnPressed: contentItem.focus = true
		Keys.onSpacePressed: contentItem.focus = true
		Keys.onLeftPressed: pageManager.navBar.goToPreviousPage()
		Keys.onRightPressed: pageManager.navBar.goToNextPage()
	}
}
