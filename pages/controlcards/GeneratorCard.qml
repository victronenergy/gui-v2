/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Utils

ControlCard {
	id: root

	property var generator

	title.iconSource: "qrc:/images/generator.svg"
	title.text: CommonWords.generator

	status.text: {
		switch (root.generator.state) {
		case VenusOS.Generators_State_Running:
			return CommonWords.running_status
		case VenusOS.Generators_State_Error:
			//% "ERROR"
			return qsTrId("controlcard_generator_status_error")
		default:
			//% "Stopped"
			return qsTrId("controlcard_generator_status_stopped")
		}
	}

	GeneratorIconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.controlCard.contentMargins
			top: parent.status.top
			topMargin: parent.status.topMargin
			bottom: parent.status.bottom
			bottomMargin: parent.status.bottomMargin
		}
		generator: root.generator
	}

	Label {
		id: substatus
		anchors {
			top: timerDisplay.bottom
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
		}

		color: root.generator.state === VenusOS.Generators_State_Error ? Theme.color.critical
			: Theme.color.font.secondary
		text: root.generator.state !== VenusOS.Generators_State_Running ?
				"" // not running, empty substatus.
			: root.generator.runningBy === VenusOS.Generators_RunningBy_Manual ?
				//% "Manual started"
				qsTrId("controlcard_generator_substatus_manualstarted")
			: root.generator.runningBy === VenusOS.Generators_RunningBy_TestRun ?
				//% "Test run"
				qsTrId("controlcard_generator_substatus_testrun")
			: ( //% "Autostarted"
				qsTrId("controlcard_generator_substatus_autostarted")
				+ " \u2022 " + substatusForRunningBy(root.generator.runningBy))

		function substatusForRunningBy(runningBy) {
			switch (root.generator.runningBy) {
			case VenusOS.Generators_RunningBy_LossOfCommunication:
				//% "Loss of comm"
				return qsTrId("controlcard_generator_substatus_lossofcomm")
			case VenusOS.Generators_RunningBy_Soc:
				return CommonWords.state_of_charge
			case VenusOS.Generators_RunningBy_Acload:
				return CommonWords.ac_load
			case VenusOS.Generators_RunningBy_BatteryCurrent:
				return CommonWords.battery_current
			case VenusOS.Generators_RunningBy_BatteryVoltage:
				return CommonWords.battery_voltage
			case VenusOS.Generators_RunningBy_InverterHighTemp:
				//% "Inverter high temp"
				return qsTrId("controlcard_generator_substatus_inverterhigh_temp")
			case VenusOS.Generators_RunningBy_InverterOverload:
				return CommonWords.inverter_overload
			default: return "" // unknown substatus.
			}
		}
	}

	SwitchControlValue {
		id: autostartSwitch

		property var _confirmationDialog

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry.controlCard.status.bottomMargin
		}

		//% "Autostart"
		label.text: qsTrId("controlcard_generator_label_autostart")
		button.checked: root.generator.autoStart
		button.checkable: false     // user might not be allowed to change this setting
		separator.visible: false

		// TODO should also disable if user is not allowed to change autostart property
		enabled: root.generator.state !== VenusOS.Generators_State_Running

		onClicked: {
			if (root.generator.autoStart) {
				// check if they really want to disable
				if (!_confirmationDialog) {
					_confirmationDialog = confirmationDialogComponent.createObject(Global.dialogLayer)
				}
				_confirmationDialog.open()
			} else {
				root.generator.setAutoStart(false)
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
			}
		}
	}

	Label {
		anchors {
			top: autostartSwitch.bottom
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
			right: parent.right
			rightMargin: Theme.geometry.controlCard.contentMargins
		}
		wrapMode: Text.Wrap
		color: Theme.color.font.secondary
		font.pixelSize: Theme.font.size.caption

		//% "The generator will start and stop based on the configured autostart conditions."
		text: qsTrId("controlcard_generator_autostart_conditions")
	}

	Button {
		id: startStopButton

		property var _startDialog
		property var _stopDialog
		property int _generatorStateBeforeDialogOpen: -1

		anchors {
			margins: Theme.geometry.controlCard.button.margins
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: Theme.geometry.generatorCard.startButton.height
		radius: Theme.geometry.button.radius
		flat: true
		enabled: root.generator.state !== VenusOS.Generators_State_Error
		color: enabled ? Theme.color.font.primary : Theme.color.font.disabled
		backgroundColor: checked ? Theme.color.dimRed : Theme.color.dimGreen

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
