/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

Page {
	id: root

	property var veBusDevice: Global.veBusDevices.model.firstObject

	readonly property var acActiveInPhases: [ acActiveIn1, acActiveIn2, acActiveIn3 ]

	DataPoint {
		id: _acOutputPower

		source: veBusDevice.serviceUid + "/Ac/Out/P"
	}

	DataPoint {
		id: _acActiveInputPower

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
		id: _numberOfPhases

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

	title: root.veBusDevice.description


	GradientListView {
		model: ObjectModel {

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(Global.system.state)
			}

			VeBusDeviceModeButton {
				veBusDevice: root.veBusDevice
			}

			AcInputsCurrentLimits {
				model: root.veBusDevice.inputSettings
				veBusDevice: root.veBusDevice
				width: parent ? parent.width : 0
			}

			Loader {
				width: parent ? parent.width : 0
				sourceComponent: _numberOfPhases.value === 1
								 ? singlePhaseAcInOut
								 : _numberOfPhases.value === 3
								   ? threePhaseTables
								   : null
			}

			VeBusDeviceActiveAcInputTextItem {
				veBusDevice: root.veBusDevice
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

			ListNavigationItem {
				//% "Product page"
				text: qsTrId("vebus_device_product_page")
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", { veBusDevice: root.veBusDevice })
			}
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
		id: singlePhaseAcInOut

		Column {
			PVCFListQuantityGroup {
				text: CommonWords.ac_in
				data: acActiveIn1
			}

			PVCFListQuantityGroup {
				text: CommonWords.ac_out
				data: acOutput.phase1
			}
		}
	}

	Component {
		id: threePhaseTables

		ThreePhaseIOTable {
			width: parent ? parent.width : 0
			numberOfPhases: _numberOfPhases.value
			inputPhases: root.acActiveInPhases
			outputPhases: acOutput.phases
			acActiveInputPower: _acActiveInputPower
			acOutputPower: _acOutputPower
		}
	}
}
