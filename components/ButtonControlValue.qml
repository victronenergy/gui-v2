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
		height: Theme.geometry.essCard.minimumSocButton.height
		width: Theme.geometry.essCard.minimumSocButton.width

		flat: !enabled
		border.color: Theme.color.ok
		font.pixelSize: Theme.font.size.m

		onClicked: root.clicked()
	}
}
