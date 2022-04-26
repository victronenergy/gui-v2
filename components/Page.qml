/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

FocusScope {
	id: root

	property string title
	property bool hasSidePanel
	property int navigationButton
	property color backgroundColor: Theme.color.page.background
	property bool fullScreenWhenIdle
	readonly property bool isCurrentPage: Global.pageManager.currentPage === root

	width: parent ? parent.width : 0
	height: parent ? parent.height : 0

	C.StackView.onActivated: Global.pageManager.currentPage = root

	Keys.onPressed: function(event) {
		if (Global.demoManager) {
			Global.demoManager.keyPressed(event)
		}
	}
}
