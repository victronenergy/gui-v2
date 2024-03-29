/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property var inverterCharger

	readonly property var acActiveInPhases: [ acActiveIn1, acActiveIn2, acActiveIn3 ]

	VeQuickItem {
		id: _acOutputPower

		uid: inverterCharger.serviceUid + "/Ac/Out/P"
	}

	VeQuickItem {
		id: _acActiveInputPower

		uid: inverterCharger.serviceUid + "/Ac/ActiveIn/P"
	}

	VeQuickItem {
		id: bmsMode

		uid: inverterCharger.serviceUid + "/Devices/Bms/Version"
	}

	VeQuickItem {
		id: dmc

		uid: root.inverterCharger.serviceUid + "/Devices/Dmc/Version"
	}

	VeQuickItem {
		id: _numberOfPhases

		uid: inverterCharger.serviceUid + "/Ac/NumberOfPhases"
	}

	VeQuickItem {
		id: dcCurrent

		uid: inverterCharger.serviceUid + "/Dc/0/Current"
	}

	VeQuickItem {
		id: dcPower

		uid: inverterCharger.serviceUid + "/Dc/0/Power"
	}

	VeQuickItem {
		id: dcVoltage

		uid: inverterCharger.serviceUid + "/Dc/0/Voltage"
	}

	VeQuickItem {
		id: stateOfCharge

		uid: inverterCharger.serviceUid + "/Soc"
	}

	AcOutput {
		id: acOutput

		serviceUid: inverterCharger.serviceUid
	}

	AcPhase{
		id: acActiveIn1

		serviceUid: inverterCharger.serviceUid + "/Ac/ActiveIn/L1"
	}

	AcPhase{
		id: acActiveIn2

		serviceUid: inverterCharger.serviceUid + "/Ac/ActiveIn/L2"
	}

	AcPhase{
		id: acActiveIn3

		serviceUid: inverterCharger.serviceUid + "/Ac/ActiveIn/L3"
	}

	title: root.inverterCharger.description


	GradientListView {
		model: ObjectModel {

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.inverterCharger.serviceUid + "/State"
			}

			VeBusDeviceModeButton {
				veBusDevice: root.inverterCharger
			}

			AcInputsCurrentLimits {
				model: root.inverterCharger.inputSettings
				veBusDevice: root.inverterCharger
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
				veBusDevice: root.inverterCharger
			}

			ListTextGroup {
				readonly property quantityInfo power: Units.getDisplayText(VenusOS.Units_Watt, dcPower.value)
				readonly property quantityInfo voltage: Units.getDisplayText(VenusOS.Units_Volt, dcVoltage.value)
				readonly property quantityInfo current: Units.getDisplayText(VenusOS.Units_Amp, dcCurrent.value)
				readonly property quantityInfo soc: Units.getDisplayText(VenusOS.Units_Percentage, stateOfCharge.value)

				text: CommonWords.dc
				textModel: [
					power.number + power.unit,
					voltage.number + voltage.unit,
					current.number + current.unit,
					CommonWords.soc_with_prefix.arg(soc.number)
				]
			}

			ListNavigationItem {
				text: CommonWords.product_page
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", { veBusDevice: root.inverterCharger })
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
