/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	property alias icon: icon
	property alias title: title
	property alias status: status

	implicitWidth: Theme.geometry_controlCard_maximumWidth
	implicitHeight: Theme.geometry_controlCard_height
	focus: true
	focusPolicy: Qt.TabFocus

	ListItemBackground {
		anchors.fill: parent
	}

	CP.ColorImage {
		id: icon

		anchors {
			verticalCenter: title.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry_size_16
		}
		color: Theme.color_font_primary
	}

	Label {
		id: title

		anchors {
			top: parent.top
			topMargin: Theme.geometry_size_16
			left: icon.right
			leftMargin: Theme.geometry_controlCard_title_spacing
			right: parent.right
			rightMargin: Theme.geometry_controlCard_title_spacing
		}
		font.pixelSize: Theme.font_control_title
		color: Theme.color_font_primary
		elide: Text.ElideRight
	}

	Label {
		id: status

		anchors {
			top: title.bottom
			topMargin: Theme.geometry_size_6
			left: parent.left
			leftMargin: Theme.geometry_size_16
			right: parent.right
			rightMargin: Theme.geometry_size_16
		}
		font.pixelSize: Theme.font_controlCard_status
		wrapMode: Text.Wrap
	}
}
