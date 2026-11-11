/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list item with an arrow, which opens a subpage when clicked.

	Set pageUrl to the subpage's file. Give it as Qt.resolvedUrl("SubPage.qml"), so that it is
	found next to the plugin's own files. The subpage's base type is a PluginPage. The host shows the
	subpage's title, or this list item's text while that title is empty. pageProperties.title, if
	set, replaces the page's title binding.
	A subpage must be a file of its own: a page written inline, as a Component, cannot be opened.

	Alternatively, leave pageUrl empty and handle onClicked.
*/
PluginListItem {
	id: root

	property string text
	property string caption
	property string secondaryText

	// The subpage to open when the list item is clicked.
	property url pageUrl
	// Properties to set on the subpage when it is created, such as { title: "Other title" }.
	property var pageProperties: ({})

	// True if the list item can be clicked. If false, the arrow is hidden.
	property bool interactive: true

	signal clicked

	// Clicks the list item, as a touch on it does.
	function click() {
		inner.click()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListNavigation {
		id: inner

		flat: root.flat
		text: root.text
		secondaryText: root.secondaryText
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		interactive: root.interactive

		onClicked: {
			root.clicked()
			const url = root.pageUrl.toString()
			if (url.length === 0) {
				return
			}
			if (url.indexOf(":") < 0) {
				console.warn("PluginListNavigation: pageUrl is relative, use Qt.resolvedUrl():", url)
				return
			}
			// Pass this list item's text as the default title. Do not write the page's title:
			// that replaces its title binding. pageProperties.title, if set, does that on purpose.
			const properties = Object.assign({}, root.pageProperties)
			Global.pageManager.pushPluginPage(url, properties, root.text)
		}

		// ListNavigation has no caption. Draw it under the content.
		ListCaptionAttachment {
			caption: root.caption
		}
	}
}
