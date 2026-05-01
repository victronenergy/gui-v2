/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSetting {
	id: root

	property bool checked
	property string secondaryText

	signal clicked()

	function click() {
		if (interactive && checkWriteAccessLevel()) {
			clicked()
		}
	}

	interactive: true

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.height

		ThreeLabelLayout {
			id: labelLayout

			anchors {
				left: parent.left
				right: radioButton.left
				rightMargin: root.spacing
				verticalCenter: parent.verticalCenter
			}
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			captionText: root.caption
			stretchSecondaryText: true
		}

		RadioButton {
			id: radioButton

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			checkable: false
			checked: root.checked
			enabled: root.clickable
			focusPolicy: Qt.NoFocus

			onClicked: root.click()
		}
	}

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive
			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: root.click()
}
