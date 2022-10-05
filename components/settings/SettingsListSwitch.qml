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

	property alias source: dataPoint.source
	property alias dataPoint: dataPoint

	signal clicked()

	function _setChecked(c) {
		if (updateOnClick) {
			if (root.source.length > 0) {
				dataPoint.setValue(c ? 1 : 0)  // set dbus value instead of breaking Switch "checked" binding
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
			checked: dataPoint.value === 1
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
