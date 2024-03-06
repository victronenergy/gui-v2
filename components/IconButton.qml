/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

PressArea {
	id: root

	property alias icon: icon

	width: icon.width
	height: icon.height

	CP.ColorImage {
		id: icon

		anchors.centerIn: parent
		fillMode: Image.PreserveAspectFit
	}
}
