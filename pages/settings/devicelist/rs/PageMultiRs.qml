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

	property string bindPrefix
	readonly property bool multiPhase: numberOfPhases.valid && numberOfPhases.value >= 2 && !_phase.valid
	readonly property int trackerCount: numberOfTrackers.value || 0

	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Dc/0/Temperature"
	}
	VeQuickItem {
		id: numberOfPhases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}
	VeQuickItem {
		id: _phase
		uid: root.bindPrefix + "/Settings/System/AcPhase"
	}
	VeQuickItem {
		id: numberOfTrackers
		uid: root.bindPrefix + "/NrOfTrackers"
	}
	VeQuickItem {
		id: pvTotalPower
		uid: root.bindPrefix + "/Yield/Power"
	}
	VeQuickItem {
		id: pvVoltage
		uid: root.bindPrefix + "/Pv/V"
	}

	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			ListText {
				text: CommonWords.state
				secondaryText: VenusOS.system_stateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}
		}

		DelegateComponent {
			ListQuantity {
				text: CommonWords.state_of_charge
				dataItem.uid: root.bindPrefix + "/Soc"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid
			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
			}
		}

		DelegateComponent {
			ListActiveAcInput {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			Loader {
				width: parent ? parent.width : 0
				sourceComponent: root.multiPhase ? threePhaseTables : singlePhaseAcInOut
			}
		}

		DelegateComponent {
			ListDcOutputQuantityGroup {
				text: CommonWords.dc
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			ListItemLoader {
				width: parent ? parent.width : 0
				sourceComponent: root.trackerCount === 1 ? singleTrackerComponent
						: root.trackerCount > 1 ? multiTrackerComponent
						: null
			}
		}

		DelegateComponent {
			preferredVisible: root.trackerCount > 0
			ListQuantity {
				//% "Total yield"
				text: qsTrId("settings_multirs_total_yield")
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/User"
			}
		}

		DelegateComponent {
			preferredVisible: root.trackerCount > 0
			ListQuantity {
				//% "System yield"
				text: qsTrId("settings_multirs_system_yield")
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/System"
			}
		}

		DelegateComponent {
			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
			}
		}

		DelegateComponent {
			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}
		}

		DelegateComponent {
			preferredVisible: root.trackerCount > 0
			ListNavigation {
				text: CommonWords.daily_history
				onClicked: {
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "serviceUid": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			preferredVisible: root.trackerCount > 0
			ListNavigation {
				text: CommonWords.overall_history
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.alarm_status
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
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
				data: AcPhase { serviceUid: root.bindPrefix + "/Ac/In/1/" + singlePhaseName }
			}

			PVCFListQuantityGroup {
				//: %1 = phase name (e.g. L1, L2, L3)
				//% "AC out %1"
				text: qsTrId("settings_multirs_ac_out_phase").arg(singlePhaseName)
				data: AcPhase { serviceUid: root.bindPrefix + "/Ac/Out/" + singlePhaseName }
			}
		}
	}

	Component {
		id: threePhaseTables

		ThreePhaseIOTable {
			width: parent ? parent.width : 0
			phaseCount: numberOfPhases.value || 0
			inputPhaseUidPrefix: root.bindPrefix + "/Ac/In/1"
			outputPhaseUidPrefix: root.bindPrefix + "/Ac/Out"
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
				//% "Total PV Power"
				text: qsTrId("settings_multirs_total_pv_power")
				dataItem.uid: root.bindPrefix + "/Yield/Power"
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
							serviceUid: root.bindPrefix
							trackerIndex: tableRow.index
							trackerCount: root.trackerCount
						}
					}
				}
			}
		}
	}
}