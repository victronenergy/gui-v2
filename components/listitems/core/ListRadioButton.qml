/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

ListItem {
	id: root

	property alias checked: radioButton.checked
	property alias radioButton: radioButton

	interactive: true

	content.children: [
		RadioButton {
			id: radioButton

			checkable: false
			enabled: root.clickable
			onClicked: root.clicked()
		}
	]
}
