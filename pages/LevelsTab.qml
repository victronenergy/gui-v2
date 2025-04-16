/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

BaseListView {
	id: root

	property bool animationEnabled: true

	// QTBUG-102340: Horizontal ListView ignores topMargin, so set anchors.topMargin instead
	anchors.topMargin: Global.pageManager?.expandLayout
			? Theme.geometry_levelsPage_gaugesView_expanded_topMargin
			: Theme.geometry_levelsPage_gaugesView_compact_topMargin
	bottomMargin: Global.pageManager?.expandLayout
			? Theme.geometry_levelsPage_gaugesView_expanded_bottomMargin
			: Theme.geometry_levelsPage_gaugesView_compact_bottomMargin
	leftMargin: contentWidth > width
			? Theme.geometry_levelsPage_gaugesView_horizontalMargin
			: parent.width/2 - contentWidth / 2
	rightMargin: contentWidth > width
			? Theme.geometry_levelsPage_gaugesView_horizontalMargin
			: 0

	orientation: ListView.Horizontal
	spacing: Gauges.spacing(count)
	currentIndex: 0

	Behavior on anchors.topMargin {
		enabled: root.animationEnabled
		NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
	}
}
