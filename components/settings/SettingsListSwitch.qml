/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias checked: switchItem.checked
	property alias secondaryText: secondaryLabel.text
	property bool updateOnClick: true
	property bool invertSourceValue

	property alias source: dataPoint.source
	readonly property alias dataPoint: dataPoint

	signal clicked()

	function _setChecked(c) {
		if (updateOnClick) {
			if (root.source.length > 0) {
				if (invertSourceValue) {
					dataPoint.setValue(c ? 0 : 1)
				} else {
					dataPoint.setValue(c ? 1 : 0)
				}
			} else {
				switchItem.checked = c
			}
		}
		clicked()
	}

	down: mouseArea.containsPress

	content.children: [
		Label {
			id: secondaryLabel
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color.font.secondary
			font.pixelSize: Theme.font.size.body2
		},
		Switch {
			id: switchItem
			checked: invertSourceValue ? dataPoint.value === 0 : dataPoint.value === 1
			onClicked: root._setChecked(!checked)
		}
	]

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root._setChecked(!switchItem.checked)
	}

	DataPoint {
		id: dataPoint
	}
}
