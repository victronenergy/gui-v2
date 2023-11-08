/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Units.js" as Units
import "../../" as SettingsPages

ObjectModel {
	id: root

	property string bindPrefix
	property int productId

	// froniusInverterProductId should always be equal to VE_PROD_ID_PV_INVERTER_FRONIUS
	readonly property int froniusInverterProductId: 0xA142
	// carloGavazziEmProductId should always be equal to VE_PROD_ID_CARLO_GAVAZZI_EM
	readonly property int carloGavazziEmProductId: 0xB002

	readonly property var nrOfPhases: DataPoint {
		source: root.bindPrefix + "/NrOfPhases"
	}

	ListTextItem {
		text: CommonWords.status
		dataSource: root.productId === froniusInverterProductId
				? root.bindPrefix + "/StatusCode"
				: ""
		visible: root.productId === froniusInverterProductId
		secondaryText: Global.pvInverters.statusCodeToText(dataValue)
	}

	ListTextItem {
		text: CommonWords.error_code
		dataSource: root.bindPrefix + "/ErrorCode"
		secondaryText: {
			if (root.productId === froniusInverterProductId) {
				return dataValue
			} else if (root.productId === carloGavazziEmProductId) {
				if (dataValue === 1) {
					//: %1 = the error number
					//% "Front selector locked (%1)"
					return qsTrId("ac-in-modeldefault_front_selector_locked").arg(dataValue)
				} else if (dataValue !== undefined) {
					//: %1 = the error number
					//% "No error (%1)"
					return qsTrId("ac-in-modeldefault_no_error").arg(dataValue)
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

				DataPoint {
					id: phaseVoltage
					source: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Voltage"
				}
				DataPoint {
					id: phaseCurrent
					source: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Current"
				}
				DataPoint {
					id: phasePower
					source: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Power"
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

		DataPoint {
			id: totalPower
			source: root.bindPrefix + "/Ac/Power"
		}

		DataPoint {
			id: totalEnergy
			source: root.bindPrefix + "/Ac/Energy/Forward"
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
				dataSource: "%1/Ac/L%2/Energy/Forward".arg(root.bindPrefix).arg(model.index + 1)
				unit: VenusOS.Units_Energy_KiloWattHour
			}
		}
	}

	ListTextItem {
		text: CommonWords.zero_feed_in_power_limit
		dataSource: root.bindPrefix + "/Ac/PowerLimit"
		visible: dataValid
	}

	ListTextItem {
		//% "Phase Sequence"
		text: qsTrId("ac-in-modeldefault_phase_sequence")
		dataSource: root.bindPrefix + "/PhaseSequence"
		visible: dataValid
		secondaryText: dataValue === 1
				  //: Phase sequence L1-L3-L2
				  //% "L1-L3-L2"
				? qsTrId("ac-in-modeldefault_phase_sequence_l3_first")
				  //: Phase sequence L1-L2-L3
				  //% "L1-L2-L3"
				: qsTrId("ac-in-modeldefault_phase_sequence_ordered")
	}

	ListNavigationItem {
		text: CommonWords.setup
		visible: allowedRoles.valid
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcInSetup.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}

		DataPoint {
			id: allowedRoles
			source: root.bindPrefix + "/AllowedRoles"
		}
	}

	ListNavigationItem {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage(deviceInfoComponent, { "title": text })
		}

		Component {
			id: deviceInfoComponent

			SettingsPages.PageDeviceInfo {
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
						dataSource: root.bindPrefix + "/DataManagerVersion"
						visible: defaultVisible && dataValid
					}
				}
			}
		}
	}
}
