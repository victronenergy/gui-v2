/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	// Animate evcharger values.
	Instantiator {
		model: FilteredServiceModel { serviceTypes: ["evcharger"] }
		delegate: Item {
			id: evcs

			required property string uid

			VeQuickItem { id: evcsMaxCurrent; uid: evcs.uid + "/MaxCurrent" }

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				onNotifyTotal: (totalPower) => { MockManager.setValue(uid + "/Ac/Power", totalPower) }

				VeQuickItem { uid: evcs.uid + "/Ac/L1/Power" }
				VeQuickItem { uid: evcs.uid + "/Ac/L2/Power" }
				VeQuickItem { uid: evcs.uid + "/Ac/L3/Power" }
			}
			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				maximumValue: evcsMaxCurrent.value ?? NaN
				VeQuickItem { uid: evcs.uid + "/Current" }
			}
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible
				stepSize: 0.005
				maximumValue: NaN
				VeQuickItem { uid: evcs.uid + "/Ac/Energy/Forward" }
			}
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible && statusItem.value === VenusOS.Evcs_Status_Charging
				stepSize: 1
				maximumValue: NaN
				VeQuickItem { uid: evcs.uid + "/ChargingTime" }
			}
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible
				interval: 5000
				minimumValue: VenusOS.Evcs_Status_Disconnected
				maximumValue: VenusOS.Evcs_Status_Charged
				VeQuickItem {
					id: statusItem
					uid: evcs.uid + "/Status"
				}
			}
		}
	}
}
