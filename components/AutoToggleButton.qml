/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Control {
	id: root

	property bool checked
	property bool autoChecked
	readonly property int buttonCount: 3

	signal onClicked()
	signal offClicked()
	signal autoClicked()

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	// background is the control's visual border
	background: Rectangle {
		radius: Theme.geometry_button_radius
		color: root.enabled ? Theme.color_ok : Theme.color_font_disabled
	}

	contentItem: Row {
		id: buttonRow

		anchors.fill: parent
		anchors.margins: Theme.geometry_button_border_width
		spacing: Theme.geometry_button_border_width

		Button {
			id: offButton

			width: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 1))) / root.buttonCount
			height: parent.height
			topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			backgroundColor: !root.enabled ? Theme.color_background_disabled
				: root.checked	? Theme.color_darkOk
				: Theme.color_button_off_background

			text: CommonWords.off

			checked: !root.checked
			onClicked: root.offClicked()

			Keys.onSpacePressed: root.offClicked()
			KeyNavigation.right: onButton
		}

		Button {
			id: onButton

			width: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 1))) / root.buttonCount
			height: parent.height
			backgroundColor: root.enabled === false ? Theme.color_background_disabled
				: root.checked ? Theme.color_ok
				: Theme.color_darkOk

			text: CommonWords.on

			checked: root.checked
			onClicked: root.onClicked()

			Keys.onSpacePressed: root.onClicked()
			Keys.onEnterPressed: focus = false
			focus: root.checked
			KeyNavigation.left: offButton
			KeyNavigation.right: autoButton
		}

		Button {
			id: autoButton

			width: (root.width - (Theme.geometry_button_border_width * (root.buttonCount + 1))) / root.buttonCount
			height: parent.height
			topRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			backgroundColor: !root.enabled ? Theme.color_background_disabled
				: root.autoChecked ? Theme.color_ok
				: Theme.color_darkOk

			text: CommonWords.auto

			checked: root.autoChecked
			onClicked: root.autoClicked()

			Keys.onSpacePressed: root.autoClicked()
			KeyNavigation.left: onButton
		}
	}

	Keys.onUpPressed: {}
	Keys.onDownPressed: {}
	Keys.onLeftPressed: {}
	Keys.onRightPressed: {}
	Keys.enabled: Global.keyNavigationEnabled
	KeyNavigationHighlight.active: activeFocus	
}
