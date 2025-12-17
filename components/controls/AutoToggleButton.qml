/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseAutoToggleSwitch {
	id: root

	property int buttonWidth: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 2)) - Theme.geometry_autotoggle_button_spacing) / root.buttonCount
	property var _notif

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	// background is the on/off buttons visual border
	background: Rectangle {
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: buttonWidth * 2 + Theme.geometry_button_border_width * 3
		radius: Theme.geometry_button_radius
		color: root.enabled ? Theme.color_ok : Theme.color_font_disabled
	}

	function notification() {
		if (ToastModel.count) {
			// The notification is already visible
			return
		}
		//% "Disable Auto mode first"
		Global.showToastNotification(VenusOS.Notification_Info, qsTrId("autotoggleswitch_disable_auto_mode_info"), 3000)
	}

	contentItem: FocusScope {
		focus: true

		ToggleButtonRow {
			width: (2 * root.buttonWidth) + (3 * Theme.geometry_button_border_width)
			height: parent.height
			on: root.onChecked
			KeyNavigation.right: autoButton

			onOnClicked: root.autoChecked ? root.notification() : root.onClicked()
			onOffClicked: root.autoChecked ? root.notification() : root.offClicked()
		}

		Button {
			id: autoButton

			anchors {
				right: parent.right
				top: parent.top
				bottom: parent.bottom
			}
			leftExtent: 0  // TODO: this shouldn't be necessary
			width: root.buttonWidth
			height: parent.height
			radius: Theme.geometry_button_radius
			flat: false
			borderWidth: Theme.geometry_button_border_width
			borderColor: root.enabled ? Theme.color_ok : Theme.color_font_disabled
			text: CommonWords.auto
			checked: root.autoChecked
			focus: true

			onClicked: root.autoClicked()

			Keys.onSpacePressed: root.autoClicked()
		}
	}

	Keys.onEscapePressed: focus = false
	Keys.onEnterPressed: focus = false
	Keys.onReturnPressed: focus = false
	Keys.onUpPressed: {}
	Keys.onDownPressed: {}
	Keys.onLeftPressed: {}
	Keys.onRightPressed: {}
}
