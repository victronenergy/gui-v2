/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

ControlCard {
	id: root

	property int state: Generators.GeneratorState.Stopped
	property int runtime
	property int runningBy: Generators.GeneratorRunningBy.NotRunning
	property int manualStartTimer
	property bool autostart

	signal manualStart(durationSecs: int)
	signal manualStop()
	signal changeAutoStart(newAutoStart: bool)

	title.icon.source: "qrc:/images/generator.svg"
	//% "Generator"
	title.text: qsTrId("controlcard_generator")
	status.text: {
		switch (state) {
		case Generators.GeneratorState.Running:
			//% "Running"
			return qsTrId("controlcard_generator_status_running")
		case Generators.GeneratorState.Error:
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

		visible: root.state === Generators.GeneratorState.Running
		state: root.state
		runtime: root.runtime
		runningBy: root.runningBy
	}

	Label {
		id: substatus
		anchors {
			top: timerDisplay.bottom
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
		}

		color: root.state === Generators.GeneratorState.Error ? Theme.color.critical
			: Theme.color.font.tertiary
		text: root.state !== Generators.GeneratorState.Running ?
				"" // not running, empty substatus.
			: root.runningBy === Generators.GeneratorRunningBy.Manual ?
				//% "Manual started"
				qsTrId("controlcard_generator_substatus_manualstarted")
			: root.runningBy === Generators.GeneratorRunningBy.TestRun ?
				//% "Test run"
				qsTrId("controlcard_generator_substatus_testrun")
			: ( //% "Auto-started"
				qsTrId("controlcard_generator_substatus_autostarted")
				+ " \u2022 " + substatusForRunningBy(root.runningBy))

		function substatusForRunningBy(runningBy) {
			switch (root.runningBy) {
			case Generators.GeneratorRunningBy.LossOfCommunication:
				//% "Loss of comm"
				return qsTrId("controlcard_generator_substatus_lossofcomm")
			case Generators.GeneratorRunningBy.Soc:
				//% "State of charge"
				return qsTrId("controlcard_generator_substatus_stateofcharge")
			case Generators.GeneratorRunningBy.Acload:
				//% "AC load"
				return qsTrId("controlcard_generator_substatus_acload")
			case Generators.GeneratorRunningBy.BatteryCurrent:
				//% "Battery current"
				return qsTrId("controlcard_generator_substatus_batterycurrent")
			case Generators.GeneratorRunningBy.BatteryVoltage:
				//% "Battery voltage"
				return qsTrId("controlcard_generator_substatus_batteryvoltage")
			case Generators.GeneratorRunningBy.InverterHighTemp:
				//% "Inverter high temp"
				return qsTrId("controlcard_generator_substatus_inverterhigh_temp")
			case Generators.GeneratorRunningBy.InverterOverload:
				//% "Inverter overload"
				return qsTrId("controlcard_generator_substatus_inverteroverload")
			default: return "" // unknown substatus.
			}
		}
	}

	SwitchControlValue {
		id: autostartSwitch

		anchors.top: substatus.bottom

		//% "Autostart"
		label.text: qsTrId("controlcard_generator_label_autostart")
		button.checked: root.autostart
		enabled: root.state !== Generators.GeneratorState.Running

		onClicked: {
			if (root.autostart) {
				// check if they really want to disable
				dialogManager.generatorDisableAutostartDialog.open()
			} else {
				root.changeAutoStart(true)
			}
		}
		Connections {
			target: dialogManager.generatorDisableAutostartDialog
			function onAccepted() {
				root.changeAutoStart(false)
			}
		}
	}

	Item {
		id: subcard
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCard.subCard.margins
			right: parent.right
			rightMargin: Theme.geometry.controlCard.subCard.margins
			top: autostartSwitch.bottom
			topMargin: 2*Theme.geometry.controlCard.subCard.margins
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCard.subCard.margins
		}

		Rectangle {
			id: subcardBgRect
			anchors.fill: parent
			color: Theme.color.background.tertiary
			radius: Theme.geometry.controlCard.radius
		}

		Label {
			id: subcardHeader
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.controlCard.contentMargins
				right: parent.right
				rightMargin: Theme.geometry.controlCard.contentMargins
			}

			height: Theme.geometry.controlCard.subCard.header.height
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignLeft
			font.pixelSize: Theme.font.size.xs
			//% "Manual control"
			text: qsTrId("controlcard_generator_subcard_header_manualcontrol")
			color: Theme.color.font.tertiary
		}
		SeparatorBar {
			id: subcardHeaderSeparator
			anchors {
				top: subcardHeader.bottom
				left: parent.left
				right: parent.right
			}
		}
		SwitchControlValue {
			id: timedRunSwitch

			anchors.top: subcardHeaderSeparator.bottom
			//% "Timed run"
			label.text: qsTrId("controlcard_generator_subcard_label_timedrun")
			enabled: root.state !== Generators.GeneratorState.Running
		}
		ButtonControlValue {
			id: durationButton

			property int duration: root.manualStartTimer

			anchors.top: timedRunSwitch.bottom
			//% "Duration"
			label.text: qsTrId("controlcard_generator_subcard_label_duration")

			button.height: Theme.geometry.generatorCard.durationButton.height
			button.width: Theme.geometry.generatorCard.durationButton.width
			button.enabled: timedRunSwitch.button.checked
					&& root.state !== Generators.GeneratorState.Running
			button.text: Utils.formatAsHHMM(durationButton.duration)

			onClicked: dialogManager.generatorDurationSelectorDialog.open()

			Connections {
				target: dialogManager.generatorDurationSelectorDialog
				function onDurationChanged() {
					durationButton.duration = dialogManager.generatorDurationSelectorDialog.duration
				}
			}
		}
		Button {
			id: startButton
			anchors {
				margins: Theme.geometry.controlCard.contentMargins
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			height: Theme.geometry.generatorCard.startButton.height

			enabled: root.state !== Generators.GeneratorState.Error

			text: root.state === Generators.GeneratorState.Running ?
					//% "Stop"
					qsTrId("controlcard_generator_subcard_button_stop")
				: /* stopped */
					//% "Start"
					qsTrId("controlcard_generator_subcard_button_start")

			backgroundColor: root.state === Generators.GeneratorState.Error
					? Theme.color.background.disabled
				: root.state === Generators.GeneratorState.Running
					? down ? Theme.color.critical : Theme.color.dimCritical
				: /* Stopped */
					  down ? Theme.color.go : Theme.color.dimGo
			color: root.state === Generators.GeneratorState.Error ? Theme.color.font.disabled
				: Theme.color.font.primary

			onClicked: {
				if (root.state === Generators.GeneratorState.Running) {
					root.manualStop()
				} else {
					root.manualStart(durationButton.duration)
				}
			}
		}
	}
}
