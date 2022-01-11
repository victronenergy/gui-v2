/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlValue {
	id: root

	property alias button: button

	signal clicked()

	implicitHeight: Theme.geometry.controlCard.mediumItem.height

	contentRow.children: RadioButton {
		id: button

		anchors.verticalCenter: parent.verticalCenter
		width: implicitIndicatorWidth   // cannot be zero, else button not clickable
		font.pixelSize: Theme.font.size.m

		onClicked: root.clicked()
	}
}
