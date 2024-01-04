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

	signal valueChanged(value: real)

	enabled: userHasWriteAccess && (dataItem.uid === "" || dataItem.isValid)

	content.anchors.rightMargin: 0
	content.children: [
		SettingsSlider {
			id: slider

			width: Theme.geometry_listItem_slider_width

			onValueChanged: function(value) {
				root.valueChanged(value)
			}
		}
	]
}
