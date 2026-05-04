/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	required property string pageName

	CP.ColorImage {
		id: promptImage

		anchors {
			centerIn: parent
			verticalCenterOffset: -promptLabel.height/2
		}

		source: "qrc:/images/prompt_device_rotation.svg"
		color: Theme.color_font_disabled
	}

	Label {
		id: promptLabel

		anchors {
			left: promptImage.left
			right: promptImage.right
			top: promptImage.bottom
		}

		topPadding: Theme.geometry_rotateDevicePrompt_spacing
		horizontalAlignment: Text.AlignHCenter
		//: Prompts the user to rotate the device. %1 = the name of the current page.
		//% "Rotate device to view %1"
		text: qsTrId("rotate_device_prompt_text").arg(root.pageName)
		font.pixelSize: Theme.font_size_caption
		color: Theme.color_font_secondary
	}
}
