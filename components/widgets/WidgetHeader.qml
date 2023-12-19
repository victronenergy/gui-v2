/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	property alias title: titleLabel.text
	property alias icon: icon

	implicitWidth: titleLabel.x + titleLabel.implicitWidth
	implicitHeight: icon.height

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: titleLabel.verticalCenter
		width: Theme.geometry_widgetHeader_icon_size
		height: Theme.geometry_widgetHeader_icon_size
		fillMode: Image.Pad
		color: titleLabel.color
	}

	Label {
		id: titleLabel

		anchors {
			left: icon.right
			leftMargin: Theme.geometry_widgetHeader_spacing
			right: parent.right
		}
		elide: Text.ElideRight
	}
}

