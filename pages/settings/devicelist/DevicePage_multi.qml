/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Provides a list of settings for a Multi RS device.
*/
DevicePage {
	id: root

	readonly property bool multiPhase: numberOfPhases.valid && numberOfPhases.value >= 2 && !_phase.valid
	readonly property int trackerCount: numberOfTrackers.value || 0

	settingsModel: VisibleItemModel {
		ListText {
			text: CommonWords.state
			secondaryText: VenusOS.system_stateToText(dataItem.value)
			dataItem.uid: root.serviceUid + "/State"
		}

		ListQuantity {
			text: CommonWords.state_of_charge
			dataItem.uid: root.serviceUid + "/Soc"
			unit: VenusOS.Units_Percentage
		}

		ListTemperature {
			text: CommonWords.battery_temperature
			dataItem.uid: root.serviceUid + "/Dc/0/Temperature"
			preferredVisible: dataItem.valid
		}

		ListActiveAcInput {
			bindPrefix: root.serviceUid
		}

		Loader {
			width: parent ? parent.width : 0
			sourceComponent: root.multiPhase ? threePhaseTables : singlePhaseAcInOut
		}

		ListDcOutputQuantityGroup {
			text: CommonWords.dc
			bindPrefix: root.serviceUid
		}

		ListItemLoader {
			width: parent ? parent.width : 0
			sourceComponent: root.trackerCount === 1 ? singleTrackerComponent
					: root.trackerCount > 1 ? multiTrackerComponent
					: null
		}

		ListQuantity {
			//% "Total yield"
			text: qsTrId("settings_multirs_total_yield")
			preferredVisible: root.trackerCount > 0
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.serviceUid + "/Yield/User"
		}

		ListQuantity {
			//% "System yield"
			text: qsTrId("settings_multirs_system_yield")
			preferredVisible: root.trackerCount > 0
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.serviceUid + "/Yield/System"
		}

		ListText {
			text: CommonWords.error
			dataItem.uid: root.serviceUid + "/ErrorCode"
			secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
		}

		ListRelayState {
			dataItem.uid: root.serviceUid + "/Relay/0/State"
		}

		ListNavigation {
			text: CommonWords.daily_history
			preferredVisible: root.trackerCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
						{ "serviceUid": root.serviceUid })
			}
		}

		ListNavigation {
			text: CommonWords.overall_history
			preferredVisible: root.trackerCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}

		ListNavigation {
			text: CommonWords.alarm_status
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}
	}

	VeQuickItem {
		id: numberOfPhases
		uid: root.serviceUid + "/Ac/NumberOfPhases"
	}

	VeQuickItem {
		id: _phase
		uid: root.serviceUid + "/Settings/System/AcPhase"
	}

	VeQuickItem {
		id: numberOfTrackers
		uid: root.serviceUid + "/NrOfTrackers"
	}

	VeQuickItem {
		id: pvTotalPower
		uid: root.serviceUid + "/Yield/Power"
	}

	VeQuickItem {
		id: pvVoltage
		uid: root.serviceUid + "/Pv/V"
	}

	Component {
		id: singlePhaseAcInOut

		SettingsColumn {
			readonly property string singlePhaseName: _phase.value === 2 ? "L3"
					: _phase.value === 1 ? "L2"
					: "L1"  // _phase.value === 0 || !_phase.valid

			PVCFListQuantityGroup {
				//: %1 = phase name (e.g. L1, L2, L3)
				//% "AC in %1"
				text: qsTrId("settings_multirs_ac_in_phase").arg(singlePhaseName)
				data: AcPhase { serviceUid: root.serviceUid + "/Ac/In/1/" + singlePhaseName }
			}

			PVCFListQuantityGroup {
				//: %1 = phase name (e.g. L1, L2, L3)
				//% "AC out %1"
				text: qsTrId("settings_multirs_ac_out_phase").arg(singlePhaseName)
				data: AcPhase { serviceUid: root.serviceUid + "/Ac/Out/" + singlePhaseName }
			}
		}
	}

	Component {
		id: threePhaseTables

		ThreePhaseIOTable {
			width: parent ? parent.width : 0
			phaseCount: numberOfPhases.value || 0
			inputPhaseUidPrefix: root.serviceUid + "/Ac/In/1"
			outputPhaseUidPrefix: root.serviceUid + "/Ac/Out"
			voltDecimals: 1
		}
	}

	Component {
		id: singleTrackerComponent

		ListQuantityGroup {
			id: singleTrackerQuantities

			readonly property real pvCurrent: (pvVoltage.value || 0) === 0 || !pvTotalPower.valid ? NaN
					: pvTotalPower.value / pvVoltage.value

			//% "PV"
			text: qsTrId("settings_multirs_pv")
			model: QuantityObjectModel {
				filterType: QuantityObjectModel.HasValue

				QuantityObject { object: pvVoltage; unit: VenusOS.Units_Volt_DC; defaultValue: "--" }
				QuantityObject { object: singleTrackerQuantities; key: "pvCurrent"; unit: VenusOS.Units_Amp }
				QuantityObject { object: pvTotalPower; unit: VenusOS.Units_Watt; defaultValue: "--" }
			}
		}
	}

	Component {
		id: multiTrackerComponent

		SettingsColumn {
			width: parent ? parent.width : 0

			ListQuantity {
				//% "Total PV power"
				text: qsTrId("settings_multirs_total_pv_power")
				dataItem.uid: root.serviceUid + "/Yield/Power"
				unit: VenusOS.Units_Watt
			}

			ListItem {
				id: trackerTableItem

				// Remove horizontal padding to allow QuantityTable row background colours to
				// stretch to the left/right edges of the view.
				topPadding: 0
				bottomPadding: bottomInset
				leftPadding: leftInset
				rightPadding: rightInset
				contentItem: QuantityTable {
					model: root.trackerCount
					header: QuantityTable.TableHeader {
						headerText: CommonWords.tracker
						model: [
							{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
							{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
							{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt }
						]
					}
					delegate: QuantityTable.TableRow {
						id: tableRow
						preferredVisible: tracker.enabled
						headerText: tracker.name
						model: QuantityObjectModel {
							QuantityObject { object: tracker; key: "voltage"; unit: VenusOS.Units_Volt_DC }
							QuantityObject { object: tracker; key: "current"; unit: VenusOS.Units_Amp }
							QuantityObject { object: tracker; key: "power"; unit: VenusOS.Units_Watt }
						}

						SolarTracker {
							id: tracker
							serviceUid: root.serviceUid
							trackerIndex: tableRow.index
							trackerCount: root.trackerCount
						}
					}
				}
			}
		}
	}
}
