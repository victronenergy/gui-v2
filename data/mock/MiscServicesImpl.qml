/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	// Animate gps values.
	Instantiator {
		model: FilteredServiceModel { serviceTypes: ["gps"] }
		delegate: Item {
			id: gps

			required property string uid

			MockDataRangeAnimator {
				stepSize: 8
				maximumValue: MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Speed/Max") || 0
				VeQuickItem { uid: gps.uid + "/Speed" }
			}
		}
	}

	// Animate meteo values.
	Instantiator {
		model: FilteredServiceModel { serviceTypes: ["meteo"] }
		delegate: Item {
			id: meteo

			required property string uid

			MockDataRandomizer {
				VeQuickItem { uid: meteo.uid + "/Irradiance" }
				VeQuickItem { uid: meteo.uid + "/WindSpeed" }
				VeQuickItem { uid: meteo.uid + "/InstallationPower" }
			}
			MockDataRangeAnimator {
				stepSize: 45
				maximumValue: 360
				VeQuickItem { uid: meteo.uid + "/WindDirection" }
			}
		}
	}
}
