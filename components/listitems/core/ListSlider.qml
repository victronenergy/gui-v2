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
		}
	]

	// clicked() signal is emitted when Key_Space is pressed.
	onClicked: slider.focus = true

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Escape:
		case Qt.Key_Return:
		case Qt.Key_Enter:
			if (slider.activeFocus) {
				slider.focus = false
				event.accepted = true
				return
			}
			break
		}
		event.accepted = false
	}
	Keys.enabled: Global.keyNavigationEnabled
}
