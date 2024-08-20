/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ControlCard {
	id: root

	property Generator generator

	icon.source: "qrc:/images/generator.svg"
	title.text: CommonWords.generator
	status.text: Global.generators.stateToText(root.generator.state, root.generator.runningBy)
	status.rightPadding: timerDisplay.width + Theme.geometry_controlCard_contentMargins

	GeneratorIconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
			top: parent.status.top
			topMargin: parent.status.font.pixelSize - fontSize
		}
		generator: root.generator
	}

	ListSwitch {
		id: autostartSwitch

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}

		//% "Autostart"
		text: qsTrId("controlcard_generator_label_autostart")
		checked: root.generator.autoStart
		flat: true
		bottomContent.children: [
			ListLabel {
				//% "The generator will start and stop based on the configured autostart conditions."
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
				root.generator.setAutoStart(true)
			} else {
				// check if they really want to disable
				Global.dialogLayer.open(confirmationDialogComponent)
			}
		}

		Component {
			id: confirmationDialogComponent

			ModalWarningDialog {
				dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

				//% "Disable autostart?"
				title: qsTrId("controlcard_generator_disableautostartdialog_title")

				//% "Autostart will be disabled and the generator won't automatically start based on the configured conditions."
				description: qsTrId("controlcard_generator_disableautostartdialog_description")

				onAccepted: {
					root.generator.setAutoStart(false)
				}
			}
		}
	}

	GeneratorManualControlButton {
		anchors {
			margins: Theme.geometry_controlCard_button_margins
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry_generatorCard_startButton_height
		radius: Theme.geometry_button_radius
		font.pixelSize: Theme.font_size_body1
		generatorUid: root.generator.serviceUid
	}
}
