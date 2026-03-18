/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
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

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - radioButton.width + root.spacing
			primaryText: root.text
			primaryFont: root.font
			primaryTextFormat: root.textFormat
			secondaryText: root.secondaryText
			captionText: root.caption
			stretchSecondaryText: true
		}

		RadioButton {
			id: radioButton

			anchors.right: parent.right
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
