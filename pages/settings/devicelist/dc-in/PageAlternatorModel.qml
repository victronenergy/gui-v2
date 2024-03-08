/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ObjectModel {
	id: root

	property string bindPrefix

	ListSwitch {
		text: CommonWords.switch_mode
		dataItem.uid: root.bindPrefix + "/Mode"
		valueTrue: 1
		valueFalse: 4
		visible: defaultVisible && dataItem.isValid
	}

	ListQuantityGroup {
		//% "Input"
		text: qsTrId("alternator_wakespeed_input")
		visible: defaultVisible && (inVoltage.isValid || inPower.isValid)
		textModel: [
			{ value: inVoltage.value, unit: VenusOS.Units_Volt, visible: inVoltage.isValid },
			{ value: inCurrent.value, unit: VenusOS.Units_Amp, visible: inCurrent.isValid },
			{ value: inPower.value, unit: VenusOS.Units_Watt, visible: inPower.isValid },
		]

		VeQuickItem {
			id: inVoltage
			uid: root.bindPrefix + "/Dc/In/V"
		}
		VeQuickItem {
			id: inCurrent
			uid: root.bindPrefix + "/Dc/In/I"
		}
		VeQuickItem {
			id: inPower
			uid: root.bindPrefix + "/Dc/In/P"
		}
	}

	ListQuantityGroup {
		//% "Output"
		text: qsTrId("alternator_wakespeed_output")
		textModel: [
			{ value: dcVoltage.value, unit: VenusOS.Units_Volt },
			{ value: dcCurrent.value, unit: VenusOS.Units_Amp, visible: dcCurrent.isValid },
			{ value: dcPower.value, unit: VenusOS.Units_Watt, visible: dcPower.isValid },
		]

		VeQuickItem {
			id: dcVoltage
			uid: root.bindPrefix + "/Dc/0/Voltage"
		}
		VeQuickItem {
			id: dcCurrent
			uid: root.bindPrefix + "/Dc/0/Current"
		}
		VeQuickItem {
			id: dcPower
			uid: root.bindPrefix + "/Dc/0/Power"
		}
	}

	ListTemperatureItem {
		text: CommonWords.temperature
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		visible: defaultVisible && dataItem.isValid
	}

	ListTextItem {
		text: CommonWords.state
		secondaryText: Global.system.systemStateToText(dataItem.value)
		dataItem.uid: root.bindPrefix + "/State"
	}

	ListTextItem {
		text: CommonWords.network_status
		secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
		dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
		visible: defaultVisible && dataItem.isValid
	}

	ListTextItem {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/ErrorCode"
		visible: defaultVisible && dataItem.isValid
		secondaryText: dataItem.isValid ? ChargerError.description(dataItem.value) : dataItem.invalidText
	}

	ListTextItem {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/Error/0/Id"
		visible: defaultVisible && dataItem.isValid
		secondaryText: dataItem.isValid ? AlternatorError.description(dataItem.value) : dataItem.invalidText
	}

	ListQuantityItem {
		//% "Field drive"
		text: qsTrId("alternator_wakespeed_field_drive")
		dataItem.uid: root.bindPrefix + "/FieldDrive"
		unit: VenusOS.Units_Percentage
		visible: defaultVisible && dataItem.isValid
	}

	ListQuantityItem {
		text: CommonWords.speed
		dataItem.uid: root.bindPrefix + "/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		visible: defaultVisible && dataItem.isValid
	}

	ListQuantityItem {
		//% "Engine speed"
		text: qsTrId("alternator_wakespeed_engine_speed")
		dataItem.uid: root.bindPrefix + "/Engine/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		visible: defaultVisible && dataItem.isValid
	}

	ListNavigationItem {
		text: CommonWords.overall_history
		onClicked: {
			Global.pageManager.pushPage(overallHistoryComponent, { "title": text })
		}

		Component {
			id: overallHistoryComponent

			Page {
				GradientListView {
					model: ObjectModel {
						ListTextItem {
							//% "Operation time"
							text: qsTrId("alternator_wakespeed_operation_time")
							secondaryText: Utils.secondsToString(dataItem.value, true)
							dataItem.uid: root.bindPrefix + "/History/Cumulative/User/OperationTime"
							visible: defaultVisible && dataItem.isValid
						}

						ListQuantityItem {
							//% "Charged Ah"
							text: qsTrId("alternator_wakespeed_charged_ah")
							dataItem.uid: root.bindPrefix + "/History/Cumulative/User/ChargedAh"
							unit: VenusOS.Units_AmpHour
							precision: 0
							visible: defaultVisible && dataItem.isValid
						}

						ListTextItem {
							//% "Cycles started"
							text: qsTrId("alternator_wakespeed_cycles_started")
							dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesStarted"
							visible: defaultVisible && dataItem.isValid
						}

						ListTextItem {
							//% "Cycles completed"
							text: qsTrId("alternator_wakespeed_cycles_completed")
							dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesCompleted"
							visible: defaultVisible && dataItem.isValid
						}

						ListTextItem {
							//% "Number of power-ups"
							text: qsTrId("alternator_wakespeed_nr_of_power_ups")
							dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfPowerups"
							visible: defaultVisible && dataItem.isValid
						}

						ListTextItem {
							//% "Number of deep discharges"
							text: qsTrId("alternator_wakespeed_nr_of_deep_discharges")
							dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfDeepDischarges"
							visible: defaultVisible && dataItem.isValid
						}
					}
				}
			}
		}
	}

	ListNavigationItem {
		//% "Charge cycle history"
		text: qsTrId("alternator_wakespeed_charge_cycle_history")
		visible: historyCyclesAvailable.isValid
		onClicked: {
			Global.pageManager.pushPage(chargeHistoryComponent, { "title": text })
		}

		Component {
			id: chargeHistoryComponent

			Page {
				GradientListView {
					model: historyCyclesAvailable.isValid ? historyCyclesAvailable.value + 1 : 1
					delegate: Component {
						ListCycleHistoryItem {
							width: parent ? parent.width : 0
							bindPrefix: root.bindPrefix + "/History/Cycle/" + index
							cycle: index
						}
					}
				}
			}
		}

		VeQuickItem {
			id: historyCyclesAvailable
			uid: root.bindPrefix + "/History/Cycle/CyclesAvailable"
		}
	}

	ListNavigationItem {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
