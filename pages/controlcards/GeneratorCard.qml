/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
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

		property ModalWarningDialog _confirmationDialog

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
		}

		//% "Autostart"
		label.text: qsTrId("controlcard_generator_label_autostart")
		button.checked: root.generator.autoStart
		button.enabled: root.generator.state !== VenusOS.Generators_State_Running
		separator.visible: false

		Connections {
			target: autostartSwitch.button
			function onToggled() {
				if (autostartSwitch.button.checked) {
					root.generator.setAutoStart(false)
				} else {
					// check if they really want to disable
					if (!autostartSwitch._confirmationDialog) {
						autostartSwitch._confirmationDialog = confirmationDialogComponent.createObject(Global.dialogLayer)
					}
					autostartSwitch._confirmationDialog.open()
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

				onAccepted: root.generator.setAutoStart(false)
				onRejected: root.generator.setAutoStart(true)
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

	Button {
		id: startStopButton

		property GeneratorStartDialog _startDialog
		property GeneratorStopDialog _stopDialog
		property int _generatorStateBeforeDialogOpen: -1

		anchors {
			margins: Theme.geometry_controlCard_button_margins
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry_generatorCard_startButton_height
		radius: Theme.geometry_button_radius
		flat: true
		enabled: root.generator.state !== VenusOS.Generators_State_Error
		color: enabled ? Theme.color_font_primary : Theme.color_font_disabled
		backgroundColor: checked ? Theme.color_dimRed : Theme.color_dimGreen

		// If the stop or start dialog is open, set the button color based on the generator
		// state at the time dialog was opened. This avoid changing the color of the button
		// when it is visible below the open start/stop dialogs.
		checked: _generatorStateBeforeDialogOpen < 0
				 ? root.generator.state === VenusOS.Generators_State_Running
				 : _generatorStateBeforeDialogOpen === VenusOS.Generators_State_Running

		text: checked
				//% "Manual Stop"
			  ? qsTrId("controlcard_generator_subcard_button_manual_stop")
				/* stopped */
				//% "Manual Start"
			  : qsTrId("controlcard_generator_subcard_button_manual_start")

		onClicked: {
			_generatorStateBeforeDialogOpen = root.generator.state
			if (root.generator.state === VenusOS.Generators_State_Running) {
				if (!_stopDialog) {
					_stopDialog = generatorStopDialogComponent.createObject(Global.dialogLayer)
				}
				_stopDialog.open()
			} else {
				if (!_startDialog) {
					_startDialog = generatorStartDialogComponent.createObject(Global.dialogLayer)
				}
				_startDialog.open()
			}
		}

		Component {
			id: generatorStartDialogComponent

			GeneratorStartDialog {
				generator: root.generator
				onAboutToShow: secondaryTitle = startStopButton.text
				onAboutToHide: startStopButton._generatorStateBeforeDialogOpen = -1
			}
		}

		Component {
			id: generatorStopDialogComponent

			GeneratorStopDialog {
				generator: root.generator
				onAboutToShow: secondaryTitle = startStopButton.text
				onAboutToHide: startStopButton._generatorStateBeforeDialogOpen = -1
			}
		}
	}
}
