/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property list<SwipeViewPage> pages
	readonly property int currentIndex: _currentIndex
	readonly property string currentTitle: pages[currentIndex].title ?? ""
	property alias backgroundColor: backgroundRect.color

	// External components should not write to these properties.
	property int _currentIndex

	function setCurrentPage(pageName) {
		for (let i = 0; i < pages.length; ++i) {
			const url = pages[i].url
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
		if (index < 0 || index >= pages.length) {
			console.warn("setCurrentIndex(): invalid index", index, "nav bar count is:", pages.length)
			return
		}
		_currentIndex = index
	}

	function getCurrentPage() {
		const url = pages[currentIndex].url
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
		x: Theme.geometry_navigationBar_horizontalMargin
		width: parent.width - 2*Theme.geometry_navigationBar_horizontalMargin
		height: parent.height

		Repeater {
			id: buttonRepeater

			model: root.pages.length
			delegate: NavButton {
				required property int index
				readonly property SwipeViewPage pageData: root.pages[index]

				anchors.verticalCenter: parent.verticalCenter
				height: Theme.geometry_navigationBar_button_height
				width: buttonRow.width / buttonRepeater.count
				text: pageData.title
				icon.source: pageData.iconSource
				checked: root.currentIndex === index
				backgroundColor: "transparent"
				focus: index === root.currentIndex
				onClicked: root._currentIndex = index

				KeyNavigation.right: buttonRepeater.itemAt((index + 1) % buttonRepeater.count)

				Loader {
					z: 1 // to get it on top of the IconLabel
					anchors {
						left: parent.horizontalCenter
						leftMargin: Theme.geometry_navigationBar_notifications_redDot_leftMargin
						top: parent.top
						topMargin: Theme.geometry_navigationBar_notifications_redDot_topMargin
					}
					sourceComponent: NotificationCounter {
						count: Global.notifications?.unacknowledgedCount ?? 0
					}
					active: pageData.url.endsWith("NotificationsPage.qml")
							&& (Global.notifications?.navBarNotificationCounterVisible ?? false)
				}
			}
		}
	}
}
