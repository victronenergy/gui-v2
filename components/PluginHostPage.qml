/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	The page that shows a plugin page, whose root is a PluginPage from Victron.GuiPlugins, not a
	Page. PageStack.pushPluginPage() creates this page, then creates the plugin page with this page
	as its parent, so plugin pages get the same title, back button and size handling as built-in
	pages, without depending on the Page type. The plugin page is destroyed with this page.
*/
Page {
	id: root

	// The plugin page. Its parent is this page.
	property Item pluginPage

	title: pluginPage?.title ?? ""

	onPluginPageChanged: {
		if (pluginPage) {
			pluginPage.anchors.fill = root
		}
	}
}
