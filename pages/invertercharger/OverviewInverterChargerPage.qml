/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property var inverterCharger

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

	title: root.inverterCharger.description

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.inverterCharger.serviceUid + "/State"
			}

			ListItem {
				id: modeListButton

				text: CommonWords.mode
				writeAccessLevel: VenusOS.User_AccessType_User
				content.children: [
					InverterChargerModeButton {
						width: Math.min(implicitWidth, modeListButton.maximumContentWidth)
						serviceUid: root.inverterCharger.serviceUid
					}
				]
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: AcInputSettingsModel {
						serviceUid: root.inverterCharger.serviceUid
						numberOfAcInputs: root.inverterCharger.numberOfAcInputs
					}
					delegate: ListItem {
						id: currentLimitListButton
						writeAccessLevel: VenusOS.User_AccessType_User
						text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
						content.children: [
							CurrentLimitButton {
								width: Math.min(implicitWidth, currentLimitListButton.maximumContentWidth)
								serviceUid: root.inverterCharger.serviceUid
								inputNumber: modelData.inputNumber
							}
						]
					}
				}
			}

			Loader {
				width: parent ? parent.width : 0
				sourceComponent: _numberOfPhases.value === 1
								 ? singlePhaseAcInOut
								 : _numberOfPhases.value === 3
								   ? threePhaseTables
								   : null
			}

			ActiveAcInputTextItem {
				bindPrefix: root.inverterCharger.serviceUid
			}

			ListTextGroup {
				readonly property quantityInfo power: Units.getDisplayText(VenusOS.Units_Watt, dcPower.value)
				readonly property quantityInfo voltage: Units.getDisplayText(VenusOS.Units_Volt_DC, dcVoltage.value)
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
				data: AcPhase { serviceUid: root.inverterCharger.serviceUid + "/Ac/ActiveIn/L1" }
			}

			PVCFListQuantityGroup {
				text: CommonWords.ac_out
				data: AcPhase { serviceUid: root.inverterCharger.serviceUid + "/Ac/Out/L1" }
			}
		}
	}

	Component {
		id: threePhaseTables

		ThreePhaseIOTable {
			width: parent ? parent.width : 0
			phaseCount: _numberOfPhases.value || 0
			inputPhaseUidPrefix: root.inverterCharger.serviceUid + "/Ac/ActiveIn"
			outputPhaseUidPrefix: root.inverterCharger.serviceUid + "/Ac/Out"
			totalInputPowerUid: root.inverterCharger.serviceUid + "/Ac/ActiveIn/P"
			totalOutputPowerUid: root.inverterCharger.serviceUid + "/Ac/Out/P"
		}
	}
}
