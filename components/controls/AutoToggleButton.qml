/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseAutoToggleSwitch {
	id: root

	property int buttonWidth: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 2)) - Theme.geometry_autotoggle_button_spacing) / root.buttonCount

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
		//% "Function is set on Auto Mode"
		Global.showToastNotification(VenusOS.Notification_Info, qsTrId("autotoggleswitch_function_auto_mode_info"))
	}

	contentItem: FocusScope {
		focus: true

		Button {
			id: offButton

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_button_border_width
				top: parent.top
				topMargin: Theme.geometry_button_border_width
				bottom: parent.bottom
				bottomMargin: Theme.geometry_button_border_width
			}
			width: root.buttonWidth
			height: parent.height
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

			anchors {
				left: offButton.right
				leftMargin: Theme.geometry_button_border_width
				top: parent.top
				topMargin: Theme.geometry_button_border_width
				bottom: parent.bottom
				bottomMargin: Theme.geometry_button_border_width
			}
			width: root.buttonWidth
			height: parent.height
			radius: 0
			topRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			backgroundColor: !root.enabled ? Theme.color_background_disabled
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

			anchors {
				right: parent.right
				top: parent.top
				bottom: parent.bottom
			}
			width: root.buttonWidth
			height: parent.height

			radius: Theme.geometry_button_radius
			backgroundColor: !root.enabled ? Theme.color_background_disabled
				: root.autoChecked ? Theme.color_ok
				: Theme.color_darkOk
			borderWidth: Theme.geometry_button_border_width
			borderColor: root.enabled ? Theme.color_ok : Theme.color_font_disabled

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
