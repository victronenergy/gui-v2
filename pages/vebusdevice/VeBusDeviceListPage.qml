/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Units.js" as Units

Page {
	id: root
	property var veBusDevice: Global.veBusDevices.model.firstObject
	property var _currentLimitDialog

	//% "This setting is disabled when a Digital Multi Control is connected."
	readonly property string noAdjustableByDmc: qsTrId("vebus_no_adjustable_by_dmc")
	//% "This setting is disabled when a VE.Bus BMS is connected."
	readonly property string noAdjustableByBms: qsTrId("vebus_no_adjustable_by_bms")
	//% "This setting is disabled. Possible reasons are \"Overruled by remote\" is not enabled or an assistant is preventing the adjustment. Please, check the inverter configuration with VEConfigure."
	readonly property string noAdjustableTextByConfig: qsTrId("vebus_no_adjustable_text_by_config")

	DataPoint {
		id: acOutputPower

		source: veBusDevice.serviceUid + "/Ac/Out/P"
	}

	DataPoint {
		id: acActiveInput

		source: veBusDevice.serviceUid + "/Ac/ActiveIn/ActiveInput"
	}

	DataPoint {
		id: acActiveInputPower

		source: veBusDevice.serviceUid + "/Ac/ActiveIn/P"
	}

	DataPoint {
		id: bmsMode

		source: veBusDevice.serviceUid + "/Devices/Bms/Version"
	}

	DataPoint {
		id: dmc

		source: root.veBusDevice.serviceUid + "/Devices/Dmc/Version"
	}

	DataPoint {
		id: numberOfPhases

		source: veBusDevice.serviceUid + "/Ac/NumberOfPhases"
	}

	DataPoint {
		id: dcCurrent

		source: veBusDevice.serviceUid + "/Dc/0/Current"
	}

	DataPoint {
		id: dcPower

		source: veBusDevice.serviceUid + "/Dc/0/Power"
	}

	DataPoint {
		id: dcVoltage

		source: veBusDevice.serviceUid + "/Dc/0/Voltage"
	}

	DataPoint {
		id: stateOfCharge

		source: veBusDevice.serviceUid + "/Soc"
	}

	AcOutput {
		id: acOutput

		serviceUid: veBusDevice.serviceUid
	}

	AcPhase{
		id: acActiveIn1

		serviceUid: veBusDevice.serviceUid + "/Ac/ActiveIn/L1"
	}

	AcPhase{
		id: acActiveIn2

		serviceUid: veBusDevice.serviceUid + "/Ac/ActiveIn/L2"
	}

	AcPhase{
		id: acActiveIn3

		serviceUid: veBusDevice.serviceUid + "/Ac/ActiveIn/L3"
	}

	readonly property var acActiveInPhases: [ acActiveIn1, acActiveIn2, acActiveIn3 ]
	title: root.veBusDevice.description


	GradientListView {
		model: ObjectModel {

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(Global.system.state)
			}

			ListButton {
				property var _modeDialog

				text: CommonWords.mode
				button.width: Theme.geometry.vebusDeviceListPage.currentLimit.button.width
				button.text: Global.veBusDevices.modeToText(root.veBusDevice.mode)
				onClicked: {
					if (!root.veBusDevice.modeIsAdjustable) {
						if (dmc.valid)
							Global.showToastNotification(VenusOS.Notification_Info, root.noAdjustableByDmc,
														 Theme.animation.veBusDeviceModeNotAdjustable.toastNotication.duration)
						if (bmsMode.value !== undefined)
							Global.showToastNotification(VenusOS.Notification_Info, root.noAdjustableByBms,
														 Theme.animation.veBusDeviceModeNotAdjustable.toastNotication.duration)
						return
					}
					if (!_modeDialog) {
						_modeDialog = modeDialogComponent.createObject(Global.dialogLayer)
					}
					_modeDialog.mode = root.veBusDevice.mode
					_modeDialog.open()
				}
			}

			Column {
				width: parent ? parent.width : 0
				Repeater {
					id: currentLimitRepeater

					model: root.veBusDevice.inputSettings
					delegate: ListButton {
						id: currentLimit

						text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
						enabled: modelData.currentLimitAdjustable
						button.width: Theme.geometry.vebusDeviceListPage.currentLimit.button.width
						button.text: {
							const quantity = Units.getDisplayText(VenusOS.Units_Amp, modelData.currentLimit)
							return quantity.number + quantity.unit
						}
						onClicked: {
							if (!root._currentLimitDialog) {
								root._currentLimitDialog = currentLimitDialogComponent.createObject(Global.dialogLayer)
							}
							root._currentLimitDialog.inputSettings = modelData
							root._currentLimitDialog.inputIndex = model.index
							root._currentLimitDialog.value = modelData.currentLimit
							root._currentLimitDialog.open()
						}
					}
				}
			}

			Loader {
				width: parent ? parent.width : 0
				sourceComponent: numberOfPhases.value === 1
								 ? singlePhaseAcInOut
								 : numberOfPhases.value === 3
								   ? threePhaseTables
								   : null
			}

			ListTextItem {
				//% "Active Input"
				text: qsTrId("vebus_device_page_active_input")
				secondaryText: {
					switch(acActiveInput.value) {
					case 0:
					case 1:
						//% "AC in %1"
						return qsTrId("vebus_device_page_ac_in").arg(acActiveInput.value + 1)
					default:
						return CommonWords.disconnected
					}
				}
			}

			ListTextGroup {
				readonly property var power: Units.getDisplayText(VenusOS.Units_Watt, dcPower.value)
				readonly property var voltage: Units.getDisplayText(VenusOS.Units_Volt, dcVoltage.value)
				readonly property var current: Units.getDisplayText(VenusOS.Units_Amp, dcCurrent.value)
				readonly property var soc: Units.getDisplayText(VenusOS.Units_Percentage, stateOfCharge.value)

				//% "DC"
				text: qsTrId("vebus_device_page_dc")
				textModel: [
					power.number + power.unit,
					voltage.number + voltage.unit,
					current.number + current.unit,
					//% "SOC %1%"
					qsTrId("vebus_device_page_state_of_charge").arg(soc.number)
				]
			}

			// TODO: Add "Product Page"
		}
	}

	Component {
		id: modeDialogComponent

		InverterChargerModeDialog {
			isMulti: root.veBusDevice.isMulti
			onAccepted: {
				if (root.veBusDevice.mode !== mode) {
					root.veBusDevice.setMode(mode)
				}
			}
		}
	}

	Component {
		id: currentLimitDialogComponent

		CurrentLimitDialog {
			presets: root.veBusDevice.ampOptions
			onAccepted: root.veBusDevice.setCurrentLimit(inputIndex, value)
		}
	}

	Component {
		id: singlePhaseAcInOut

		Column {
			ListQuantityGroup {
				text: CommonWords.ac_in
				textModel: [
					{
						value: acActiveIn1.power,
						unit: VenusOS.Units_Watt
					},
					{
						value: acActiveIn1.voltage,
						unit: VenusOS.Units_Volt
					},
					{
						value: acActiveIn1.current,
						unit: VenusOS.Units_Amp
					},
					{
						value: acActiveIn1.frequency,
						unit: VenusOS.Units_Hertz
					}
				]
			}

			ListQuantityGroup {
				text: CommonWords.ac_out
				textModel: [
					{
						value: acOutput.phase1.power,
						unit: VenusOS.Units_Watt
					},
					{
						value: acOutput.phase1.voltage,
						unit: VenusOS.Units_Volt
					},
					{
						value: acOutput.phase1.current,
						unit: VenusOS.Units_Amp
					},
					{
						value: acOutput.phase1.frequency,
						unit: VenusOS.Units_Hertz
					}
				]
			}
		}
	}

	Component {
		id: singlePhaseAcOut

		ListQuantityGroup {
			text: CommonWords.ac_out
			textModel: [
				{
					value: acOutput.phase1.power,
					unit: VenusOS.Units_Watt
				},
				{
					value: acOutput.phase1.voltage,
					unit: VenusOS.Units_Volt
				},
				{
					value: acOutput.phase1.current,
					unit: VenusOS.Units_Amp
				},
				{
					value: acOutput.phase1.frequency,
					unit: VenusOS.Units_Hertz
				}
			]
		}
	}

	Component {
		id: threePhaseTables

		Row {
			width: parent ? parent.width : 0
			spacing: Theme.geometry.vebusDeviceListPage.quantityTable.row.spacing

			ThreePhaseQuantityTable {
				width: (parent.width - parent.spacing) / 2
				labelText: CommonWords.ac_in
				totalPower: Units.getDisplayText(VenusOS.Units_Watt, acActiveInputPower.value)
				valueForModelIndex: function(trackerIndex, column) {
					if (column === 0) {
						return "L%1".arg(trackerIndex + 1)
					}
					if (!numberOfPhases.valid) {
						return "--"
					}

					var phase = root.acActiveInPhases[trackerIndex]
					if (phase) {
						switch(column) {
						case 1:
							return Units.getDisplayText(VenusOS.Units_Watt, phase.power).number
						case 2:
							return Units.getDisplayText(VenusOS.Units_Volt, phase.voltage).number
						case 3:
							return Units.getDisplayText(VenusOS.Units_Amp, phase.current).number
						case 4:
							return Units.getDisplayText(VenusOS.Units_Hertz, phase.frequency).number
						}
						return "--"
					}
				}
			}

			ThreePhaseQuantityTable {
				id: acOutTable

				width: (parent.width - parent.spacing) / 2
				labelText: CommonWords.ac_out
				totalPower: Units.getDisplayText(VenusOS.Units_Watt, acOutputPower.value)
				valueForModelIndex: function(trackerIndex, column) {
					if (column === 0) {
						return "L%1".arg(trackerIndex + 1)
					}
					var phase = acOutput.phases[trackerIndex]

					if (phase) {
						switch(column) {
						case 1:
							return phase.power
						case 2:
							return phase.voltage
						case 3:
							return phase.current
						case 4:
							return phase.frequency
						}
					}
					return "--"
				}
			}
		}
	}
}
