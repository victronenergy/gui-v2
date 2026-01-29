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

	// Layout has 3 columns, 2 rows. The caption spans across all columns.
	// | Primary label | Secondary label | Radio button |
	// | Caption                                        |
	contentItem: GridLayout {
		columns: 2
		columnSpacing: root.spacing

		Label {
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		RadioButton {
			id: radioButton

			checkable: false
			checked: root.checked
			enabled: root.clickable
			focusPolicy: Qt.NoFocus
			text: root.secondaryText
			textColor: Theme.color_font_secondary

			onClicked: root.click()

			Layout.fillWidth: true
			Layout.alignment: Qt.AlignRight
		}

		Label {
			text: root.caption
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.columnSpan: 2
			Layout.maximumWidth: root.availableWidth
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
