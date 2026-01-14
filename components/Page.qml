/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property color backgroundColor: Theme.color_page_background
	property bool fullScreenWhenIdle
	readonly property bool isCurrentPage: !!Global.mainView && Global.mainView.currentPage === root
	readonly property bool defaultAnimationEnabled: !!Global.mainView
			&& Global.mainView.allowPageAnimations
			&& !Global.mainView.screenIsBlanked
	property bool animationEnabled: defaultAnimationEnabled && visible

	property int topLeftButton: VenusOS.StatusBar_LeftButton_None
	property int topRightButton: VenusOS.StatusBar_RightButton_None

	// Optional function that is called when the stack is about to pop this page. Return true if
	// the page can be popped, or false to deny it and remain on the page.
	// Takes one argument: the page to which the stack will be popped (null if popping all pages)
	property var tryPop

	readonly property bool __is_venus_gui_page__: true

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_screen_height
	focus: isCurrentPage
}
