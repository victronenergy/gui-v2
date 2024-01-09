/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property int hub4Mode

	GradientListView {
		model: ObjectModel {
			ListSwitch {
				id: acFeedin

				//% "AC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_ac_coupled_pv")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/PreventFeedback"
				visible: defaultVisible && hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
				invertSourceValue: true
			}

			ListSwitch {
				id: feedInDc

				//% "DC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_dc_coupled_pv")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/OvervoltageFeedIn"
				visible: defaultVisible
					&& hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& doNotFeedInvOvervoltage.isValid

				VeQuickItem {
					id: doNotFeedInvOvervoltage
					uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/DoNotFeedInOvervoltage" : ""
				}
			}

			ListSwitch {
				id: restrictFeedIn

				//% "Limit system feed-in"
				text: qsTrId("settings_ess_limit_system_feed_in")
				visible: defaultVisible && (acFeedin.checked || feedInDc.checked)
				checked: maxFeedInPower.value >= 0
				onCheckedChanged: {
					if (checked && maxFeedInPower.value < 0)
						maxFeedInPower.dataItem.setValue(1000)
					else if (!checked && maxFeedInPower.value >= 0)
						maxFeedInPower.dataItem.setValue(-1)
				}
			}

			ListSpinBox {
				id: maxFeedInPower

				//% "Maximum feed-in"
				text: qsTrId("settings_ess_max_feed_in")
				visible: defaultVisible && restrictFeedIn.visible && restrictFeedIn.checked
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxFeedInPower"
				suffix: "W"
				to: 300000
				stepSize: 100
			}

			ListTextItem {
				id: feedInLimitingActive
				//% "Feed-in limiting active"
				text: qsTrId("settings_ess_feed_in_limiting_active")
				visible: defaultVisible
					&& hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& dataItem.isValid
				dataItem.uid: BackendConnection.serviceUidForType("hub4") +"/PvPowerLimiterActive"
				secondaryText: CommonWords.yesOrNo(feedInLimitingActive.dataItem.value)
			}
		}
	}
}
