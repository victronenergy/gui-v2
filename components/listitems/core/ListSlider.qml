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

	enabled: userHasWriteAccess && (dataItem.uid === "" || dataItem.isValid)

	rightPadding: 0
	content.children: [
		SettingsSlider {
			id: slider

			width: Theme.geometry_listItem_slider_width
		}
	]
}
