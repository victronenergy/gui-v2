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

	contentItem: RowLayout {
		Label {
			text: CommonWords.manual_control
			font: root.font
			Layout.fillWidth: true
		}

		GeneratorManualControlButton {
			id: button

			enabled: root.interactive && button.defaultEnabled
			generatorUid: root.generatorUid
			gensetUid: root.gensetUid
		}
	}
}
