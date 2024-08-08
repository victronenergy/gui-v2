/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

ListView {
	id: root

	width: parent.width
	height: parent.height
	bottomMargin: Theme.geometry_gradientList_bottomMargin
	leftMargin: Theme.geometry_page_content_horizontalMargin
	rightMargin: Theme.geometry_page_content_horizontalMargin
	boundsBehavior: Flickable.StopAtBounds

	// Note: do not set spacing here, as it creates extra spacing if an item has visible=false.
	// Instead, the spacing is added visually within ListItem's ListItemBackground.

	ViewGradient {
		anchors.bottom: root.bottom
	}

	maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
	flickDeceleration: Theme.geometry_flickable_flickDeceleration

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry_gradientList_topMargin
		bottomPadding: Theme.geometry_gradientList_bottomMargin
	}

	// When the ListView becomes invisible (e.g. if another page is pushed on top) the contentHeight
	// becomes 0 and contentY is reset; so, when the page above is popped and the ListView becomes
	// visible again, the list has unexpectedly returned to the top. To avoid this visual jump, save
	// the contentY when the ListView becomes invisible, then restore that contentY when the view is
	// visible again and the contentHeight is fixed up.
	property real _previousContentY: NaN
	onVisibleChanged: {
		if (!visible) {
			_previousContentY = contentY - originY
		}
	}
	onContentHeightChanged: {
		// Restore the contentY. This may be triggered multiple times after the view reappears: if
		// _restoreContentY() moves the contentY beyond the last created delegate, more delegates
		// will be created, which will trigger another contentHeight change.
		if (visible && contentHeight > 0 && !isNaN(_previousContentY)) {
			// Delay the call so that originY has been fixed up by the time _restoreContent() occurs.
			Qt.callLater(_restoreContentY)
		}
	}
	function _restoreContentY() {
		if (!isNaN(_previousContentY)) {
			forceLayout()   // ensure geometry is correct before updating contentY
			contentY = _previousContentY + originY
		}
	}
	Connections {
		target: {
			// Find the root Page parent item
			let p = root.parent
			while (p && p.__is_venus_gui_page__ === undefined) {
				p = p.parent
			}
			return (!p || (p.__is_venus_gui_page__ === undefined)) ? null : p
		}
		function onIsCurrentPageChanged() {
			// Once the parent page is activated, stop auto-adjustments of contentY.
			if (target && target.isCurrentPage) {
				root._previousContentY = NaN
			}
		}
	}

}
