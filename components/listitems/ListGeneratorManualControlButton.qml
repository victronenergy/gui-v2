/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListItem {
	id: root

	required property string generatorUid
	property string gensetUid: ""
	property bool interactive: true

	contentItem: Item {
		// Use a fixed content height instead of sizing to the RowLayout height, so that the large
		// button height does not cause the expansion of the control height.
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: 0

		RowLayout {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			spacing: root.spacing

			Label {
				text: CommonWords.manual_control
				font: root.font
				elide: Text.ElideRight
				Layout.fillWidth: true
			}

			GeneratorManualControlButton {
				id: button

				enabled: root.interactive && button.defaultEnabled
				generatorUid: root.generatorUid
				gensetUid: root.gensetUid
				focus: true

				KeyNavigationHighlight.fill: root.background
				Keys.onSpacePressed: if (enabled) clicked()
			}
		}
	}
}
