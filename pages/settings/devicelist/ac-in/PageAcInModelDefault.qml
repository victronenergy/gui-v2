/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

ObjectModel {
	id: root

	property string bindPrefix
	property int productId

	// froniusInverterProductId should always be equal to VE_PROD_ID_PV_INVERTER_FRONIUS
	readonly property int froniusInverterProductId: 0xA142
	// carloGavazziEmProductId should always be equal to VE_PROD_ID_CARLO_GAVAZZI_EM
	readonly property int carloGavazziEmProductId: 0xB002

	readonly property var nrOfPhases: VeQuickItem {
		uid: root.bindPrefix + "/NrOfPhases"
	}

	ListTextItem {
		text: CommonWords.status
		dataItem.uid: root.productId === froniusInverterProductId
				? root.bindPrefix + "/StatusCode"
				: ""
		visible: root.productId === froniusInverterProductId
		secondaryText: Global.pvInverters.statusCodeToText(dataItem.value)
	}

	ListTextItem {
		text: CommonWords.error_code
		dataItem.uid: root.bindPrefix + "/ErrorCode"
		secondaryText: {
			if (root.productId === froniusInverterProductId) {
				return dataItem.value
			} else if (root.productId === carloGavazziEmProductId) {
				if (dataItem.value === 1) {
					//: %1 = the error number
					//% "Front selector locked (%1)"
					return qsTrId("ac-in-modeldefault_front_selector_locked").arg(dataItem.value)
				} else if (dataItem.value !== undefined) {
					//: %1 = the error number
					//% "No error (%1)"
					return qsTrId("ac-in-modeldefault_no_error").arg(dataItem.value)
				}
			}
			return ""
		}
		visible: root.productId === froniusInverterProductId
				|| root.productId === carloGavazziEmProductId
	}

	Column {
		width: parent ? parent.width : 0

		Repeater {
			model: nrOfPhases.value || 3
			delegate: ListQuantityGroup {
				text: CommonWords.ac_phase_x.arg(model.index + 1)
				textModel: [
					{ value: phaseVoltage.value, unit: VenusOS.Units_Volt },
					{ value: phaseCurrent.value, unit: VenusOS.Units_Amp },
					{ value: phasePower.value, unit: VenusOS.Units_Watt },
				]

				VeQuickItem {
					id: phaseVoltage
					uid: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Voltage"
				}
				VeQuickItem {
					id: phaseCurrent
					uid: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Current"
				}
				VeQuickItem {
					id: phasePower
					uid: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Power"
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
			model: nrOfPhases.value || 3
			delegate: ListQuantityItem {
				//: %1 = phase number (1-3)
				//% "Energy L%1"
				text: qsTrId("ac-in-modeldefault_energy_x").arg(model.index + 1)
				dataItem.uid: "%1/Ac/L%2/Energy/Forward".arg(root.bindPrefix).arg(model.index + 1)
				unit: VenusOS.Units_Energy_KiloWattHour
			}
		}
	}

	ListTextItem {
		text: CommonWords.zero_feed_in_power_limit
		dataItem.uid: root.bindPrefix + "/Ac/PowerLimit"
		visible: dataItem.isValid
	}

	ListTextItem {
		//% "Phase Sequence"
		text: qsTrId("ac-in-modeldefault_phase_sequence")
		dataItem.uid: root.bindPrefix + "/PhaseSequence"
		visible: dataItem.isValid
		secondaryText: dataItem.value === 1
				  //: Phase sequence L1-L3-L2
				  //% "L1-L3-L2"
				? qsTrId("ac-in-modeldefault_phase_sequence_l3_first")
				  //: Phase sequence L1-L2-L3
				  //% "L1-L2-L3"
				: qsTrId("ac-in-modeldefault_phase_sequence_ordered")
	}

	ListNavigationItem {
		text: CommonWords.setup
		visible: allowedRoles.isValid
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcInSetup.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}

		VeQuickItem {
			id: allowedRoles
			uid: root.bindPrefix + "/AllowedRoles"
		}
	}

	ListNavigationItem {
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

					ListTextItem {
						//% "Data manager version"
						text: qsTrId("ac-in-modeldefault_data_manager_version")
						dataItem.uid: root.bindPrefix + "/DataManagerVersion"
						visible: defaultVisible && dataItem.isValid
					}
				}
			}
		}
	}
}
