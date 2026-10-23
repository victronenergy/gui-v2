/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A row with an arrow, which opens a subpage when clicked.

	Set pageUrl to the subpage's file. Give it as Qt.resolvedUrl("SubPage.qml"), so that it is
	found next to the plugin's own files. The subpage's root is a PluginPage. Its title is the
	row's text, unless pageProperties gives another one. A subpage must be a file of its own: a
	page written inline, as a Component, cannot be opened.

	Alternatively, leave pageUrl empty and handle onClicked.
*/
PluginListRow {
	id: root

	property string text
	property string caption
	property string secondaryText

	// The subpage to open when the row is clicked.
	property url pageUrl
	// Properties to set on the subpage when it is created, such as { title: "Other title" }.
	property var pageProperties: ({})

	// True if the row can be clicked. If false, the arrow is hidden.
	property bool interactive: true

	signal clicked

	// Clicks the row, as a touch on it does.
	function click() {
		inner.click()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListNavigation {
		id: inner

		text: root.text
		caption: root.caption
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
			Global.pageManager.pushPluginPage(url, Object.assign({ title: root.text }, root.pageProperties))
		}
	}
}
