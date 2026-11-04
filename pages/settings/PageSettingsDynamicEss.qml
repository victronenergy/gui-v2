/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool _dessActive: dEssMode.dataItem.valid
		&& dEssMode.dataItem.value !== VenusOS.DynamicEss_Mode_Off
		&& dEssMode.dataItem.value !== VenusOS.DynamicEss_Mode_Buy
		&& dEssMode.dataItem.value !== VenusOS.DynamicEss_Mode_Sell
	readonly property bool _targetSocInUse: targetSoc.valid && targetSoc.value > 0

	VeQuickItem {
		id: targetSoc
		uid: Services.system.serviceUid + "/DynamicEss/TargetSoc"
	}

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				id: dEssMode
				text: CommonWords.mode
				dataItem.uid: Services.settings.serviceUid + "/Settings/DynamicEss/Mode"
				interactive: opportunityLoads.value !== 1
				//% "Dynamic ESS cannot be enabled while Opportunity Loads is enabled. Disable Opportunity Loads first."
				caption: !interactive ? qsTrId("settings_ess_disable_ol_first")
						//% "Dynamic ESS has not been set up yet. Set it up on the VRM Portal first."
						: !(batteryCapacity.value > 0) ? qsTrId("settings_ess_dess_setup_in_vrm")
						: ""
				optionModel: {
					let options = [
						{ display: CommonWords.off, value: VenusOS.DynamicEss_Mode_Off },
						{ display: CommonWords.auto, value: VenusOS.DynamicEss_Mode_Auto }
					]
					if (nodeRedMode.value > 0 || dataItem.value === VenusOS.DynamicEss_Mode_NodeRed) {
						options.push({ display: qsTrId("settings_large_node_red"), value: VenusOS.DynamicEss_Mode_NodeRed })
					}
					return options
				}
				currentIndex: {
					const value = dataItem.value === VenusOS.DynamicEss_Mode_Buy || dataItem.value === VenusOS.DynamicEss_Mode_Sell
						? VenusOS.DynamicEss_Mode_Off
						: dataItem.value
					return optionModel.findIndex(option => option.value === value)
				}

				VeQuickItem {
					id: opportunityLoads
					uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
				}

				VeQuickItem {
					id: batteryCapacity
					uid: Services.settings.serviceUid + "/Settings/DynamicEss/BatteryCapacity"
				}

				VeQuickItem {
					id: nodeRedMode
					uid: Services.platform.serviceUid + "/Services/NodeRed/Mode"
				}
			}

			ListTextStatus {
				readonly property real scheduleAge: windowSlot.valid && windowSlot.value >= 0
						&& lastScheduledStart.valid && lastScheduledEnd.valid
					? windowSlot.value * (lastScheduledEnd.value - lastScheduledStart.value)
					: 0
				readonly property bool scheduleOutdated: dEssMode.dataItem.value === VenusOS.DynamicEss_Mode_Auto
					&& scheduleAge >= 90 * 60

				text: CommonWords.status
				preferredVisible: root._dessActive
				dataItem.uid: Services.system.serviceUid + "/DynamicEss/ReactiveStrategy"
				secondaryText: dataItem.valid ? VenusOS.dynamicEss_reactiveStrategyToText(dataItem.value) : CommonWords.inactive_status
				alarmStatus: scheduleOutdated ? VenusOS.Alarm_Level_Warning : -1
				caption: scheduleOutdated
						//: %1 = how long ago, e.g. "2h 0m"
						//% "The schedule from VRM has not been updated for at least %1. Dynamic ESS keeps following the last schedule it received."
						? qsTrId("settings_ess_dess_schedule_not_updated").arg(Utils.secondsToString(scheduleAge, false))
						: ""

				VeQuickItem {
					id: windowSlot
					uid: Services.system.serviceUid + "/DynamicEss/WindowSlot"
				}

				VeQuickItem {
					id: lastScheduledStart
					uid: Services.system.serviceUid + "/DynamicEss/LastScheduledStart"
				}

				VeQuickItem {
					id: lastScheduledEnd
					uid: Services.system.serviceUid + "/DynamicEss/LastScheduledEnd"
				}
			}

			ListDynamicEssError {
				preferredVisible: root._dessActive && hasError
					&& dataItem.value !== VenusOS.DynamicEss_ErrorCode_BatteryCapacityUnset
				dataItem.uid: Services.system.serviceUid + "/DynamicEss/ErrorCode"
				dessMode: dEssMode.dataItem.value ?? VenusOS.DynamicEss_Mode_Auto
			}

			ListQuantity {
				text: CommonWords.state_of_charge
				preferredVisible: root._dessActive
				value: Services.system.battery.stateOfCharge
				unit: VenusOS.Units_Percentage
			}

			ListQuantity {
				//% "Target SOC"
				text: qsTrId("settings_ess_target_soc")
				preferredVisible: root._dessActive && root._targetSocInUse
				value: targetSoc.value
				unit: VenusOS.Units_Percentage
			}
		}
	}
}
