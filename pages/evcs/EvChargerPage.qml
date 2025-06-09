/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix
	readonly property var evCharger: Global.evChargers.model.deviceAt(Global.evChargers.model.indexOf(bindPrefix))
	readonly property bool energyMeterMode: !chargeMode.dataItem.valid

	title: evCharger.name

	GradientListView {
		model: VisibleItemModel {
			BaseListItem {
				width: parent ? parent.width : 0
				height: phaseTable.y + phaseTable.height

				QuantityTableSummary {
					id: chargerSummary

					readonly property string currentSummaryText: {
						if (root.energyMeterMode) {
							return "--"
						}
						const actual = isNaN(root.evCharger.current) ? "--" : Math.round(root.evCharger.current)
						const max = isNaN(root.evCharger.maxCurrent) ? "--" : Math.round(root.evCharger.maxCurrent)
						return actual + "/" + max
					}

					readonly property string chargingTimeText: root.energyMeterMode ? "--"
							: Utils.formatAsHHMM(root.evCharger.chargingTime, true)

					width: parent.width
					columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
					equalWidthColumns: true
					//% "Session"
					summaryHeaderText: qsTrId("evcs_session")
					summaryModel: [
						{ text: CommonWords.power_watts, unit: VenusOS.Units_None },
						{ text: CommonWords.current_amps, unit: VenusOS.Units_None },
						{ text: CommonWords.energy, unit: VenusOS.Units_None },
						//: Charging time for the EV charger
						//% "Time"
						{ text: qsTrId("evcs_charging_time"), unit: VenusOS.Units_None },
					]
					bodyHeaderText: CommonWords.total
					bodyModel: QuantityObjectModel {
						QuantityObject { object: root.evCharger; key: "power"; unit: VenusOS.Units_Watt }
						QuantityObject { object: chargerSummary; key: "currentSummaryText"; unit: VenusOS.Units_Amp }
						QuantityObject { object: root.evCharger; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
						QuantityObject { object: chargerSummary; key: "chargingTimeText" }
					}
				}

				QuantityTable {
					id: phaseTable

					anchors.top: chargerSummary.bottom
					width: chargerSummary.width
					columnSpacing: chargerSummary.columnSpacing
					visible: root.evCharger.phases.count > 1
					equalWidthColumns: true
					model: root.evCharger.phases.count > 1 ? root.evCharger.phases.count : 0
					delegate: QuantityTable.TableRow {
						readonly property QtObject phase: root.evCharger.phases.get(index)

						headerText: phase.name
						model: QuantityObjectModel {
							QuantityObject { object: phase; key: "power"; unit: VenusOS.Units_Watt }

							// The current, energy and charging time columns are only relevant to
							// the summary and not the individual devices, so just add empty values
							// here to pad out the remaining columns.
							QuantityObject {}
							QuantityObject {}
							QuantityObject {}
						}
					}
				}
			}

			ListRadioButtonGroup {
				id: chargeMode
				//% "Charge mode"
				text: qsTrId("evcs_charge_mode")
				dataItem.uid: root.evCharger.serviceUid + "/Mode"
				preferredVisible: dataItem.valid
				optionModel: Global.evChargers.modeOptionModel
			}

			ListSpinBox {
				text: CommonWords.charge_current
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				from: 0
				to: root.evCharger.maxCurrent
				dataItem.uid: root.evCharger.serviceUid + "/SetCurrent"
				preferredVisible: dataItem.valid
				interactive: dataItem.valid && chargeMode.dataItem.value === VenusOS.Evcs_Mode_Manual
			}

			ListSwitch {
				//% "Enable charging"
				text: qsTrId("evcs_enable_charging")
				dataItem.uid: root.evCharger.serviceUid + "/StartStop"
				preferredVisible: dataItem.valid
			}

			ListNavigation {
				text: CommonWords.setup
				preferredVisible: !root.energyMeterMode || allowedRoles.valid
				onClicked: {
					if (root.energyMeterMode) {
						Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcInSetup.qml",
								{ "title": text, "bindPrefix": root.evCharger.serviceUid })
					} else {
						Global.pageManager.pushPage("/pages/evcs/EvChargerSetupPage.qml",
								{ "title": text, "bindPrefix": root.evCharger.serviceUid })
					}
				}

				VeQuickItem {
					id: allowedRoles
					uid: root.evCharger.serviceUid + "/AllowedRoles"
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.evCharger.serviceUid })
				}
			}
		}
	}
}
