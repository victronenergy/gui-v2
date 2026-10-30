/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The root type of a plugin page.

	The app shows it inside a page of its own, which provides the status bar title (from 'title'),
	the back button, and the page size. Put a PluginGradientListView inside it to show a list of
	rows.
*/
FocusScope {
	// The page title, shown in the status bar.
	property string title

	focus: true
}
