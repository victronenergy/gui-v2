/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a Multi RS device.
*/
DevicePage {
	id: root

	property string bindPrefix
	readonly property bool multiPhase: numberOfPhases.valid && numberOfPhases.value >= 2 && !_phase.valid
	readonly property int trackerCount: numberOfTrackers.value || 0

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListText {
			text: CommonWords.state
			secondaryText: Global.system.systemStateToText(dataItem.value)
			dataItem.uid: root.bindPrefix + "/State"
		}

		ListQuantity {
			text: CommonWords.state_of_charge
			dataItem.uid: root.bindPrefix + "/Soc"
			unit: VenusOS.Units_Percentage
		}

		ListTemperature {
			text: CommonWords.battery_temperature
			dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
			preferredVisible: dataItem.valid
		}

		ListActiveAcInput {
			bindPrefix: root.bindPrefix
		}

		Loader {
			width: parent ? parent.width : 0
			sourceComponent: root.multiPhase ? threePhaseTables : singlePhaseAcInOut
		}

		ListDcOutputQuantityGroup {
			text: CommonWords.dc
			bindPrefix: root.bindPrefix
		}

		Loader {
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
			dataItem.uid: root.bindPrefix + "/Yield/User"
		}

		ListQuantity {
			//% "System yield"
			text: qsTrId("settings_multirs_system_yield")
			preferredVisible: root.trackerCount > 0
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.bindPrefix + "/Yield/System"
		}

		ListText {
			text: CommonWords.error
			dataItem.uid: root.bindPrefix + "/ErrorCode"
			secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
		}

		ListRelayState {
			dataItem.uid: root.bindPrefix + "/Relay/0/State"
		}

		ListNavigation {
			text: CommonWords.daily_history
			preferredVisible: root.trackerCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
						{ "solarHistory": solarDevice.history })
			}
		}

		ListNavigation {
			text: CommonWords.overall_history
			preferredVisible: root.trackerCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}

		ListNavigation {
			text: CommonWords.alarm_status
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}
	}

	SolarDevice {
		id: solarDevice
		serviceUid: root.bindPrefix
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
			voltPrecision: 1
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
				//% "Trackers"
				text: qsTrId("settings_multirs_trackers")

				bottomContentChildren: [
					QuantityTable {
						width: parent.width
						model: root.trackerCount
						delegate: QuantityTable.TableRow {
							id: tableRow
							preferredVisible: tracker.enabled
							headerText: Global.solarInputs.formatTrackerName(
									  tracker.name, index, root.trackerCount, root.title,
									  VenusOS.TrackerName_NoDevicePrefix)
							model: QuantityObjectModel {
								QuantityObject { object: tracker; key: "voltage"; unit: VenusOS.Units_Volt_DC }
								QuantityObject { object: tracker; key: "current"; unit: VenusOS.Units_Amp }
								QuantityObject { object: tracker; key: "power"; unit: VenusOS.Units_Watt }
							}

							SolarTracker {
								id: tracker
								device: solarDevice
								trackerIndex: tableRow.index
							}
						}
					}
				]
			}
		}
	}
}
