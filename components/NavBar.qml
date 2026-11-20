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
	property bool modified

	readonly property int currentIndex: _currentIndex
	readonly property string currentTitle: pages[currentIndex]?.title ?? ""
	readonly property real buttonWidth: buttonRow.width / visiblePageCount
	readonly property int visiblePageCount: Math.min(pages.length,
			buttonRow.width / Theme.geometry_navigationBar_button_minimumWidth)

	// Internal references.
	property int _currentIndex
	// Full URL of the page to restore. A file name would not tell two plugins apart.
	property string _currentPageUrl

	signal buttonClicked(pageIndex : int)

	function _pageMatches(pageName, url) {
		const pageUrl = url ?? ""
		if (!pageName || pageUrl.length === 0) {
			return false
		}
		if (pageName.indexOf("/") >= 0) {
			return pageUrl === pageName
		}
		return pageUrl.endsWith("/" + pageName)
	}

	// A file name selects the first page with that name. A full URL selects
	// that page, so two plugins with the same file name stay distinct.
	function setCurrentPage(pageName) {
		for (let i = 0; i < pages.length; ++i) {
			if (_pageMatches(pageName, pages[i].url)) {
				return setCurrentIndex(i)
			}
		}
		console.warn("setCurrentPage(): cannot find page", pageName)
		return false
	}

	function hasPage(pageName) {
		for (let i = 0; i < pages.length; ++i) {
			if (_pageMatches(pageName, pages[i].url)) {
				return true
			}
		}
		return false
	}

	function setCurrentIndex(index) {
		if (index === _currentIndex) {
			_currentPageUrl = getCurrentPageUrl()
			return true
		}
		if (index >= pages.length) { // index < 0 is ok, if clearing the current index
			console.warn("setCurrentIndex(): invalid index", index, "nav bar count is:", pages.length)
			return false
		}
		modified = true
		_currentIndex = index
		_currentPageUrl = getCurrentPageUrl()
		return true
	}

	function getCurrentPage() {
		const url = getCurrentPageUrl()
		return url.substring(url.lastIndexOf("/") + 1)
	}

	function getCurrentPageUrl() {
		return pages[currentIndex]?.url ?? ""
	}

	function restoreCurrentPage() {
		if (_currentPageUrl.length > 0) {
			return setCurrentPage(_currentPageUrl)
		}
		return false
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

			model: root.visiblePageCount < root.pages.length // If we cannot show all available pages...
				   ? root.visiblePageCount - 1  // -1 to make space for the "More" button
				   : root.visiblePageCount // show all available pages
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
					root.setCurrentIndex(index)
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
					// The built-in page only. endsWith("NotificationsPage.qml") also matches a plugin page.
					active: Services.notifications.navBarNotificationCounterVisible
							&& page.url === "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml"
					sourceComponent: NotificationCounter {
						count: Services.notifications.unacknowledgedCount
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
