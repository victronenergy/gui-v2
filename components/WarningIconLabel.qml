/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	required property string text
	property color color: Theme.color_warning
	property alias font: label.font

	implicitWidth: label.implicitWidth
	implicitHeight: Math.max(icon.implicitHeight, label.implicitHeight)

	Label {
		id: label

		x: (parent.width / 2) - (width / 2)
		topPadding: (icon.height / 2) - (fontMetrics.height / 2)
		leftPadding: icon.implicitWidth + Theme.geometry_icon_margin_medium
		width: Math.min(implicitWidth, root.width)
		wrapMode: Text.Wrap
		color: root.color
		text: root.text

		CP.ColorImage {
			id: icon

			source: "qrc:/images/icon_alert_24.svg"
			color: root.color
		}
	}

	FontMetrics {
		id: fontMetrics
		font: label.font
	}
}
