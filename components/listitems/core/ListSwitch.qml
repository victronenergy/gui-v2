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
	readonly property bool defaultInteractive: (dataItem.uid === "" || dataItem.valid)
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
			root.toggleDataValue()
		}
		// If checkable, update 'checked' value so that onCheckedChanged signal is fired.
		// TODO: this only works for a touch on the switch, because Qt toggles the inner Switch
		// before its onClicked calls click(). The Space key, and any other call to click(), leave
		// the inner Switch unchanged, so a checkable switch does not toggle. This affects every
		// checkable ListSwitch (in ListChargeSchedule, PageSettingsGsm and
		// PageSettingsHub4Peakshaving) and PluginListSwitch. Fix them all together.
		if (checkable && !!_switchItem) {
			checked = _switchItem.checked
		}
		root.clicked()
	}

	function toggleDataValue() {
		if (root.dataItem.uid.length > 0) {
			// Note: this logic only holds so long as checkable is false so we can use
			// the current unmodified checked state at the point of onClicked.
			// (dataItem might not be valid until the first write so we can't simply use
			// the comparison of dataItem.value === valueFalse) and forget invertSourceValue).
			// Note that a malformed uid will result in it being empty when inspected.
			if (root.invertSourceValue) {
				root.dataItem.setValue(checked ? valueTrue : valueFalse)
			} else {
				root.dataItem.setValue(checked ? valueFalse : valueTrue)
			}
		}
	}

	// Remove padding, so that the internal Switch can extend its touch area to the right edge.
	rightPadding: rightInset

	interactive: defaultInteractive

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.implicitHeight + (captionLabel.visible ? captionLabel.implicitHeight : 0)

		TwoLabelLayout {
			id: labelLayout

			anchors {
				left: parent.left
				right: switchItem.left
				rightMargin: root.spacing
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: captionLabel.visible ? -captionLabel.height/2 : 0
			}
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			primaryLabel.color: root.interactive ? Theme.color_font_primary : Theme.color_font_disabled
			secondaryText: root.secondaryText
		}

		Switch {
			id: switchItem

			anchors {
				right: parent.right
				verticalCenter: labelLayout.verticalCenter
			}
			// Expand the switch touch area to make it easier to click.
			topInset: Theme.geometry_button_touch_verticalMargin
			bottomInset: Theme.geometry_button_touch_verticalMargin
			leftInset: root.spacing
			rightInset: root.horizontalContentPadding
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: leftInset
			rightPadding: rightInset

			checked: root.checked
			checkable: root.checkable && root.clickable
			focusPolicy: Qt.NoFocus
			enabled: root.clickable

			onClicked: root.click()
			Component.onCompleted: root._switchItem = switchItem
		}

		CaptionLabel {
			id: captionLabel

			anchors {
				top: labelLayout.bottom
				left: parent.left
				right: parent.right
				rightMargin: root.horizontalContentPadding
			}
			visible: text.length > 0
			topPadding: Theme.geometry_listItem_content_verticalSpacing
			text: root.caption
		}
	}

	background: ListSettingAccessCheckBackground {
		listItem: root
	}

	Keys.onSpacePressed: root.click()

	VeQuickItem {
		id: dataItem
	}
}
