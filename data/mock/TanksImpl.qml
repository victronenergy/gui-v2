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
		model: ServiceModel { serviceTypes: ["tank"] }
		delegate: Item {
			id: tank

			required property string uid

			MockDataRangeAnimator {
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
		}
	}
}
