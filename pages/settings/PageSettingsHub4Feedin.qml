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
				dataSource: "com.victronenergy.settings/Settings/CGwacs/PreventFeedback"
				visible: defaultVisible && hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
				invertSourceValue: true
			}

			ListSwitch {
				id: feedInDc

				//% "DC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_dc_coupled_pv")
				dataSource: "com.victronenergy.settings/Settings/CGwacs/OvervoltageFeedIn"
				visible: defaultVisible
					&& hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& doNotFeedInvOvervoltage.valid

				DataPoint {
					id: doNotFeedInvOvervoltage
					source: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/DoNotFeedInOvervoltage" : ""
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
						maxFeedInPower.setDataValue(1000)
					else if (!checked && maxFeedInPower.value >= 0)
						maxFeedInPower.setDataValue(-1)
				}
			}

			ListSpinBox {
				id: maxFeedInPower

				//% "Maximum feed-in"
				text: qsTrId("settings_ess_max_feed_in")
				visible: defaultVisible && restrictFeedIn.visible && restrictFeedIn.checked
				dataSource: "com.victronenergy.settings/Settings/CGwacs/MaxFeedInPower"
				suffix: "W"
				to: 300000
				stepSize: 100
			}

			ListTextItem {
				//% "Feed-in limiting active"
				text: qsTrId("settings_ess_feed_in_limiting_active")
				visible: defaultVisible
					&& hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& dataValid
				dataSource: "com.victronenergy.hub4/PvPowerLimiterActive"
				secondaryText: CommonWords.yesOrNo(dataValue)
			}
		}
	}
}
