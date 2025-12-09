/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	readonly property string motorDriveUid: motorDriveServices.firstUid

	function setSystemValue(path, value) {
		MockManager.setValue("com.victronenergy.system" + path, value)
	}

	FilteredServiceModel {
		id: motorDriveServices
		serviceTypes: ["motordrive"]
	}

	VeQuickItem {
		id: gaugesAutoMax
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/AutoMax"
	}

	VeQuickItem {
		id: maxMotorRpm
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/RPM/Max"
	}

	Loader {
		active: root.motorDriveUid.length > 0
		sourceComponent: Item {
			// Set system /MotorDrive/Power to the power of the first motordrive on the system.
			VeQuickItem {
				uid: root.motorDriveUid + "/Dc/0/Power"
				onValueChanged: {
					root.setSystemValue("/MotorDrive/Power", value ?? 0)
					root.setSystemValue("/MotorDrive/Current", value/100 ?? 0)
				}
			}

			// Update the max value of the RPM gauge on the Boat page.
			VeQuickItem {
				uid: root.motorDriveUid + "/Motor/RPM"
				onValueChanged: {
					if (valid && gaugesAutoMax.value === 1) {
						maxMotorRpm.setValue(Math.max(value, maxMotorRpm.value || 0))
					}
				}
			}

			// Animate motordrive values.
			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: root.motorDriveUid + "/Dc/0/Power" }
				VeQuickItem { uid: root.motorDriveUid + "/Dc/0/Voltage" }
				VeQuickItem { uid: root.motorDriveUid + "/Dc/0/Current" }
				VeQuickItem { uid: root.motorDriveUid + "/Dc/0/Temperature" }
				VeQuickItem { uid: root.motorDriveUid + "/Motor/Temperature" }
				VeQuickItem { uid: root.motorDriveUid + "/Coolant/Temperature" }
				VeQuickItem { uid: root.motorDriveUid + "/Controller/Temperature" }
				VeQuickItem { uid: root.motorDriveUid + "/Motor/Torque" }
			}
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible
				stepSize: -876 // use a step size that looks uneven
				maximumValue: MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/RPM/Max") || 0
				VeQuickItem { uid: root.motorDriveUid + "/Motor/RPM" }
			}
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible
				maximumValue: VenusOS.MotorDriveGear_Forward
				VeQuickItem { uid: root.motorDriveUid + "/Motor/Direction" }
			}
		}
	}
}
