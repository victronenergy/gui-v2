/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A push button with text and an optional icon.

	iconSource is a single-color image, such as one of the PluginIcons: the button tints it with the
	text color. A touch on the button, or the Space key when it has the key navigation focus, emits
	clicked(). Set enabled to false to grey the button out and ignore clicks.
*/
Item {
	id: root

	property string text
	property url iconSource

	signal clicked

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight
	focusPolicy: Qt.TabFocus
	KeyNavigationHighlight.active: activeFocus
	Keys.enabled: Global.keyNavigationEnabled
	Keys.onSpacePressed: root.clicked()

	Button {
		id: inner

		anchors.fill: parent
		text: root.text
		icon.source: root.iconSource
		flat: false
		focusPolicy: Qt.NoFocus
		onClicked: root.clicked()
	}
}
