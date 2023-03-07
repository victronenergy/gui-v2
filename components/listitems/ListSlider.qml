/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias dataSource: slider.dataSource
	readonly property alias dataValue: slider.dataValue
	readonly property alias dataValid: slider.dataValid
	function setDataValue(v) { dataPoint.setValue(v) }

	readonly property alias slider: slider

	signal valueChanged(value: real)

	enabled: userHasWriteAccess && (dataSource === "" || dataValid)

	content.anchors.rightMargin: 0
	content.children: [
		SettingsSlider {
			id: slider

			width: Theme.geometry.listItem.slider.width

			onValueChanged: function(value) {
				root.valueChanged(value)
			}
		}
	]
}
