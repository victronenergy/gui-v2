/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function setSystemValue(path, value) {
		MockManager.setValue("com.victronenergy.system" + path, value)
	}

	VeQuickItem {
		id: gaugesAutoMax
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/AutoMax"
	}

	VeQuickItem {
		id: maxMotorRpm
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/RPM/Max"
	}

	Instantiator {
		model: ServiceModel { serviceTypes: ["motordrive"] }
		delegate: Item {
			id: motorDrive

			required property int index
			required property string uid

			// Set system /MotorDrive/Power to the power of the first motordrive on the system.
			VeQuickItem {
				uid: motorDrive.uid + "/Dc/0/Power"
				onValueChanged: {
					if (motorDrive.index === 0) {
						root.setSystemValue("/MotorDrive/Power", value ?? 0)
						root.setSystemValue("/MotorDrive/Current", value/100 ?? 0)
					}
				}
			}

			// Update the max value of the RPM gauge on the Boat page.
			VeQuickItem {
				uid: motorDrive.uid + "/Motor/RPM"
				onValueChanged: {
					if (valid && gaugesAutoMax.value === 1) {
						maxMotorRpm.setValue(Math.max(value, maxMotorRpm.value || 0))
					}
				}
			}

			// Animate motordrive values.
			MockDataRandomizer {
				VeQuickItem { uid: motorDrive.uid + "/Dc/0/Power" }
				VeQuickItem { uid: motorDrive.uid + "/Dc/0/Voltage" }
				VeQuickItem { uid: motorDrive.uid + "/Dc/0/Current" }
				VeQuickItem { uid: motorDrive.uid + "/Dc/0/Temperature" }
				VeQuickItem { uid: motorDrive.uid + "/Motor/Temperature" }
				VeQuickItem { uid: motorDrive.uid + "/Coolant/Temperature" }
				VeQuickItem { uid: motorDrive.uid + "/Controller/Temperature" }
			}
			MockDataRangeAnimator {
				stepSize: -876 // use a step size that looks uneven
				maximumValue: MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/RPM/Max") || 0
				VeQuickItem { uid: motorDrive.uid + "/Motor/RPM" }
			}
			MockDataRangeAnimator {
				maximumValue: VenusOS.MotorDriveGear_Forward
				VeQuickItem { uid: motorDrive.uid + "/Motor/Direction" }
			}
		}
	}
}
