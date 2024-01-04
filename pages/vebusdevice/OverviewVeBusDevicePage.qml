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

	VeQuickItem {
		id: _acOutputPower

		uid: veBusDevice.serviceUid + "/Ac/Out/P"
	}

	VeQuickItem {
		id: _acActiveInputPower

		uid: veBusDevice.serviceUid + "/Ac/ActiveIn/P"
	}

	VeQuickItem {
		id: bmsMode

		uid: veBusDevice.serviceUid + "/Devices/Bms/Version"
	}

	VeQuickItem {
		id: dmc

		uid: root.veBusDevice.serviceUid + "/Devices/Dmc/Version"
	}

	VeQuickItem {
		id: _numberOfPhases

		uid: veBusDevice.serviceUid + "/Ac/NumberOfPhases"
	}

	VeQuickItem {
		id: dcCurrent

		uid: veBusDevice.serviceUid + "/Dc/0/Current"
	}

	VeQuickItem {
		id: dcPower

		uid: veBusDevice.serviceUid + "/Dc/0/Power"
	}

	VeQuickItem {
		id: dcVoltage

		uid: veBusDevice.serviceUid + "/Dc/0/Voltage"
	}

	VeQuickItem {
		id: stateOfCharge

		uid: veBusDevice.serviceUid + "/Soc"
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
				readonly property quantityInfo power: Units.getDisplayText(VenusOS.Units_Watt, dcPower.value)
				readonly property quantityInfo voltage: Units.getDisplayText(VenusOS.Units_Volt, dcVoltage.value)
				readonly property quantityInfo current: Units.getDisplayText(VenusOS.Units_Amp, dcCurrent.value)
				readonly property quantityInfo soc: Units.getDisplayText(VenusOS.Units_Percentage, stateOfCharge.value)

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
