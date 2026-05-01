/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list setting item with a toggle switch on the right.

	The toggle switch is triggered by:
	- clicking on the switch (but not if you click anywhere else in the list item)
	- the space key, when focused

	There are two ways to control the switch value:

	1. By setting `dataItem.uid` to a path that will be automatically set to valueTrue/valueFalse
	when the switch is toggled. The 'checked' value will reflect whether the backend value indicates
	the value is "on".

	2. By setting checkable=true. This means the switch can be directly toggled by the user; when
	the switch is clicked, 'checked' is updated to reflect the toggle state.
	NOTE: this means the 'checked' binding will be overwritten when clicked!! It can still be set
	to assign the initial checked state, but after a user interaction, the binding is gone.
*/
ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property bool checked: invertSourceValue ? dataItem.value === valueFalse : dataItem.value === valueTrue
	property bool checkable
	property string secondaryText
	property bool updateDataOnClick: true
	property bool invertSourceValue

	property var valueTrue: 1
	property var valueFalse: 0

	property Switch _switchItem

	signal clicked

	function click() {
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
		// If checkable, update 'checked' value so that onCheckedChanged signal is fired.
		if (checkable && !!_switchItem) {
			checked = _switchItem.checked
		}
		root.clicked()
	}

	// Remove padding around the edges, so that the internal Switch can expand its touch area.
	rightPadding: rightInset
	topPadding: 0
	bottomPadding: 0

	interactive: (dataItem.uid === "" || dataItem.valid)

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.height

		ThreeLabelLayout {
			id: labelLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - switchItem.width - root.spacing
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			captionText: root.caption
			stretchSecondaryText: true

			// Since padding is cleared in the root item, add it back again here.
			topPadding: Theme.geometry_listItem_content_verticalMargin
			bottomPadding: Theme.geometry_listItem_content_verticalMargin
		}

		Switch {
			id: switchItem

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}

			// Expand the switch touch area to make it easier to click.
			topInset: Theme.geometry_listItem_content_verticalMargin
			bottomInset: Theme.geometry_listItem_content_verticalMargin
			leftInset: root.spacing
			rightInset: root.horizontalContentPadding
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: leftInset
			rightPadding: rightInset

			checked: root.checked
			checkable: root.checkable && root.clickable
			focusPolicy: Qt.NoFocus
			showEnabled: root.clickable

			onClicked: root.click()
			Component.onCompleted: root._switchItem = switchItem
		}
	}

	Keys.onSpacePressed: root.click()

	VeQuickItem {
		id: dataItem
	}
}
