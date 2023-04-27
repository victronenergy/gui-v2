/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Loader {
	active: FrameRateModel.frameRate >= 0
	anchors {
		left: parent.left
		right: parent.right
		bottom: parent.bottom
	}

	sourceComponent: Component {
		Item {
			Row {
				id: fpsRow
				anchors {
					left: parent.left
					bottom: parent.bottom
				}
				height: visible ? 4 : 0
				Repeater {
					height: parent.height
					model: FrameRateModel.frameRate >= 0 ? FrameRateModel : null
					delegate: Rectangle {
						height: parent.height
						width: root.width / FrameRateModel.chunkCount
						color: model.decoration
					}
				}
			}

			Label {
				anchors {
					right: parent.right
					bottom: fpsRow.top
					margins: fpsRow.height
				}
				visible: FrameRateModel.frameRate >= 0
				text: FrameRateModel.frameRate
				color: "white"
			}
		}
	}
}
