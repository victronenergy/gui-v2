/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

// This card compiles, but a pane cannot create it, as the pane does not set its required property.
PluginCard {
	required property string cardTitle

	title: cardTitle
}
