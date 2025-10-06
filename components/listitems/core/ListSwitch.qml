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

	// Override ListItem right padding to give Switch a larger touch area for users
	rightPadding: 0

	interactive: (dataItem.uid === "" || dataItem.valid)
	pressAreaEnabled: false

	content.spacing: 0
	content.children: [
		Label {
			id: secondaryLabel
			rightPadding: 0
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_size_body2
			width: Math.min(implicitWidth, root.maximumContentWidth - switchItem.width - Theme.geometry_listItem_content_spacing)
			wrapMode: Text.Wrap
		},
		Switch {
			id: switchItem

			topInset: Theme.geometry_listItem_content_verticalMargin
			bottomInset: Theme.geometry_listItem_content_verticalMargin
			leftInset: Theme.geometry_listItem_content_spacing
			rightInset: root.flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin
			checked: invertSourceValue ? dataItem.value === valueFalse : dataItem.value === valueTrue
			checkable: false
			focusPolicy: Qt.NoFocus

			onClicked: {
				if (!root.checkWriteAccessLevel() || !root.clickable) {
					return
				}
				if (root.updateDataOnClick) {
					if (root.dataItem.uid.length > 0) {
						// Note: this logic only holds so long as checkable is false so we can use
						// the current unmodified checked state at the point of onClicked.
						// (dataItem might not be valid until the first write so we can't simply use
						// the comparison of dataItem.value === valueFalse) and forget invertSourceValue).
						// Note that an malformed uid will result in it being empty when inspected.
						if (root.invertSourceValue) {
							root.dataItem.setValue(checked ? valueTrue : valueFalse)
						} else {
							root.dataItem.setValue(checked ? valueFalse : valueTrue)
						}
					}
				}
				root.clicked()
			}
		}
	]

	VeQuickItem {
		id: dataItem
	}
}
