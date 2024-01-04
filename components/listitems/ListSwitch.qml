/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias checked: switchItem.checked
	property alias secondaryText: secondaryLabel.text
	property bool updateOnClick: true
	property bool invertSourceValue

	signal clicked()

	function _setChecked(c) {
		if (updateOnClick) {
			if (root.dataItem.uid.length > 0) {
				if (invertSourceValue) {
					dataItem.setValue(c ? 0 : 1)
				} else {
					dataItem.setValue(c ? 1 : 0)
				}
			} else {
				switchItem.checked = c
			}
		}
		clicked()
	}

	down: mouseArea.containsPress
	enabled: userHasWriteAccess && (dataItem.uid === "" || dataItem.isValid)

	content.children: [
		Label {
			id: secondaryLabel
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_size_body2
		},
		Switch {
			id: switchItem
			checked: invertSourceValue ? dataItem.value === 0 : dataItem.value === 1
			onClicked: root._setChecked(!checked)
		}
	]

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root._setChecked(!switchItem.checked)
	}

	VeQuickItem {
		id: dataItem
	}
}
