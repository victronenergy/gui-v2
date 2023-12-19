/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property color backgroundColor: Theme.color.page.background
	property bool fullScreenWhenIdle
	readonly property bool isCurrentPage: !!Global.pageManager && Global.pageManager.currentPage === root
	property bool animationEnabled: isCurrentPage && BackendConnection.applicationVisible

	property int topLeftButton: T.StackView.view && T.StackView.view.depth > 1 ? VenusOS.StatusBar_LeftButton_Back : VenusOS.StatusBar_LeftButton_None
	property int topRightButton: VenusOS.StatusBar_RightButton_None

	property var tryPop // optional function: returns whether the page can be poppped

	implicitWidth: T.StackView.view ? T.StackView.view.width : 0
	implicitHeight: T.StackView.view ? T.StackView.view.height : 0

	T.StackView.onActivated: if (!!Global.pageManager) Global.pageManager.currentPage = root
}
