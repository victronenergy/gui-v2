/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Explanatory text across the width of the list, without a row background.

	Key navigation skips it.
*/
PluginListRow {
	id: root

	property string text

	implicitWidth: inner.implicitWidth
	// The internal label stays as tall as its text when hidden, so the row collapses instead.
	implicitHeight: root.effectiveVisible ? inner.implicitHeight : 0
	focusPolicy: Qt.NoFocus

	PrimaryListLabel {
		id: inner

		text: root.text
		preferredVisible: root.effectiveVisible
	}
}
