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

	// data from Generators.qml.  TODO: hook up.
	property int state: Generators.GeneratorState.Running
	property int runtime: 3793 // seconds remaining?
	property int runningBy: Generators.GeneratorRunningBy.Manual

	icon.source: "qrc:/images/generator.svg"
	//% "Generator"
	title.text: qsTrId("controlcard_generator")
	status.text: root.state === Generators.GeneratorState.Error ?
					//% "ERROR"
					qsTrId("controlcard_generator_status_error")
				: root.state === Generators.GeneratorState.Stopped ?
					//% "Stopped"
					qsTrId("controlcard_generator_status_stopped")
				: /* Running */
					//% "Running"
					qsTrId("controlcard_generator_status_running")

	CP.IconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: 14
			top: parent.status.top
			topMargin: parent.status.topMargin
			bottom: parent.status.bottom
			bottomMargin: parent.status.bottomMargin
		}

		spacing: 5
		display: C.AbstractButton.TextBesideIcon

		icon.width: 24
		icon.height: 24
		icon.source: root.state !== Generators.GeneratorState.Running ? ""
				: root.runningBy === Generators.GeneratorRunningBy.Manual
					? root.runtime > 0
						? "qrc:/images/icon_manualstart_timer_24.svg"
						: "qrc:/images/icon_manualstart_24.svg"
				: "qrc:/images/icon_autostart_24.svg"
		text: Utils.formatAsHHMM(root.runtime)
		font.family: VenusFont.normal.name
		font.pixelSize: Theme.fontSizeControlValue
		color: root.runtime > 0 ? Theme.primaryFontColor : Theme.weatherColor
	}

	Label {
		id: substatus
		anchors {
			top: timerDisplay.bottom
			left: parent.left
			leftMargin: 16
		}

		color: root.state === Generators.GeneratorState.Error ? Theme.criticalColor : Theme.weatherColor
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
			case root.runningBy === Generators.GeneratorRunningBy.Soc:
				//% "State of charge"
				return qsTrId("controlcard_generator_substatus_stateofcharge")
			case root.runningBy === Generators.GeneratorRunningBy.Acload:
				//% "AC load"
				return qsTrId("controlcard_generator_substatus_acload")
			case root.runningBy === Generators.GeneratorRunningBy.BatteryCurrent:
				//% "Battery current"
				return qsTrId("controlcard_generator_substatus_batterycurrent")
			case root.runningBy === Generators.GeneratorRunningBy.BatteryVoltage:
				//% "Battery voltage"
				return qsTrId("controlcard_generator_substatus_batteryvoltage")
			case root.runningBy === Generators.GeneratorRunningBy.InverterHighTemp:
				//% "Inverter high temp"
				return qsTrId("controlcard_generator_substatus_inverterhigh_temp")
			case root.runningBy === Generators.GeneratorRunningBy.InverterOverload:
				//% "Inverter overload"
				return qsTrId("controlcard_generator_substatus_inverteroverload")
			default: return "" // unknown substatus.
			}
		}
	}

	Item {
		id: autostartRow
		anchors {
			top: substatus.bottom
			left: parent.left
			right: parent.right
		}

		height: 56

		Label {
			id: autostartLabel
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: 16
			}

			//% "Autostart"
			text: qsTrId("controlcard_generator_label_autostart")
		}
		Switch {
			id: autostartSwitch
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: 16
			}

			property bool generatorAutostartValue: true // TODO: bind to data model
			checkable: false
			checked: generatorAutostartValue
			onClicked: {
				if (generatorAutostartValue) {
					// check if they really want to disable
					dialogManager.generatorDisableAutostartDialog.open()
				} else {
					generatorAutostartValue = true
				}
			}
			Connections {
				target: dialogManager.generatorDisableAutostartDialog
				function onAccepted() {
					autostartSwitch.generatorAutostartValue = false
				}
			}
		}
	}

	Item {
		id: subcard
		anchors {
			left: parent.left
			leftMargin: 8
			right: parent.right
			rightMargin: 8
			top: autostartRow.bottom
			topMargin: 16
			bottom: parent.bottom
			bottomMargin: 8
		}

		Rectangle {
			id: subcardBgRect
			anchors.fill: parent
			color: Theme.separatorBarColor
			opacity: 0.5 // TODO: ask Serj for a solid-color version instead?
			radius: 8
		}

		Label {
			id: subcardHeader
			anchors {
				left: parent.left
				leftMargin: 16
				right: parent.right
				rightMargin: 16
			}

			height: 40
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignLeft
			font.pixelSize: Theme.fontSizeSubcardHeader
			//% "Manual control"
			text: qsTrId("controlcard_generator_subcard_header_manualcontrol")
			color: Theme.weatherColor
		}
		SeparatorBar {
			id: subcardHeaderSeparator
			anchors {
				top: subcardHeader.bottom
				left: parent.left
				right: parent.right
			}
		}
		Item {
			id: timedRunRow
			anchors {
				top: subcardHeaderSeparator.bottom
				left: parent.left
				right: parent.right
			}

			height: 56

			Label {
				id: timedRunLabel
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: 16
				}

				//% "Timed run"
				text: qsTrId("controlcard_generator_subcard_label_timedrun")
			}
			Switch {
				id: timedRunSwitch
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: 16
				}
			}
		}
		SeparatorBar {
			id: timedRunSeparator
			anchors {
				top: timedRunRow.bottom
				left: parent.left
				leftMargin: 8
				right: parent.right
				rightMargin: 8
			}
		}
		Item {
			id: durationRow
			anchors {
				top: timedRunSeparator.bottom
				left: parent.left
				right: parent.right
			}

			height: 72

			Label {
				id: durationLabel
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: 16
				}

				//% "Duration"
				text: qsTrId("controlcard_generator_subcard_label_duration")
			}
			Button {
				id: durationButton
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: 16
				}
				height: 40
				width: 112

				flat: !enabled
				enabled: timedRunSwitch.checked
				color: enabled ? Theme.primaryFontColor : Theme.secondaryFontColor
				backgroundColor: enabled ? Theme.spinboxButtonSecondaryColor : Theme.separatorBarColor
				border.color: Theme.okColor
				font.pixelSize: Theme.fontSizeControlValue

				text: Utils.formatAsHHMM(selectedRuntime)
				property int selectedRuntime: 0 // TODO: bind to data model

				onClicked: dialogManager.generatorDurationSelectorDialog.open()
				Connections {
					target: dialogManager.generatorDurationSelectorDialog
					function onDurationChanged() {
						durationButton.selectedRuntime = dialogManager.generatorDurationSelectorDialog.duration
					}
				}
			}
		}
		SeparatorBar {
			id: durationSeparator
			anchors {
				top: durationRow.bottom
				left: parent.left
				leftMargin: 8
				right: parent.right
				rightMargin: 8
			}
		}
		Button {
			id: startButton
			anchors {
				margins: 16
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			height: 48

			enabled: root.state !== Generators.GeneratorState.Error

			text: root.state === Generators.GeneratorState.Running ?
					//% "Stop"
					qsTrId("controlcard_generator_subcard_button_stop")
				: /* stopped */
					//% "Start"
					qsTrId("controlcard_generator_subcard_button_start")

			backgroundColor: root.state === Generators.GeneratorState.Error
					? Theme.colorValueWithOpacity(Theme.displayMode, Theme.SeparatorBarColor, 0.6)
				: root.state === Generators.GeneratorState.Running
					? Theme.colorValueWithOpacity(Theme.displayMode, Theme.CriticalColor, 0.6)
				: /* Stopped */
					  Theme.colorValueWithOpacity(Theme.displayMode, Theme.GoColor, 0.6)
			color: root.state === Generators.GeneratorState.Error ? Theme.secondaryFontColor
				: Theme.primaryFontColor

			onClicked: {
				// TODO: hook up to data model.
				if (root.state === Generators.GeneratorState.Running) {
					root.state = Generators.GeneratorState.Stopped
					root.runtime = -1
				} else {
					root.state = Generators.GeneratorState.Running
					root.runtime = 7357
				}
			}
		}
	}
}
