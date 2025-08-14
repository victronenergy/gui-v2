/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	property int fontPixelSize: Theme.font_size_body3
	property bool checked
	property bool autoChecked

	signal onClicked()
	signal offClicked()
	signal autoClicked()

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	T.Control {
		anchors.fill: parent

		// background is the control's visual border
		background: Rectangle {
			anchors.fill: parent
			radius: Theme.geometry_button_radius
			color: root.enabled ? Theme.color_ok : Theme.color_font_disabled
		}

		contentItem: Row {
			id: buttonRow

			anchors.fill: parent
			anchors.margins: Theme.geometry_button_border_width
			spacing: Theme.geometry_button_border_width

			InternalButton {
				id: offButton

				onPressed: {
					if (!root.autoChecked) {
						root.offClicked()
					}
				}

				topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
				bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width

				color: !root.enabled ? Theme.color_background_disabled
					: root.checked	? Theme.color_darkOk
					: Theme.color_button_off_background
				text: CommonWords.off
				textColor: !root.enabled ? Theme.color_font_disabled
					: root.checked ? Theme.color_font_primary
					: Theme.color_button_down_text

				Keys.onSpacePressed: {
					if (!root.autoChecked) {
						root.offClicked()
					}
				}
				focus: !root.checked
				KeyNavigation.right: onButton
			}

			InternalButton {
				id: onButton

				onPressed: {
					if (!root.autoChecked) {
						root.onClicked()
					}
				}

				color: root.enabled === false ? Theme.color_background_disabled
					: root.checked ? Theme.color_ok
					: Theme.color_darkOk
				text: CommonWords.on
				textColor: !root.enabled ? Theme.color_font_disabled
					: root.checked ? Theme.color_button_down_text
					: Theme.color_font_primary

				Keys.onSpacePressed: {
					if (!root.autoChecked) {
						root.onClicked()
					}
				}
				focus: root.checked
				KeyNavigation.left: offButton
				KeyNavigation.right: autoButton
			}

			InternalButton {
				id: autoButton

				onPressed: root.autoClicked()

				topRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
				bottomRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width

				color: !root.enabled ? Theme.color_background_disabled
					: root.autoChecked ? Theme.color_ok
					: Theme.color_darkOk
				text: CommonWords.auto
				textColor: !root.enabled ? Theme.color_font_disabled
					: root.autoChecked ? Theme.color_button_down_text
					: Theme.color_font_primary

				Keys.onSpacePressed: root.autoClicked()
				KeyNavigation.left: onButton
			}
		}
	}

	component InternalButton : Rectangle {
		property alias text: buttonLabel.text
		property alias textColor: buttonLabel.color

		signal pressed

		width: (root.width - (Theme.geometry_button_border_width * 4)) / 3
		height: parent.height

		Label {
			id: buttonLabel
			anchors.centerIn: parent
			font.pixelSize: root.fontPixelSize
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			x: Theme.geometry_tabBar_horizontalMargin
			width: parent.width - 2*x
			elide: Text.ElideRight
		}

		MouseArea {
			anchors.fill: parent
			onPressed: parent.pressed()
		}

		Keys.enabled: Global.keyNavigationEnabled
		KeyNavigationHighlight.active: activeFocus
	}

	Keys.onUpPressed: {}
	Keys.onDownPressed: {}
	Keys.onLeftPressed: {}
	Keys.onRightPressed: {}
	Keys.enabled: Global.keyNavigationEnabled
	KeyNavigationHighlight.active: activeFocus
}
