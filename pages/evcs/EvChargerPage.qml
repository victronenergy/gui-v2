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

					function _currentSummaryText() {
						if (root.energyMeterMode) {
							return "--"
						}
						const actual = isNaN(root.evCharger.current) ? "--" : Math.round(root.evCharger.current)
						const max = isNaN(root.evCharger.maxCurrent) ? "--" : Math.round(root.evCharger.maxCurrent)
						return actual + "/" + max
					}

					metrics.equalWidthColumns: true

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
							secondaryText: Units.defaultUnitString(VenusOS.Units_Amp)
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
							text: root.energyMeterMode ? "--" : Utils.formatAsHHMM(root.evCharger.chargingTime, true),
							secondaryText: ""
						},
					]
				}

				QuantityTable {
					id: phaseTable

					anchors.top: chargerSummary.bottom
					visible: root.evCharger.phases.count > 1
					metrics.equalWidthColumns: true
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
