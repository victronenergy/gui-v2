/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property var evCharger

	title: evCharger.name

	GradientListView {
		model: ObjectModel {
			ListItemBackground {
				height: phaseTable.y + phaseTable.height

				QuantityTableSummary {
					id: chargerSummary

					function _currentSummaryText() {
						const actual = isNaN(root.evCharger.current) ? "--" : Math.round(root.evCharger.current)
						const max = isNaN(root.evCharger.maxCurrent) ? "--" : Math.round(root.evCharger.maxCurrent)
						return actual + "/" + max
					}

					x: Theme.geometry.listItem.content.horizontalMargin
					width: parent.width - Theme.geometry.listItem.content.horizontalMargin
					equalWidthColumns: true

					model: [
						{
							//% "Session"
							title: qsTrId("evcs_session"),
							text: CommonWords.total,
							unit: VenusOS.Units_None,
						},
						{
							title: CommonWords.power_watts,
							value: root.evCharger.power,
							unit: VenusOS.Units_Watt
						},
						{
							title: CommonWords.current_amps,
							text: _currentSummaryText(),
							secondaryText: "A"
						},
						{
							title: CommonWords.energy,
							value: root.evCharger.energy,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							//: Charging time for the EV charger
							//% "Time"
							title: qsTrId("evcs_charging_time"),
							text: Utils.formatAsHHMM(root.evCharger.chargingTime, true),
							secondaryText: ""
						},
					]
				}

				QuantityTable {
					id: phaseTable

					anchors {
						top: chargerSummary.bottom
						topMargin: Theme.geometry.gradientList.spacing
					}
					visible: root.evCharger.phases.count > 1
					equalWidthColumns: true
					headerVisible: false

					rowCount: root.evCharger.phases.count
					units: [
						{ title: "", unit: VenusOS.Units_None },
						{ title: "", unit: VenusOS.Units_Watt },
						{ title: "", unit: VenusOS.Units_None },
						{ title: "", unit: VenusOS.Units_None },
						{ title: "", unit: VenusOS.Units_None },
					]
					valueForModelIndex: function(phaseIndex, column) {
						const phase = root.evCharger.phases.get(phaseIndex)
						if (column === 0) {
							return phase.name
						} else if (column === 1) {
							return phase.power
						} else {
							return 0
						}
					}
				}
			}

			Item {
				width: 1
				height: Theme.geometry.gradientList.spacing
			}

			ListRadioButtonGroup {
				//% "Charge mode"
				text: qsTrId("evcs_charge_mode")
				dataSource: root.evCharger.serviceUid + "/Mode"
				optionModel: [
					{
						display: Global.evChargers.chargerModeToText(VenusOS.Evcs_Mode_Manual),
						value: VenusOS.Evcs_Mode_Manual,
						//% "Start and stop the process yourself. Use this for quick charges and close monitoring."
						caption: qsTrId("evcs_manual_caption")
					},
					{
						display: Global.evChargers.chargerModeToText(VenusOS.Evcs_Mode_Auto),
						value: VenusOS.Evcs_Mode_Auto,
						//% "Starts and stops based on the battery charge level. Optimal for overnight and extended charges to avoid overcharging."
						caption: qsTrId("evcs_auto_caption")
					},
					{
						display: Global.evChargers.chargerModeToText(VenusOS.Evcs_Mode_Scheduled),
						value: VenusOS.Evcs_Mode_Scheduled,
						//% "Lower electricity rates during off-peak hours or if you want to ensure that your EV is fully charged and ready to go at a specific time."
						caption: qsTrId("evcs_scheduled_caption")
					},
				]
			}

			ListSpinBox {
				//% "Charge current"
				text: qsTrId("evcs_charge_current")
				suffix: "A"
				from: 0
				to: root.evCharger.maxCurrent
				dataSource: root.evCharger.serviceUid + "/Current"
			}

			ListSwitch {
				//% "Enable charging"
				text: qsTrId("evcs_enable_charging")
				dataSource: root.evCharger.serviceUid + "/StartStop"
			}

			ListNavigationItem {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/evcs/EvChargerSetupPage.qml",
							{ "title": text, "evCharger": root.evCharger })
				}
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.evCharger.serviceUid })
				}
			}
		}
	}
}
