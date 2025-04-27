/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

/*
  A page in the main swipe view.

  If the page allows key navigation, it should:
	- set activeFocusOnTab to true
	- set blockInitialFocus to true if the page has a long scrollable list, so that the user can
	  easily skip past the page during key navigation
*/
Page {
	id: root

	required property string navButtonText
	required property url navButtonIcon
	required property string url
	required property SwipeView view

	// Set to true if this page should be initially blocked by a full-screen highlight, which the
	// user needs to dismiss (by pressing the space key) before the page receives focus.
	property bool blockInitialFocus

	// Allow animations if this is the current page, or when dragging between pages
	animationEnabled: defaultAnimationEnabled && visible

	// Only set visible=true when the page is within the visible area of the SwipeView.
	// (This also helps to avoid QTBUG-115468.)

	// On startup, the Settings page incorrectly has an 'x' value of 0 for about half a second (Qt bug).
	// If we use 'visible: Global.mainView && Global.mainView.swipeView.pageInView(x, width, Theme.geometry_page_content_horizontalMargin)', we
	// briefly see the Settings page displayed on top of the Brief page.
	visible: Global.mainView &&
			 ((view && view.moving && Global.mainView.swipeView)
			 ? Global.mainView.swipeView.pageInView(x, width, Theme.geometry_page_content_horizontalMargin)
			 : SwipeView.isCurrentItem) // 'SwipeView.isCurrentItem' correctly returns false for the Settings page on Startup.
}
