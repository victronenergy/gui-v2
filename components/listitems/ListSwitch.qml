/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias checked: switchItem.checked
	property alias secondaryText: secondaryLabel.text
	property bool updateOnClick: true
	property bool invertSourceValue

	property int valueTrue: 1
	property int valueFalse: 0

	signal clicked()

	function _setChecked(c) {
		if (updateOnClick) {
			if (root.dataItem.uid.length > 0) {
				if (invertSourceValue) {
					dataItem.setValue(c ? valueFalse : valueTrue)
				} else {
					dataItem.setValue(c ? valueTrue : valueFalse)
				}
			} else {
				switchItem.checked = c
			}
		}
		clicked()
	}

	down: pressArea.containsPress
	enabled: userHasWriteAccess && (dataItem.uid === "" || dataItem.isValid)

	content.children: [
		Label {
			id: secondaryLabel
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_size_body2
			width: Math.min(implicitWidth, root.maximumContentWidth - switchItem.width - parent.spacing)
			wrapMode: Text.Wrap
		},
		Switch {
			id: switchItem
			checked: invertSourceValue ? dataItem.value === valueFalse : dataItem.value === valueTrue
			checkable: false
			focus: true
			onClicked: root._setChecked(!checked)
		}
	]

	ListPressArea {
		id: pressArea

		radius: backgroundRect.radius
		anchors {
			fill: parent
			bottomMargin: root.spacing
		}

		onClicked: root._setChecked(!switchItem.checked)
	}

	VeQuickItem {
		id: dataItem
	}
}
