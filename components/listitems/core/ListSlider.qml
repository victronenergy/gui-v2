/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: slider.dataItem
	readonly property alias slider: slider

	interactive: (dataItem.uid === "" || dataItem.valid)

	rightPadding: 0
	content.children: [
		SettingsSlider {
			id: slider

			enabled: root.clickable
			width: Theme.geometry_listItem_slider_width
			focus: true // receive key events
		}
	]
}
