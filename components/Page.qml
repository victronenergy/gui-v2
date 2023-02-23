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

	property int topLeftButton: VenusOS.StatusBar_LeftButton_None
	property int topRightButton: VenusOS.StatusBar_RightButton_None

	width: parent ? parent.width : 0
	height: parent ? parent.height : 0

	C.StackView.onActivated: Global.pageManager.currentPage = root
}
