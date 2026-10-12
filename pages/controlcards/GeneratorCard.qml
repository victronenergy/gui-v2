/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property alias serviceUid: generator.serviceUid

	implicitHeight: controlButton.y + controlButton.height + Theme.geometry_space_16
	icon.source: "qrc:/images/generator.svg"
	title.text: CommonWords.generator
	status.text: generator.stateText
	status.rightPadding: timerDisplay.width + Theme.geometry_space_16

	Generator {
		id: generator
	}

	GeneratorIconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: Theme.geometry_space_16
			baseline: parent.status.baseline
		}
		generator: generator
	}

	Label {
		id: runningBy

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_space_6
			left: parent.left
			leftMargin: Theme.geometry_space_16
			right: parent.right
			rightMargin: Theme.geometry_space_16
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
		writeAccessLevel: VenusOS.User_AccessType_User
		flat: true
		//% "Start and stop the generator based on the configured autostart conditions."
		caption: qsTrId("controlcard_generator_autostart_conditions")

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
			top: Theme.screenSize === Theme.Portrait ? autostartSwitch.bottom : undefined
			bottom: Theme.screenSize === Theme.Portrait ? undefined : parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry_card_button_height
		radius: Theme.geometry_radius_8
		font.pixelSize: Theme.font_button_size
		generatorUid: generator.serviceUid
	}
}
