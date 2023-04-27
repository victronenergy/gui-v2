/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Loader {
	active: FrameRateModel.enabled
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
				height: 4
				Repeater {
					height: parent.height
					model: FrameRateModel
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
				text: FrameRateModel.frameRate
				color: "white"
			}
		}
	}
}
