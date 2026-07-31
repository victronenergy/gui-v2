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
	readonly property bool energyMeterMode: !chargeMode.dataItem.valid

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

	settingsModel: VisibleItemModel {
		ListRadioButtonGroup {
			id: chargeMode
			//% "Charge mode"
			text: qsTrId("evcs_charge_mode")
			dataItem.uid: evCharger.serviceUid + "/Mode"
			preferredVisible: dataItem.valid
			optionModel: Global.evChargers.modeOptionModel
			writeAccessLevel: VenusOS.User_AccessType_User
		}

		ListText {
			//% "Auto mode source"
			text: qsTrId("evcs_auto_mode_source")
			//% "Internal (EV Charging Station)"
			readonly property string evcsInternalText: qsTrId("evcs_auto_mode_source_evcs_internal")
			readonly property string externalSourceName: {
				if (gxAutoModeSource.valid && gxAutoModeSource.value !== undefined && gxAutoModeSource.value !== null) {
					const sourceText = String(gxAutoModeSource.value).trim()
					if (sourceText.length > 0) {
						return sourceText
					}
				}
				//% "GX device"
				return qsTrId("gx_device")
			}
			//: %1 = source string from /GxAutoMode/Source, or "GX" when not available
			//% "External (%1)"
			secondaryText: Number(dataItem.value) === 1
						   ? qsTrId("evcs_auto_mode_source_external_with_source").arg(externalSourceName)
						   : evcsInternalText
			dataItem.uid: evCharger.serviceUid + "/GxAutoMode/Enabled"
			preferredVisible: dataItem.valid && Number(chargeMode.dataItem.value) === VenusOS.Evcs_Mode_Auto

			VeQuickItem {
				id: gxAutoModeSource
				uid: evCharger.serviceUid + "/GxAutoMode/Source"
			}
		}

		ListEvcsSetCurrentSpinBox {
			serviceUid: evCharger.serviceUid
			text: CommonWords.charge_current
			preferredVisible: dataItem.valid && chargeMode.dataItem.value === VenusOS.Evcs_Mode_Manual
		}

		ListSwitch {
			//% "Enable charging"
			text: qsTrId("evcs_enable_charging")
			dataItem.uid: evCharger.serviceUid + "/StartStop"
			preferredVisible: dataItem.valid
			writeAccessLevel: VenusOS.User_AccessType_User
		}

		PowerGuardConsumptionSettings {
			bindPrefix: root.bindPrefix
		}

		PowerGuardProductionSettings {
			bindPrefix: root.bindPrefix
		}

		ListNavigation {
			text: CommonWords.setup
			preferredVisible: !root.energyMeterMode || allowedRoles.valid
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

	EvCharger {
		id: evCharger
		serviceUid: root.bindPrefix
	}
}
