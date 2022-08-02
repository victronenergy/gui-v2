/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlValue {
	id: root

	property alias button: button

	signal clicked()

	implicitHeight: Theme.geometry.controlCard.largeItem.height

	contentRow.children: Button {
		id: button

		anchors.verticalCenter: parent.verticalCenter
		height: Theme.geometry.buttonControlValue.height
		width: Theme.geometry.buttonControlValue.width

		flat: !enabled
		border.color: Theme.color.ok
		font.pixelSize: Theme.font.size.body2

		onClicked: root.clicked()
	}
}
