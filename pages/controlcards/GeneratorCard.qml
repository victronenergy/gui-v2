/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ControlCard {
	id: root

	property alias serviceUid: generator.serviceUid

	icon.source: "qrc:/images/generator.svg"
	title.text: CommonWords.generator
	status.text: generator.stateText
	status.rightPadding: timerDisplay.width + Theme.geometry_controlCard_contentMargins

	Generator {
		id: generator
	}

	GeneratorIconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
			top: parent.status.top
			topMargin: parent.status.font.pixelSize - fontSize
		}
		generator: generator
	}

	Label {
		id: runningBy

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
		}
		text: generator.isAutoStarted
			  ? CommonWords.autostarted_dot_running_by.arg(generator.runningByText)
			  : generator.runningByText
		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_size_caption
		wrapMode: Text.WordWrap
		visible: generator.isRunning
	}

	ListSwitch {
		id: autostartSwitch

		anchors {
			top: runningBy.visible ? runningBy.bottom : root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}

		//% "Autostart"
		text: qsTrId("controlcard_generator_label_autostart")
		checked: generator.autoStart
		flat: true
		bottomContent.children: [
			PrimaryListLabel {
				//% "Start and stop the generator based on the configured autostart conditions."
				text: qsTrId("controlcard_generator_autostart_conditions")
				color: Theme.color_font_secondary
				font.pixelSize: Theme.font_size_caption
				topPadding: 0
				leftPadding: autostartSwitch.leftPadding
				rightPadding: autostartSwitch.rightPadding
			}
		]

		onClicked: {
			if (!checked) {
				generator.setAutoStart(true)
			} else {
				// check if they really want to disable
				Global.dialogLayer.open(confirmationDialogComponent)
			}
		}

		KeyNavigation.down: controlButton

		Component {
			id: confirmationDialogComponent

			GeneratorDisableAutoStartDialog {
				onAccepted: generator.setAutoStart(false)
			}
		}
	}

	GeneratorManualControlButton {
		id: controlButton
		anchors {
			margins: Theme.geometry_controlCard_button_margins
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry_card_button_height
		radius: Theme.geometry_button_radius
		font.pixelSize: Theme.font_size_body1
		generatorUid: generator.serviceUid
	}
}
