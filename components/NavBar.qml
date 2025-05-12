/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	required property var model
	readonly property int currentIndex: _currentIndex
	readonly property string activeButtonText: model ? model.get(currentIndex).navButtonText : ""
	property alias backgroundColor: backgroundRect.color

	// External components should not write to these properties.
	property int _currentIndex

	function setCurrentPage(pageName) {
		for (let i = 0; i < model.count; ++i) {
			const url = model.get(i).url
			if (url.endsWith("/" + pageName)) {
				_currentIndex = i
				return true
			}
		}
		console.warn("setCurrentPage(): cannot find page", pageName)
		return false
	}

	function setCurrentIndex(index) {
		if (index === _currentIndex) {
			return
		}
		if (index < 0 || index >= model.count) {
			console.log("setCurrentIndex(): invalid index", index, "nav bar count is:", model.count)
			return
		}
		_currentIndex = index
	}

	function getCurrentPage() {
		const url = model.get(currentIndex).url
		return url.substring(url.lastIndexOf("/") + 1)
	}

	width: parent.width
	height: Theme.geometry_navigationBar_height

	// Add an opaque background so that page disappears behind nav bar when scrolled
	Rectangle {
		id: backgroundRect
		anchors.fill: parent
	}

	Row {
		id: buttonRow
		x: Theme.geometry_page_content_horizontalMargin
		width: parent.width - 2*Theme.geometry_page_content_horizontalMargin
		height: parent.height

		Repeater {
			id: buttonRepeater

			// The model for this repeater is a 'visual' model (i.e. an ObjectModel), and is used as the model for the SwipeView in MainView.qml.
			// If you use an ObjectModel as the model for more than 1 view, the Items in the ObjectModel only appear in 1 of the views.
			// To work around this shortcoming, we have to use 'root.model.count' instead of 'root.model' as the Repeater model,
			// and other awkward syntax to access model properties.
			model: root.model ? root.model.count : null
			delegate: NavButton {
				id: navButton

				readonly property var _modelData: root.model.get(index)
				anchors.verticalCenter: parent.verticalCenter
				height: Theme.geometry_navigationBar_button_height
				width: buttonRow.width / buttonRepeater.count
				text: _modelData.navButtonText
				icon.source: _modelData.navButtonIcon
				checked: root.currentIndex === model.index
				backgroundColor: "transparent"
				focus: model.index === root.currentIndex
				onClicked: root._currentIndex = model.index

				KeyNavigation.right: buttonRepeater.itemAt((model.index + 1) % buttonRepeater.count)

				Loader {
					z: 1 // to get it on top of the IconLabel
					anchors {
						left: parent.horizontalCenter
						leftMargin: Theme.geometry_navigationBar_notifications_redDot_leftMargin
						top: parent.top
						topMargin: Theme.geometry_navigationBar_notifications_redDot_topMargin
					}
					sourceComponent: NotificationCounter {
						count: Global.notifications?.activeOrUnAcknowledgedCount ?? 0
					}
					active: navButton._modelData.url.endsWith("NotificationsPage.qml")
							&& (Global.notifications?.navBarNotificationCounterVisible ?? false)
				}
			}
		}
	}
}
