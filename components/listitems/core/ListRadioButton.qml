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
	property string secondaryText

	interactive: true

	content.children: [
		SecondaryListLabel {
			text: root.secondaryText
			width: Math.min(implicitWidth, root.maximumContentWidth - radioButton.width - Theme.geometry_listItem_content_spacing)
			visible: text.length > 0
		},
		RadioButton {
			id: radioButton

			checkable: false
			enabled: root.clickable
			onClicked: root.clicked()
		}
	]
}
