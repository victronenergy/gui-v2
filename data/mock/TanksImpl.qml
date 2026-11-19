/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	// Animate tank values.
	Instantiator {
		id: tankObjects
		model: FilteredServiceModel { serviceTypes: ["tank"] }
		delegate: Item {
			id: tank

			required property int index
			required property string uid

			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible && status.value === VenusOS.Tank_Status_Ok
				stepSize: 7
				maximumValue: 100

				VeQuickItem {
					id: level
					uid: tank.uid + "/Level"
					onValueChanged: {
						if (!valid) {
							return
						}
						if (capacity.valid) {
							remaining.setValue(capacity.value * (value / 100))
						}
					}
				}
			}

			VeQuickItem {
				id: capacity
				uid: tank.uid + "/Capacity"
			}
			VeQuickItem {
				id: remaining
				uid: tank.uid + "/Remaining"
			}
			VeQuickItem {
				id: status
				uid: tank.uid + "/Status"
			}

			// If this is the first tank, then every 10 seconds, change it to/from an error state.
			// (This may not be the first tank in the Levels page due to the sort order there.)
			MockDataToggler {
				active: MockManager.timersActive && tank.index === 0
				valueA: VenusOS.Tank_Status_Ok
				valueB: VenusOS.Tank_Status_Error
				interval: 10000
				dataItems: [status]
			}
		}
	}
}
