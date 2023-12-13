/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	readonly property alias dataSeen: dataPoint.seen
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property alias checked: switchItem.checked
	property alias secondaryText: secondaryLabel.text
	property bool updateOnClick: true
	property bool invertSourceValue

	signal clicked()

	function _setChecked(c) {
		if (updateOnClick) {
			if (root.dataSource.length > 0) {
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
	enabled: userHasWriteAccess && (dataSource === "" || dataValid)

	contentChildren: [
		Label {
			id: secondaryLabel
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color.font.secondary
			font.pixelSize: Theme.font.size.body2
		},
		Switch {
			id: switchItem
			checked: invertSourceValue ? dataValue === 0 : dataValue === 1
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
