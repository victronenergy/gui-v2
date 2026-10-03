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

	contentItem: GridLayout {
		columns: 2
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		TwoLabelLayout {
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText

			Layout.fillWidth: true
		}

		RadioButton {
			checkable: false
			checked: root.checked
			enabled: root.clickable
			focusPolicy: Qt.NoFocus

			onClicked: root.click()
		}

		CaptionLabel {
			visible: text.length > 0
			text: root.caption

			Layout.columnSpan: 2
			Layout.fillWidth: true
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
