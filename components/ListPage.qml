/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property int restoreIndex
	property GradientListView listView

	function navigateTo(page, properties, idx) {
		restoreIndex = idx
		Global.pageManager.pushPage(page, properties)
	}

	Timer {
		id: restoreTimer
		repeat: false
		interval: 2
		onTriggered: root.listView.positionViewAtIndex(root.restoreIndex, ListView.Center)
	}

	onVisibleChanged: if (visible && !!root.listView) restoreTimer.start()
	onListViewChanged: if (!!root.listView) { root.listView.listPage = root; root.listView.parent = root }
	Component.onCompleted: if (!!root.listView && root.listView.listPage != root) listViewChanged()
}
