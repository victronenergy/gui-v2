/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseAutoToggleSwitch {
	id: root

	property real defaultBackgroundWidth
	property real defaultBackgroundHeight

	property var _notif

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
			on: root.onChecked
			KeyNavigation.right: autoButton

			// Expand clickable area left (to delegate edge), right (halfway to auto button), and
			// vertically. Paddings don't need adjustment as that is done internally by the control.
			defaultBackgroundWidth: root.defaultBackgroundWidth - autoButton.defaultBackgroundWidth - Theme.geometry_iochannel_spacing
			defaultBackgroundHeight: Theme.geometry_iochannel_control_height
			topInset: Theme.geometry_button_touch_verticalMargin
			bottomInset: Theme.geometry_button_touch_verticalMargin
			leftInset: Theme.geometry_controlCard_button_margins
			rightInset: Theme.geometry_iochannel_spacing / 2

			onOnClicked: root.autoChecked ? root.notification() : root.onClicked()
			onOffClicked: root.autoChecked ? root.notification() : root.offClicked()
		}

		Button {
			id: autoButton

			anchors.right: parent.right
			radius: Theme.geometry_button_radius
			flat: false
			borderWidth: Theme.geometry_button_border_width
			borderColor: root.enabled ? Theme.color_ok : Theme.color_font_disabled
			text: CommonWords.auto
			checked: root.autoChecked
			focus: true

			// Expand clickable area left (halfway to toggle buttons), right (to delegate edge), and
			// vertically. Paddings don't need adjustment as that is done internally by the control.
			defaultBackgroundWidth: (root.defaultBackgroundWidth - Theme.geometry_iochannel_spacing) / root.buttonCount
			defaultBackgroundHeight: root.defaultBackgroundHeight
			topInset: Theme.geometry_button_touch_verticalMargin
			bottomInset: Theme.geometry_button_touch_verticalMargin
			leftInset: Theme.geometry_iochannel_spacing / 2
			rightInset: Theme.geometry_controlCard_button_margins
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: leftInset
			rightPadding: rightInset

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
