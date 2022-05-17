/*
** Copyright (C) 2022 Victron Energy B.V.
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
		width: Theme.geometry.widgetHeader.icon.size
		height: Theme.geometry.widgetHeader.icon.size
		fillMode: Image.Pad
		color: titleLabel.color
	}

	Label {
		id: titleLabel

		anchors {
			left: icon.right
			leftMargin: Theme.geometry.widgetHeader.spacing
			right: parent.right
		}
		elide: Text.ElideRight
	}
}

