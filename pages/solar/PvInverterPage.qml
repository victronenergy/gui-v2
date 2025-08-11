/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string serviceUid

	title: pvInverter.name

	PvInverter {
		id: pvInverter
		serviceUid: root.serviceUid
	}

	GradientListView {
		model: VisibleItemModel {
			BaseListItem {
				width: parent ? parent.width : 0
				height: phaseTable.y + phaseTable.height

				QuantityTableSummary {
					id: phaseSummary

					width: parent.width
					columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
					summaryHeaderText: pvInverter.statusCode >= 0 ? CommonWords.status : ""
					summaryModel: [
						{ text: CommonWords.energy, unit: VenusOS.Units_Energy_KiloWattHour },
						{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_AC },
						{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					bodyHeaderText: VenusOS.pvInverter_statusCodeToText(pvInverter.statusCode)
					bodyModel: QuantityObjectModel {
						QuantityObject { object: pvInverter; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
						QuantityObject { object: pvInverter; key: "voltage"; unit: VenusOS.Units_Volt_AC }
						QuantityObject { object: pvInverter; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: pvInverter; key: "power"; unit: VenusOS.Units_Watt }
					}
				}

				QuantityTable {
					id: phaseTable

					anchors {
						top: phaseSummary.bottom
						topMargin: Theme.geometry_gradientList_spacing
					}
					width: phaseSummary.width
					visible: pvInverter.phases.count > 1
					metricsFontSize: phaseSummary.metricsFontSize
					columnSpacing: phaseSummary.columnSpacing
					model: pvInverter.phases.count > 1 ? pvInverter.phases : 0

					delegate: QuantityTable.TableRow {
						id: tableRow

						required property string name
						required property real energy
						required property real voltage
						required property real current
						required property real power

						headerText: name
						model: QuantityObjectModel {
							QuantityObject { object: tableRow; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
							QuantityObject { object: tableRow; key: "voltage"; unit: VenusOS.Units_Volt_AC }
							QuantityObject { object: tableRow; key: "current"; unit: VenusOS.Units_Amp }
							QuantityObject { object: tableRow; key: "power"; unit: VenusOS.Units_Watt }
						}
					}
				}
			}

			ListPvInverterPositionRadioButtonGroup {
				dataItem.uid: pvInverter.serviceUid + "/Position"
				preferredVisible: (!positionIsAdjustable.valid || positionIsAdjustable.value === 1) ? dataItem.valid : false

				// Datapoint will exist in VM-3P75CT energy meters, but usually will not exist.
				// In cases where the data point does not exist, assume position IS adjustable.
				// Value will be zero if the position setting is not adjustable via gui-v2.
				VeQuickItem {
					id: positionIsAdjustable
					uid: pvInverter.serviceUid + "/PositionIsAdjustable"
				}
			}

			ListQuantity {
				text: "Max reported power"
				unit: VenusOS.Units_Watt
				dataItem.uid: root.pvInverter.serviceUid + "/Ac/MaxPower"
				// preferredVisible: dataItem.valid
			}

			ListQuantity {
				id: powerLimit
				text: CommonWords.dynamic_power_limit
				unit: VenusOS.Units_Watt
				dataItem.uid: root.pvInverter.serviceUid + "/Ac/PowerLimit"
				// preferredVisible: dataItem.valid
			}

			ListSwitch {
				//% "Dynamic power limiting"
				text: qsTrId("page_settings_fronius_inverter_dynamic_power_limiting")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/Inverters/I" + serial.value + "/EnableLimiter"
				// preferredVisible: powerLimit.dataItem.valid

				VeQuickItem {
					id: serial
					uid: root.pvInverter.serviceUid + "/Serial"
				}
			}

			ListAcInError {
				text: CommonWords.error
				bindPrefix: pvInverter.serviceUid
				secondaryLabel.color: pvInverter.errorCode > 0 ? Theme.color_critical : Theme.color_font_secondary
			}

			ListNavigation {
				text: CommonWords.product_page
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml",
							{ title: text, bindPrefix: pvInverter.serviceUid })
				}
			}

			SettingsListHeader {
				text: "ESS - Feed-in settings"
			}

			ListSwitch {
				id: acFeedin

				//% "AC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_ac_coupled_pv")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/PreventFeedback"
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
				invertSourceValue: true
			}

			ListSwitch {
				id: feedInDc

				//% "DC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_dc_coupled_pv")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/OvervoltageFeedIn"
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& doNotFeedInvOvervoltage.valid

				VeQuickItem {
					id: doNotFeedInvOvervoltage
					uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/DoNotFeedInOvervoltage" : ""
				}
			}

			ListSwitch {
				id: restrictFeedIn

				//% "Limit system feed-in"
				text: qsTrId("settings_ess_limit_system_feed_in")
				preferredVisible: acFeedin.checked || feedInDc.checked
				checked: maxFeedInPower.dataItem.value >= 0
				onClicked: {
					if (maxFeedInPower.dataItem.value < 0) {
						maxFeedInPower.dataItem.setValue(1000)
					} else if (maxFeedInPower.dataItem.value >= 0) {
						maxFeedInPower.dataItem.setValue(-1)
					}
				}
			}

			ListSpinBox {
				id: maxFeedInPower

				//% "Maximum feed-in"
				text: qsTrId("settings_ess_max_feed_in")
				preferredVisible: restrictFeedIn.visible && restrictFeedIn.checked
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxFeedInPower"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				from: 0
				to: 300000
				stepSize: 100
				presets: [ 0, 100, 200, 300, 500, 1000, 2000 ].map(function(v) { return { value: v } })
			}

			ListSpinBox {
				//% "Grid setpoint"
				text: qsTrId("settings_ess_grid_setpoint")
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				stepSize: 10
				presets: [ -200, -100, -50, 0, 50, 100, 200 ].map(function(v) { return { value: v } })
			}

			ListText {
				id: feedInLimitingActive
				text: "Feed-in limiting active (hub4/PvPowerLimiterActive)"
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& dataItem.valid
				dataItem.uid: BackendConnection.serviceUidForType("hub4") +"/PvPowerLimiterActive"
				secondaryText: CommonWords.yesOrNo(feedInLimitingActive.dataItem.value)
			}

			ListText {
				id: pvDisable
				text: "PV disable request (hub4/Pv/Disable)"
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& dataItem.valid
				dataItem.uid: BackendConnection.serviceUidForType("hub4") +"/Pv/Disable"
				secondaryText: CommonWords.yesOrNo(pvDisable.dataItem.value)
			}
		}
	}
}
