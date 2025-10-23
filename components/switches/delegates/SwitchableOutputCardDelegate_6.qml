/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_Dropdown type.
*/
FocusScope {
	id: root

	required property SwitchableOutput switchableOutput

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
	focus: true
	KeyNavigationHighlight.active: activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			// Enter edit mode.
			if (!dropdown.activeFocus) {
				dropdown.focus = true
				event.accepted = true
			}
			break
		}
	}

	SwitchableOutputCardDelegateHeader {
		id: header

		anchors {
			top: parent.top
			topMargin: Theme.geometry_switches_header_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
		}
		switchableOutput: root.switchableOutput
	}

	ComboBox {
		id: dropdown

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		height: Theme.geometry_switchableoutput_control_height
		currentIndex: Math.floor(dropdownSync.dataItem.value || 0)

		onActivated: (index) => dropdownSync.writeValue(index)

		// Process key events in edit mode.
		Keys.onPressed: (event) => {
			switch (event.key) {
			case Qt.Key_Enter:
			case Qt.Key_Return:
				// Save highlighted index as the currentIndex, and exit edit mode.
				if (highlightedIndex >= 0 && highlightedIndex < count) {
					currentIndex = highlightedIndex
					activated(highlightedIndex)
				}
				focus = false
				event.accepted = true
				return
			case Qt.Key_Escape:
				// Exit edit mode. If the popup was open, it will be closed without changing the
				// current index.
				focus = false
				event.accepted = true
				return
			case Qt.Key_Left:
			case Qt.Key_Right:
				// When in edit mode, prevent left/right from moving focus to another item in
				// the grid view.
				event.accepted = true
				return
			default:
				break
			}
			event.accepted = false
		}

		SettingSync {
			id: dropdownSync

			function syncValueToDropdown() {
				if (dataItem.valid && dataItem.value >= 0 && dataItem.value < dropdown.count) {
					dropdown.currentIndex = Math.floor(dataItem.value)
				}
			}

			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/Dimming"
				onValueChanged: dropdownSync.syncValueToDropdown()
			}
			onTimeout: syncValueToDropdown()
		}

		VeQuickItem {
			uid: root.switchableOutput.uid + "/Settings/Labels"
			onValueChanged: {
				if (value === undefined) {
					dropdown.model = []
				} else {
					let items = []
					for (const text of value) {
						items.push({ text: text })
					}
					dropdown.model = items
				}
			}
		}
	}
}
