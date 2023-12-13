/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias dataSource: slider.dataSource
	readonly property alias dataValue: slider.dataValue
	readonly property alias dataValid: slider.dataValid
	readonly property alias dataSeen: slider.dataSeen
	property alias dataInvalidate: slider.dataInvalidate
	function setDataValue(v) { slider.setDataValue(v) }

	readonly property alias slider: slider

	signal valueChanged(value: real)

	enabled: userHasWriteAccess && (dataSource === "" || dataValid)

	content.anchors.rightMargin: 0
	contentChildren: [
		SettingsSlider {
			id: slider

			width: Theme.geometry.listItem.slider.width

			onValueChanged: function(value) {
				root.valueChanged(value)
			}
		}
	]
}
