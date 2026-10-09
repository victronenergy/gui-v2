/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Layouts
import Victron.VenusOS

FocusScope {
	id: root

	required property list<SwipeViewPage> pages
	property alias backgroundColor: backgroundRect.color
	property Component moreButton
	property bool moreDialogVisible

	readonly property int currentIndex: _currentIndex
	readonly property string currentTitle: pages[currentIndex]?.title ?? ""
	readonly property real buttonWidth: buttonRow.width / visiblePageCount
	readonly property int visiblePageCount: Math.min(pages.length,
	buttonRow.width / Theme.geometry_navigationBar_button_minimumWidth)

	// Intermediate property written to the Repeater. Do not bind Repeater.model;
	// setModel while nested AsynchronousIfNested delegates are Loading will assert.
	readonly property int _buttonModelCount: root.visiblePageCount < root.pages.length
			? Math.max(0, root.visiblePageCount - 1)
			: root.visiblePageCount
	on_ButtonModelCountChanged: root._applyButtonModel()
	Component.onCompleted: root._applyButtonModel()

	function _applyButtonModel() {
		if (!buttonRepeater) {
			return
		}
		if (buttonRepeater.model === root._buttonModelCount) {
			return
		}
		FastUtils.drainIncubators(buttonRepeater)
		buttonRepeater.model = root._buttonModelCount
	}

	// Internal reference to the currently selected index.
	property int _currentIndex

	signal buttonClicked(pageIndex : int)

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
		if (index >= pages.length) { // index < 0 is ok, if clearing the current index
			console.warn("setCurrentIndex(): invalid index", index, "nav bar count is:", pages.length)
			return
		}
		_currentIndex = index
	}

	function getCurrentPage() {
		const url = pages[currentIndex]?.url ?? ""
		return url.substring(url.lastIndexOf("/") + 1)
	}

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_navigationBar_height

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

			model: 0
			delegate: NavButton {
				required property int index
				readonly property SwipeViewPage page: root.pages[index]

				anchors.verticalCenter: parent.verticalCenter
				width: root.buttonWidth
				text: page.title
				icon.source: page.iconSource
				checked: root.currentIndex === index && !root.moreDialogVisible
				focus: checked

				onClicked: {
					root._currentIndex = index
					root.buttonClicked(index)
				}

				KeyNavigation.right: index >= 0 && index < buttonRepeater.count - 1
						? buttonRepeater.itemAt(index + 1)
						: moreButtonLoader

				Loader {
					z: 1 // to get it on top of the IconLabel
					anchors {
						left: parent.horizontalCenter
						topMargin: Theme.geometry_navigationBar_notifications_redDot_margin
					}
					active: (Global.notifications?.navBarNotificationCounterVisible ?? false)
							&& page.url.endsWith("NotificationsPage.qml")
					sourceComponent: NotificationCounter {
						count: Global.notifications?.unacknowledgedCount ?? 0
					}
				}
			}
		}

		Loader {
			id: moreButtonLoader
			anchors.verticalCenter: parent.verticalCenter
			sourceComponent: root.moreButton
			enabled: status === Loader.Ready
		}
	}
}
