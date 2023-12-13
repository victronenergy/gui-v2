/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as C
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property color backgroundColor: Theme.color.page.background
	property bool fullScreenWhenIdle
	readonly property bool isCurrentPage: !!Global.pageManager && Global.pageManager.currentPage === root
	property bool animationEnabled: isCurrentPage && BackendConnection.applicationVisible

	property int topLeftButton: C.StackView.view && C.StackView.view.depth > 1 ? Enums.StatusBar_LeftButton_Back : Enums.StatusBar_LeftButton_None
	property int topRightButton: Enums.StatusBar_RightButton_None

	property var tryPop // optional function: returns whether the page can be poppped

	implicitWidth: C.StackView.view ? C.StackView.view.width : 0
	implicitHeight: C.StackView.view ? C.StackView.view.height : 0

	C.StackView.onActivated: if (!!Global.pageManager) Global.pageManager.currentPage = root
}
