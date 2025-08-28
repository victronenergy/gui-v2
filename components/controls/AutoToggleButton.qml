/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseAutoToggleSwitch {
	id: root

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	// background is the control's visual border
	background: Rectangle {
		radius: Theme.geometry_button_radius
		color: root.enabled ? Theme.color_ok : Theme.color_font_disabled
	}

	function notification() {
		//% "Function is set on Auto Mode"
		Global.showToastNotification(VenusOS.Notification_Info, qsTrId("autotoggleswitch_function_auto_mode_info"))
	}

	contentItem: FocusScope {
		focus: true

		Button {
			id: offButton

			width: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 1))) / root.buttonCount
			height: parent.height
			anchors.left: parent.left
			anchors.leftMargin: Theme.geometry_button_border_width
			anchors.top: parent.top
			anchors.topMargin: Theme.geometry_button_border_width
			anchors.bottom: parent.bottom
			anchors.bottomMargin: Theme.geometry_button_border_width
			radius: 0
			topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			backgroundColor: !root.enabled ? Theme.color_background_disabled
				: root.onChecked ? Theme.color_darkOk
				: Theme.color_button_off_background

			text: CommonWords.off

			checked: !root.onChecked
			onClicked: root.autoChecked ? notification() : root.offClicked()
			focus: !root.onChecked

			Keys.onSpacePressed: root.autoChecked ? notification() : root.offClicked()
			KeyNavigation.right: onButton
		}

		Button {
			id: onButton

			width: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 1))) / root.buttonCount
			height: parent.height
			anchors.left: offButton.right
			anchors.leftMargin: Theme.geometry_button_border_width
			anchors.right: autoButton.left
			anchors.rightMargin: Theme.geometry_button_border_width
			anchors.top: parent.top
			anchors.topMargin: Theme.geometry_button_border_width
			anchors.bottom: parent.bottom
			anchors.bottomMargin: Theme.geometry_button_border_width
			radius: 0
			backgroundColor: root.enabled === false ? Theme.color_background_disabled
				: root.onChecked ? Theme.color_ok
				: Theme.color_darkOk

			text: CommonWords.on

			checked: root.onChecked
			onClicked: root.autoChecked ? notification() : root.onClicked()
			focus: root.onChecked

			Keys.onSpacePressed: root.autoChecked ? notification() : root.onClicked()
			KeyNavigation.right: autoButton
		}

		Button {
			id: autoButton

			width: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 1))) / root.buttonCount
			height: parent.height
			anchors.right: parent.right
			anchors.rightMargin: Theme.geometry_button_border_width
			anchors.top: parent.top
			anchors.topMargin: Theme.geometry_button_border_width
			anchors.bottom: parent.bottom
			anchors.bottomMargin: Theme.geometry_button_border_width
			radius: 0
			topRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			backgroundColor: !root.enabled ? Theme.color_background_disabled
				: root.autoChecked ? Theme.color_ok
				: Theme.color_darkOk

			text: CommonWords.auto

			checked: root.autoChecked
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
