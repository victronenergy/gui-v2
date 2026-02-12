/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

RowLayout {
	id: root

	required property string formattedName
	required property string statusText
	property string secondaryTitle
	property bool statusVisible
	property color statusColor: Theme.color_red

	Label {
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignBaseline
		bottomPadding: Theme.geometry_switchableoutput_label_margin
		rightPadding: Theme.geometry_switchableoutput_label_margin
		text: root.formattedName
		elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
	}

	Label {
		id: secondaryTitleLabel
		Layout.alignment: Qt.AlignBaseline
		bottomPadding: Theme.geometry_switchableoutput_label_margin
		text: root.secondaryTitle
		font.pixelSize: Theme.font_size_body2
	}

	Rectangle {
		id: statusRect

		Layout.bottomMargin: Theme.geometry_switchableoutput_label_margin
		Layout.maximumWidth: parent.width / 2
		Layout.minimumWidth: statusLabel.implicitWidth
		Layout.alignment: Qt.AlignRight
		height: statusLabel.height
		color: statusLabel.color === Theme.color_green ? Theme.color_darkGreen
				: statusLabel.color === Theme.color_orange ? Theme.color_darkOrange
				: statusLabel.color === Theme.color_red ? Theme.color_darkRed
				: Theme.color_switch_status_disabled
		radius: Theme.geometry_switchableoutput_status_radius
		visible: root.statusVisible

		Label {
			id: statusLabel

			anchors.centerIn: parent
			text: root.statusText
			width: parent.width
			topPadding: Theme.geometry_switchableoutput_status_verticalPadding
			bottomPadding: Theme.geometry_switchableoutput_status_verticalPadding
			leftPadding: Theme.geometry_switchableoutput_status_horizontalPadding
			rightPadding: Theme.geometry_switchableoutput_status_horizontalPadding
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			font.pixelSize: Theme.font_size_tiny
			color: root.statusColor
		}
	}
}
