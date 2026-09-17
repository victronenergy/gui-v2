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
		model: DelegateComponentModel {
			DelegateComponent {
				id: acFeedinDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/PreventFeedback" }
				// Mirrors the ListSwitch below, which sets invertSourceValue: true
				property bool checked: dataItem.value === 0
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
				ListSwitch {
					id: acFeedin

					//% "AC-coupled PV - feed in excess"
					text: qsTrId("settings_ess_ac_coupled_pv")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/PreventFeedback"
					invertSourceValue: true
				}
			}

			DelegateComponent {
				id: feedInDcDC
				dataItem: VeQuickItem {
					uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/OvervoltageFeedIn"
				}
				property VeQuickItem doNotFeedInOvervoltageItem: VeQuickItem {
					uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/DoNotFeedInOvervoltage" : ""
				}
				property bool checked: dataItem.value === 1
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& doNotFeedInOvervoltageItem.valid
				ListSwitch {
					id: feedInDc

					//% "DC-coupled PV - feed in excess"
					text: qsTrId("settings_ess_dc_coupled_pv")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/OvervoltageFeedIn"
				}
			}

			DelegateComponent {
				id: restrictFeedInDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxFeedInPower" }
				property bool checked: dataItem.value >= 0
				preferredVisible: acFeedinDC.checked || feedInDcDC.checked
				ListSwitch {
					id: restrictFeedIn

					//% "Limit system feed-in"
					text: qsTrId("settings_ess_limit_system_feed_in")
					checked: restrictFeedInDC.dataItem.value >= 0
					onClicked: {
						if (restrictFeedInDC.dataItem.value < 0) {
							restrictFeedInDC.dataItem.setValue(1000)
						} else if (restrictFeedInDC.dataItem.value >= 0) {
							restrictFeedInDC.dataItem.setValue(-1)
						}
					}
				}
			}

			DelegateComponent {
				preferredVisible: restrictFeedInDC.preferredVisible && restrictFeedInDC.checked
				ListSpinBox {
					id: maxFeedInPower

					//% "Maximum feed-in"
					text: qsTrId("settings_ess_max_feed_in")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxFeedInPower"
					suffix: Units.defaultUnitString(VenusOS.Units_Watt)
					from: 0
					to: 300000
					stepSize: 100
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: BackendConnection.serviceUidForType("hub4") +"/PvPowerLimiterActive" }
				preferredVisible: hub4Mode !== VenusOS.Ess_Hub4ModeState_Disabled
					&& dataItem.valid
				ListText {
					id: feedInLimitingActive
					//% "Feed-in limiting active"
					text: qsTrId("settings_ess_feed_in_limiting_active")
					dataItem.uid: BackendConnection.serviceUidForType("hub4") +"/PvPowerLimiterActive"
					secondaryText: CommonWords.yesOrNo(feedInLimitingActive.dataItem.value)
				}
			}
		}
	}
}
