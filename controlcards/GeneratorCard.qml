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

	property int state: VenusOS.Generators_State_Stopped
	property int runtime
	property int runningBy: VenusOS.Generators_RunningBy_NotRunning
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
		case VenusOS.Generators_State_Running:
			//% "Running"
			return qsTrId("controlcard_generator_status_running")
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

		visible: root.state === VenusOS.Generators_State_Running
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

		color: root.state === VenusOS.Generators_State_Error ? Theme.color.critical
			: Theme.color.font.secondary
		text: root.state !== VenusOS.Generators_State_Running ?
				"" // not running, empty substatus.
			: root.runningBy === VenusOS.Generators_RunningBy_Manual ?
				//% "Manual started"
				qsTrId("controlcard_generator_substatus_manualstarted")
			: root.runningBy === VenusOS.Generators_RunningBy_TestRun ?
				//% "Test run"
				qsTrId("controlcard_generator_substatus_testrun")
			: ( //% "Auto-started"
				qsTrId("controlcard_generator_substatus_autostarted")
				+ " \u2022 " + substatusForRunningBy(root.runningBy))

		function substatusForRunningBy(runningBy) {
			switch (root.runningBy) {
			case VenusOS.Generators_RunningBy_LossOfCommunication:
				//% "Loss of comm"
				return qsTrId("controlcard_generator_substatus_lossofcomm")
			case VenusOS.Generators_RunningBy_Soc:
				//% "State of charge"
				return qsTrId("controlcard_generator_substatus_stateofcharge")
			case VenusOS.Generators_RunningBy_Acload:
				//% "AC load"
				return qsTrId("controlcard_generator_substatus_acload")
			case VenusOS.Generators_RunningBy_BatteryCurrent:
				//% "Battery current"
				return qsTrId("controlcard_generator_substatus_batterycurrent")
			case VenusOS.Generators_RunningBy_BatteryVoltage:
				//% "Battery voltage"
				return qsTrId("controlcard_generator_substatus_batteryvoltage")
			case VenusOS.Generators_RunningBy_InverterHighTemp:
				//% "Inverter high temp"
				return qsTrId("controlcard_generator_substatus_inverterhigh_temp")
			case VenusOS.Generators_RunningBy_InverterOverload:
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
		separator.visible: false
		enabled: root.state !== VenusOS.Generators_State_Running

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
			topMargin: Theme.geometry.controlCard.subCard.margins
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCard.subCard.margins
		}

		Rectangle {
			id: subcardBgRect
			anchors.fill: parent
			color: Theme.color.card.panel.background
			radius: Theme.geometry.panel.radius
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
			color: Theme.color.font.secondary
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
			enabled: root.state !== VenusOS.Generators_State_Running
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
					&& root.state !== VenusOS.Generators_State_Running
			button.text: Utils.formatAsHHMM(durationButton.duration)

			onClicked: dialogManager.generatorDurationSelectorDialog.open()

			Connections {
				target: dialogManager.generatorDurationSelectorDialog
				function onDurationChanged() {
					durationButton.duration = dialogManager.generatorDurationSelectorDialog.duration
				}
			}
		}
		ActionButton {
			id: startButton
			anchors {
				margins: Theme.geometry.controlCard.contentMargins
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			height: Theme.geometry.generatorCard.startButton.height

			enabled: root.state !== VenusOS.Generators_State_Error

			text: root.state === VenusOS.Generators_State_Running ?
					//% "Stop"
					qsTrId("controlcard_generator_subcard_button_stop")
				: /* stopped */
					//% "Start"
					qsTrId("controlcard_generator_subcard_button_start")

			checked: root.state === VenusOS.Generators_State_Running

			onClicked: {
				if (root.state === VenusOS.Generators_State_Running) {
					root.manualStop()
				} else {
					root.manualStart(durationButton.duration)
				}
			}
		}
	}
}
