/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property color backgroundColor: Theme.color_page_background
	property bool fullScreenWhenIdle
	readonly property bool isCurrentPage: !!Global.mainView && Global.mainView.currentPage === root
	readonly property bool defaultAnimationEnabled: !!Global.mainView && Global.mainView.allowPageAnimations
			&& !Global.mainView.screenIsBlanked
	property bool animationEnabled: defaultAnimationEnabled && isCurrentPage

	property int topLeftButton: VenusOS.StatusBar_LeftButton_None
	property int topRightButton: VenusOS.StatusBar_RightButton_None

	property var tryPop // optional function: returns whether the page can be poppped

	readonly property bool __is_venus_gui_page__: true

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_screen_height
	focus: isCurrentPage
}
