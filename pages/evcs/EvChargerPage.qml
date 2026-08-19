/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an evcharger device.
*/
DevicePage {
	id: root

	required property string bindPrefix
	readonly property bool energyMeterMode: !chargeModeDC.dataItem.valid

	VeQuickItem {
		id: startStopItem
		uid: evCharger.serviceUid + "/StartStop"
	}
	VeQuickItem {
		id: enabledItem
		uid: evCharger.serviceUid + "/GxAutoMode/Enabled"
	}
	VeQuickItem {
		id: modeItem
		uid: evCharger.serviceUid + "/Mode"
	}

	serviceUid: bindPrefix

	settingsHeader: ListItem {
		id: tableListItem

		topPadding: 0
		bottomPadding: bottomInset
		leftPadding: leftInset
		rightPadding: rightInset
		contentItem: HorizontalFlickable {
			implicitHeight: phaseTable.y + phaseTable.height
			contentWidth: Math.max(Theme.geometry_quantityTable_maximumWidth_large, tableListItem.availableWidth)

			QuantityTableSummary {
				id: chargerSummary

				readonly property string currentSummaryText: {
					const actual = isNaN(evCharger.current) ? "--" : Math.round(evCharger.current)
					if (root.energyMeterMode) {
						return actual
					}
					const max = isNaN(evCharger.maxCurrent) ? "--" : Math.round(evCharger.maxCurrent)
					return actual + "/" + max
				}

				readonly property string chargingTimeText: root.energyMeterMode ? "--"
						: Utils.formatAsHHMM(evCharger.chargingTime, true)

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
					QuantityObject { object: evCharger; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: chargerSummary; key: "currentSummaryText"; unit: VenusOS.Units_Amp }
					QuantityObject { object: evCharger; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
					QuantityObject { object: chargerSummary; key: "chargingTimeText" }
				}
			}

			QuantityTable {
				id: phaseTable

				anchors.top: chargerSummary.bottom
				width: parent.width
				columnSpacing: chargerSummary.columnSpacing
				equalWidthColumns: true
				model: phaseModel.count > 1 ? phaseModel : null
				delegate: QuantityTable.TableRow {
					id: tableRow

					required property string name
					required property real power

					headerText: name
					model: QuantityObjectModel {
						// The current, energy and charging time columns are only relevant to
						// the summary and not the individual devices, so just add empty values
						// here to pad out the remaining columns.
						QuantityObject { object: tableRow; key: "power"; unit: VenusOS.Units_Watt }
						QuantityObject { hidden: true }
						QuantityObject { hidden: true }
						QuantityObject { hidden: true }
					}
				}

				PhaseModel {
					id: phaseModel
				}

				Instantiator {
					model: VeQItemSortTableModel {
						dynamicSortFilter: true
						filterRole: VeQItemTableModel.UniqueIdRole
						filterRegExp: "\/L\\d+$"
						model: VeQItemTableModel {
							uids: [ evCharger.serviceUid + "/Ac" ]
							flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
						}
					}
					delegate: QtObject {
						id: phaseObject

						required property int index
						required property string uid

						readonly property VeQuickItem _power: VeQuickItem {
							uid: phaseObject.uid + "/Power"
							onValueChanged: phaseModel.setValue(phaseObject.index, PhaseModel.PowerRole, value)
							onValidChanged: if (valid) phaseModel.phaseCount = Math.max(phaseModel.phaseCount, phaseObject.index + 1)
						}
					}
				}
			}
		}
	}

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			id: chargeModeDC
			dataItem: VeQuickItem { uid: evCharger.serviceUid + "/Mode" }
			preferredVisible: modeItem.valid
			ListRadioButtonGroup {
				id: chargeMode
				//% "Charge mode"
				text: qsTrId("evcs_charge_mode")
				dataItem.uid: evCharger.serviceUid + "/Mode"
				optionModel: Global.evChargers.modeOptionModel
				writeAccessLevel: VenusOS.User_AccessType_User
			}
		}

		DelegateComponent {
			preferredVisible: enabledItem.valid && chargeModeDC.dataItem.value === VenusOS.Evcs_Mode_Auto
			ListText {
				//% "Auto mode source"
				text: qsTrId("evcs_auto_mode_source")
				readonly property string externalSourceName: (gxAutoModeSource.value ?? "")
						//% "GX device"
						|| qsTrId("gx_device")
				//: %1 = source string from /GxAutoMode/Source, or "GX device" when not available
				//% "External (%1)"
				secondaryText: dataItem.value === 1
							   ? qsTrId("evcs_auto_mode_source_external_with_source").arg(externalSourceName)
							   //% "Internal (EV Charging Station)"
							   : qsTrId("evcs_auto_mode_source_evcs_internal")
				dataItem.uid: evCharger.serviceUid + "/GxAutoMode/Enabled"

				VeQuickItem {
					id: gxAutoModeSource
					uid: evCharger.serviceUid + "/GxAutoMode/Source"
				}
			}
		}

		DelegateComponent {
			dataItem: VeQuickItem { uid: evCharger.serviceUid + "/SetCurrent" }
			preferredVisible: dataItem.valid && chargeModeDC.dataItem.value === VenusOS.Evcs_Mode_Manual
			ListEvcsSetCurrentSpinBox {
				serviceUid: evCharger.serviceUid
				text: CommonWords.charge_current
			}
		}

		DelegateComponent {
			preferredVisible: startStopItem.valid
			ListSwitch {
				//% "Enable charging"
				text: qsTrId("evcs_enable_charging")
				dataItem.uid: evCharger.serviceUid + "/StartStop"
				writeAccessLevel: VenusOS.User_AccessType_User
			}
		}

		DelegateComponent {
			PowerGuardConsumptionSettings {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			PowerGuardProductionSettings {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			id: allowedRolesDC
			dataItem: VeQuickItem { uid: evCharger.serviceUid + "/AllowedRoles" }
			preferredVisible: !root.energyMeterMode || allowedRolesDC.dataItem.valid
			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					if (root.energyMeterMode) {
						Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcInSetup.qml",
								{ "title": text, "bindPrefix": evCharger.serviceUid, "deviceSettingsPage": root })
					} else {
						Global.pageManager.pushPage("/pages/evcs/EvChargerSetupPage.qml",
								{ "title": text, "bindPrefix": evCharger.serviceUid })
					}
				}

				VeQuickItem {
					id: allowedRoles
					uid: evCharger.serviceUid + "/AllowedRoles"
				}
			}
		}
	}

	EvCharger {
		id: evCharger
		serviceUid: root.bindPrefix
	}
}