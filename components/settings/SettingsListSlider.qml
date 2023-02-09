/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias source: slider.source
	readonly property alias dataPoint: slider.dataPoint
	readonly property alias slider: slider

	signal valueChanged(value: real)

	enabled: userHasWriteAccess && (source === "" || dataPoint.valid)

	content.anchors.rightMargin: 0
	content.children: [
		SettingsSlider {
			id: slider

			width: Theme.geometry.settingsListItem.slider.width

			onValueChanged: function(value) {
				root.valueChanged(value)
			}
		}
	]
}
