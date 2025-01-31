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

	enabled: userHasWriteAccess

	content.children: [
		RadioButton {
			id: radioButton

			checkable: false
			onClicked: root.clicked()
		}
	]
}
