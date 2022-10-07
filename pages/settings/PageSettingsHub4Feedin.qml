/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property int hub4Mode

	SettingsListView {
		model: ObjectModel {
			SettingsListSwitch {
				id: acFeedin

				//% "AC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_ac_coupled_pv")
				source: "com.victronenergy.settings/Settings/CGwacs/PreventFeedback"
				visible: defaultVisible && hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
				invertSourceValue: true
			}

			SettingsListSwitch {
				id: feedInDc

				//% "DC-coupled PV - feed in excess"
				text: qsTrId("settings_ess_dc_coupled_pv")
				source: "com.victronenergy.settings/Settings/CGwacs/OvervoltageFeedIn"
				visible: defaultVisible
					&& hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& doNotFeedInvOvervoltage.value !== undefined

				DataPoint {
					id: vebusPath
					source: "com.victronenergy.system/VebusService"
				}
				DataPoint {
					id: doNotFeedInvOvervoltage
					source: vebusPath.value === undefined ? "" : (vebusPath.value + "/Hub4/DoNotFeedInOvervoltage")
				}
			}

			SettingsListSwitch {
				id: restrictFeedIn

				//% "Limit system feed-in"
				text: qsTrId("settings_ess_limit_system_feed_in")
				visible: defaultVisible && (acFeedin.checked || feedInDc.checked)
				checked: maxFeedInPower.value >= 0
				onCheckedChanged: {
					if (checked && maxFeedInPower.value < 0)
						maxFeedInPower.dataPoint.setValue(1000)
					else if (!checked && maxFeedInPower.value >= 0)
						maxFeedInPower.dataPoint.setValue(-1)
				}
			}

			SettingsListSpinBox {
				id: maxFeedInPower

				//% "Maximum feed-in"
				text: qsTrId("settings_ess_max_feed_in")
				visible: defaultVisible && restrictFeedIn.visible && restrictFeedIn.checked
				source: "com.victronenergy.settings/Settings/CGwacs/MaxFeedInPower"
				suffix: "W"
				to: 300000
				stepSize: 100
			}

			SettingsListTextItem {
				//% "Feed-in limiting active"
				text: qsTrId("settings_ess_feed_in_limiting_active")
				visible: defaultVisible
					&& hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& dataPoint.value !== undefined
				source: "com.victronenergy.hub4/PvPowerLimiterActive"
				secondaryText: dataPoint.value === 0
					  //% "No"
					? qsTrId("settings_ess_no")
					  //% "Yes"
					: qsTrId("settings_ess_yes")
			}
		}
	}
}
