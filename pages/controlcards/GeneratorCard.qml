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

	SwitchControlValue {
		id: autostartSwitch

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}

		//% "Autostart"
		label.text: qsTrId("controlcard_generator_label_autostart")
		button.checked: root.generator.autoStart
		button.enabled: root.generator.state !== VenusOS.Generators_State_Running
		button.checkable: false // control the checked state locally
		separator.visible: false

		Connections {
			target: autostartSwitch.button

			function onClicked() {
				if (!autostartSwitch.button.checked) {
					root.generator.setAutoStart(true)
				} else {
					// check if they really want to disable
					Global.dialogLayer.open(confirmationDialogComponent)
				}
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

	Label {
		anchors {
			top: autostartSwitch.bottom
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
		}
		wrapMode: Text.Wrap
		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_size_caption

		//% "The generator will start and stop based on the configured autostart conditions."
		text: qsTrId("controlcard_generator_autostart_conditions")
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
