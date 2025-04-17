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
	property alias checkable: switchItem.checkable
	property alias secondaryText: secondaryLabel.text
	property bool updateDataOnClick: true
	property bool invertSourceValue

	property int valueTrue: 1
	property int valueFalse: 0

	property bool _updatingValue

	// Emitted when a click results in a change in the data value, or when checkable=true and the
	// switch is toggled directly.
	signal toggled

	interactive: (dataItem.uid === "" || dataItem.valid)

	content.children: [
		Label {
			id: secondaryLabel
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_size_body2
			width: Math.min(implicitWidth, root.maximumContentWidth - switchItem.width - root.content.spacing)
			wrapMode: Text.Wrap
		},
		Switch {
			id: switchItem

			enabled: root.clickable
			checked: invertSourceValue ? dataItem.value === valueFalse : dataItem.value === valueTrue
			checkable: false
			onClicked: root.clicked()
			onToggled: root.toggled()
		}
	]

	onClicked: {
		if (switchItem.enabled && updateDataOnClick) {
			if (root.dataItem.uid.length > 0) {
				// Note: this logic only holds so long as checkable is false so we can use
				// the current unmodified checked state at the point of onClicked.
				// (dataItem might not be valid until the first write so we can't simply use
				// the comparison of dataItem.value === valueFalse) and forget invertSourceValue).
				// Note that an malformed uid will result in it being empty when inspected.
				root._updatingValue = true
				if (invertSourceValue) {
					dataItem.setValue(switchItem.checked ? valueTrue : valueFalse)
				} else {
					dataItem.setValue(switchItem.checked ? valueFalse : valueTrue)
				}
			}
		}
	}

	VeQuickItem {
		id: dataItem
		onValueChanged: {
			if (root._updatingValue) {
				root.toggled()
			}
			root._updatingValue = false
		}
	}
}
