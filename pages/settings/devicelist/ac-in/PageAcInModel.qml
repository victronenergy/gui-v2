/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ObjectModel {
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
	readonly property var phaseNumbers: nrOfPhases.isValid ? Array.from({length: nrOfPhases.value}, (_, index) => index+1)
			: phase.isValid ? [ phase.value ]
			: [1,2,3]   // default to 3 phases, and use phaseCountKnown to filter out invalid phases

	// If the number of phases is not known, show each phase depending on whether there is valid
	// data for that phase.
	readonly property bool phaseCountKnown: phase.isValid || nrOfPhases.isValid

	ListText {
		text: CommonWords.status
		dataItem.uid: root.bindPrefix + "/StatusCode"
		allowed: defaultAllowed && dataItem.isValid
		secondaryText: Global.pvInverters.statusCodeToText(dataItem.value)
	}

	ListAcInError {
		bindPrefix: root.bindPrefix
	}

	Column {
		width: parent ? parent.width : 0

		Repeater {
			model: root.phaseNumbers
			delegate: ListQuantityGroup {
				allowed: root.phaseCountKnown || (phaseVoltage.isValid || phaseCurrent.isValid || phasePower.isValid)
				text: CommonWords.ac_phase_x.arg(modelData)
				textModel: [
					{ value: phaseVoltage.value, unit: VenusOS.Units_Volt_AC },
					{ value: phaseCurrent.value, unit: VenusOS.Units_Amp },
					{ value: phasePower.value, unit: VenusOS.Units_Watt },
				]

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
			}
		}
	}

	ListQuantityGroup {
		//% "AC Totals"
		text: qsTrId("ac-in-modeldefault_ac_totals")
		textModel: [
			{ value: totalPower.value, unit: VenusOS.Units_Watt },
			{ value: totalEnergy.value, unit: VenusOS.Units_Energy_KiloWattHour },
		]

		VeQuickItem {
			id: totalPower
			uid: root.bindPrefix + "/Ac/Power"
		}

		VeQuickItem {
			id: totalEnergy
			uid: root.bindPrefix + "/Ac/Energy/Forward"
		}
	}

	Column {
		width: parent ? parent.width : 0

		Repeater {
			model: root.phaseNumbers
			delegate: ListQuantity {
				//: %1 = phase number (1-3)
				//% "Energy L%1"
				text: qsTrId("ac-in-modeldefault_energy_x").arg(modelData)
				dataItem.uid: "%1/Ac/L%2/Energy/Forward".arg(root.bindPrefix).arg(modelData)
				unit: VenusOS.Units_Energy_KiloWattHour
				allowed: root.phaseCountKnown || dataItem.isValid
			}
		}
	}

	ListText {
		text: CommonWords.zero_feed_in_power_limit
		dataItem.uid: root.bindPrefix + "/Ac/PowerLimit"
		allowed: dataItem.isValid
	}

	ListText {
		//% "Phase Sequence"
		text: qsTrId("ac-in-modeldefault_phase_sequence")
		dataItem.uid: root.bindPrefix + "/PhaseSequence"
		allowed: dataItem.isValid
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
		allowed: allowedRoles.isValid
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcInSetup.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}

		VeQuickItem {
			id: allowedRoles
			uid: root.bindPrefix + "/AllowedRoles"
		}
	}

	ListNavigation {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage(deviceInfoComponent, { "title": text })
		}

		Component {
			id: deviceInfoComponent

			PageDeviceInfo {
				id: deviceInfoPage

				bindPrefix: root.bindPrefix

				Component.onCompleted: {
					settingsListView.model.append(dataManagerVersionComponent.createObject(deviceInfoPage))
				}

				Component {
					id: dataManagerVersionComponent

					ListText {
						//% "Data manager version"
						text: qsTrId("ac-in-modeldefault_data_manager_version")
						dataItem.uid: root.bindPrefix + "/DataManagerVersion"
						allowed: defaultAllowed && dataItem.isValid
					}
				}
			}
		}
	}
}
