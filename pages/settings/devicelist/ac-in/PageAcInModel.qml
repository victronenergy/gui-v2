/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
	id: root

	property string bindPrefix
	property int productId

	readonly property VeQuickItem nrOfPhases: VeQuickItem {
		uid: root.bindPrefix + "/NrOfPhases"
	}

	// The selected phase, if applicable (e.g. Multi RS in PV inverter only mode, which is assigned
	// to a specific phase).
	readonly property VeQuickItem phase: VeQuickItem {
		uid: root.bindPrefix + "/Ac/Phase"
	}

	// Phase numbers are determined by /NrOfPhases or /Ac/Phase, in that order. If neither are set,
	// use all 3 phases and rely on phaseCountKnown to filter out invalid phases.
	readonly property var phaseNumbers: nrOfPhases.valid ? Array.from({length: nrOfPhases.value}, (_, index) => index+1)
			: phase.valid ? [ phase.value ]
			: [1,2,3]   // default to 3 phases, and use phaseCountKnown to filter out invalid phases

	// If the number of phases is not known, show each phase depending on whether there is valid
	// data for that phase.
	readonly property bool phaseCountKnown: phase.valid || nrOfPhases.valid

	ListText {
		text: CommonWords.status
		dataItem.uid: root.bindPrefix + "/StatusCode"
		preferredVisible: dataItem.valid
		secondaryText: VenusOS.pvInverter_statusCodeToText(dataItem.value)
	}

	ListAcInError {
		bindPrefix: root.bindPrefix
	}

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: root.phaseNumbers.length > 0

		Repeater {
			model: root.phaseNumbers
			delegate: ListQuantityGroup {
				preferredVisible: root.phaseCountKnown || (phaseVoltage.valid || phaseCurrent.valid ||
												  phasePower.valid || phasePowerFactor.valid)
				text: CommonWords.ac_phase_x.arg(modelData)
				model: QuantityObjectModel {
					filterType: QuantityObjectModel.HasValue

					QuantityObject { object: phaseVoltage; unit: VenusOS.Units_Volt_AC; defaultValue: "--" }
					QuantityObject { object: phaseCurrent; unit: VenusOS.Units_Amp; defaultValue: "--" }
					QuantityObject { object: phasePower; unit: VenusOS.Units_Watt; defaultValue: "--" }
					QuantityObject { object: phasePowerFactor; unit: VenusOS.Units_PowerFactor }
				}

				VeQuickItem {
					id: phaseVoltage
					uid: root.bindPrefix + "/Ac/L" + modelData + "/Voltage"
				}
				VeQuickItem {
					id: phaseCurrent
					uid: root.bindPrefix + "/Ac/L" + modelData + "/Current"
				}
				VeQuickItem {
					id: phasePower
					uid: root.bindPrefix + "/Ac/L" + modelData + "/Power"
				}
				VeQuickItem {
					id: phasePowerFactor
					uid: root.bindPrefix + "/Ac/L" + modelData + "/PowerFactor"
				}
			}
		}
	}

	ListQuantityGroup {
		//% "AC Totals"
		text: qsTrId("ac-in-modeldefault_ac_totals")
		model: QuantityObjectModel {
			QuantityObject { object: totalPower; unit: VenusOS.Units_Watt }
			QuantityObject { object: totalEnergy; unit: VenusOS.Units_Energy_KiloWattHour; defaultValue: "--" }
			QuantityObject { object: totalEnergyReverse; unit: VenusOS.Units_Energy_KiloWattHour; defaultValue: "--" }
		}

		VeQuickItem {
			id: totalPower
			uid: root.bindPrefix + "/Ac/Power"
		}

		VeQuickItem {
			id: totalEnergy
			uid: root.bindPrefix + "/Ac/Energy/Forward"
		}

		VeQuickItem {
			id: totalEnergyReverse
			uid: root.bindPrefix + "/Ac/Energy/Reverse"
		}
	}

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: root.phaseNumbers.length > 0

		Repeater {
			model: root.phaseNumbers
			delegate: ListQuantity {
				//: %1 = phase number (1-3)
				//% "Energy L%1"
				text: qsTrId("ac-in-modeldefault_energy_x").arg(modelData)
				dataItem.uid: "%1/Ac/L%2/Energy/Forward".arg(root.bindPrefix).arg(modelData)
				unit: VenusOS.Units_Energy_KiloWattHour
				preferredVisible: root.phaseCountKnown || dataItem.valid
			}
		}
	}

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: root.phaseNumbers.length > 0

		Repeater {
			model: root.phaseNumbers
			delegate: ListQuantity {
				//: %1 = phase number (1-3)
				//% "Reversed Energy L%1"
				text: qsTrId("ac-in-modeldefault_energy_reverse_x").arg(modelData)
				dataItem.uid: "%1/Ac/L%2/Energy/Reverse".arg(root.bindPrefix).arg(modelData)
				unit: VenusOS.Units_Energy_KiloWattHour
				preferredVisible: root.phaseCountKnown || dataItem.valid
			}
		}
	}

	ListQuantity {
		text: CommonWords.dynamic_power_limit
		unit: VenusOS.Units_Watt
		dataItem.uid: root.bindPrefix + "/Ac/PowerLimit"
		preferredVisible: dataItem.valid
	}

	ListText {
		//% "Phase Sequence"
		text: qsTrId("ac-in-modeldefault_phase_sequence")
		dataItem.uid: root.bindPrefix + "/PhaseSequence"
		preferredVisible: dataItem.valid
		secondaryText: dataItem.value === 1
				  //: Phase sequence L1-L3-L2
				  //% "L1-L3-L2"
				? qsTrId("ac-in-modeldefault_phase_sequence_l3_first")
				  //: Phase sequence L1-L2-L3
				  //% "L1-L2-L3"
				: qsTrId("ac-in-modeldefault_phase_sequence_ordered")
	}

	ListNavigation {
		text: CommonWords.setup
		preferredVisible: allowedRoles.valid
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcInSetup.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}

		VeQuickItem {
			id: allowedRoles
			uid: root.bindPrefix + "/AllowedRoles"
		}
	}
}
