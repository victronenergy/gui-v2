/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property color backgroundColor: Theme.color.page.background
	property bool fullScreenWhenIdle
	readonly property bool isCurrentPage: Global.pageManager.currentPage === root
	property bool animationEnabled: isCurrentPage && BackendConnection.applicationVisible

	property int topLeftButton: VenusOS.StatusBar_LeftButton_None
	property int topRightButton: VenusOS.StatusBar_RightButton_None

	property var tryPop // optional function: returns whether the page can be poppped

	width: parent ? parent.width : 0
	height: parent ? parent.height : 0

	C.StackView.onActivated: Global.pageManager.currentPage = root
}
