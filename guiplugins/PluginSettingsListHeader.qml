/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A heading above a group of list items.

	Key navigation skips it.
*/
PluginListItem {
	id: root

	property string text

	implicitWidth: inner.implicitWidth
	// The internal heading does not collapse when hidden, so the list item collapses instead.
	implicitHeight: root.effectiveVisible ? inner.implicitHeight : 0
	focusPolicy: Qt.NoFocus

	SettingsListHeader {
		id: inner

		// Fill the list item, so that a long heading wraps.
		width: root.width
		text: root.text
		preferredVisible: root.effectiveVisible
	}
}
