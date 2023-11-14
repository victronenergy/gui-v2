/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Loader {
	anchors {
		left: parent.left
		right: parent.right
		bottom: parent.bottom
	}

	// Disable the visualizer and the model while the application isn't visible
	active: FrameRateModel.enabled
	property bool frameRateModelWasEnabled: false
	property bool applicationVisible: BackendConnection.applicationVisible
	onApplicationVisibleChanged: {
		if (!applicationVisible) {
			frameRateModelWasEnabled = FrameRateModel.enabled
			FrameRateModel.enabled = false
		} else if (frameRateModelWasEnabled) {
			FrameRateModel.enabled = true
		}
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
