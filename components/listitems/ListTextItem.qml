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

	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			width: Math.min(implicitWidth, root.maximumContentWidth)
			visible: root.secondaryText.length > 0
			text: dataValue === undefined ? "" : dataValue
			font.pixelSize: Theme.font.size.body2
			color: Theme.color.listItem.secondaryText
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignRight
			verticalAlignment: Text.AlignVCenter
		}
	]

	DataPoint {
		id: dataPoint
	}
}
