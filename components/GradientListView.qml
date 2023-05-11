/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListView {
	id: root

	x: Theme.geometry.page.content.horizontalMargin
	width: parent.width - Theme.geometry.page.content.horizontalMargin
	height: parent.height
	topMargin: Theme.geometry.gradientList.topMargin
	bottomMargin: Theme.geometry.gradientList.bottomMargin
	rightMargin: Theme.geometry.page.content.horizontalMargin

	// Note: do not set spacing here, as it creates extra spacing if an item has visible=false.
	// Instead, the spacing is added visually within ListItem's ListItemBackground.

	function childDelegateClicked(child) {
		var idx = root.count - 1
		while (idx-- >= 0) {
			if (itemAtIndex(idx) == child) {
				_gradientListView_clickedIndex = idx
				return
			}
		}
		_gradientListView_clickedIndex = NaN
	}

	property int _gradientListView_clickedIndex: NaN
	onVisibleChanged: {
		if (visible && !isNaN(_gradientListView_clickedIndex)) {
			restoreTimer.start()
		}
	}

	Timer {
		id: restoreTimer
		repeat: false
		interval: 20 // any less, and the position change won't necessarily activate last.
		onTriggered: {
			root.positionViewAtIndex(root._gradientListView_clickedIndex, ListView.Center)
			_gradientListView_clickedIndex = NaN
		}
	}

	ViewGradient {
		anchors {
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry.gradientList.topMargin
		bottomPadding: Theme.geometry.gradientList.bottomMargin
	}
}
