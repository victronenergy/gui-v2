/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var motorDrive: Global.allDevicesModel.motorDriveDevices.count > 0
										 ? Global.allDevicesModel.motorDriveDevices.firstObject
										 : null
	// we no longer support max current, so BoatPage always shows power, regardless of Global.systemSettings.electricalQuantity
	readonly property VeQuickItemsQuotient dcConsumption: power

	readonly property VeQuickItemsQuotient power: VeQuickItemsQuotient {
		objectName: "motorDrivePower"
		numeratorUid: motorDrive ? BackendConnection.serviceUidForType("system") + "/MotorDrive/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Power/Max" : ""
		sourceUnit: VenusOS.Units_Watt
		displayUnit: VenusOS.Units_Watt
	}

	readonly property VeQuickItemsQuotient rpm: VeQuickItemsQuotient {
		objectName: "motorDriveRpm"
		numeratorUid: motorDrive ? motorDrive.serviceUid + "/Motor/RPM" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/RPM/Max" : ""
		sourceUnit: VenusOS.Units_RevolutionsPerMinute
		displayUnit: VenusOS.Units_RevolutionsPerMinute
	}

	readonly property VeQuickItem temperature: VeQuickItem {
		uid: motorDrive ? motorDrive.serviceUid + "/Dc/0/Temperature" : ""
	}

	readonly property VeQuickItem motorTemperature: VeQuickItem {
		uid: motorDrive ? motorDrive.serviceUid + "/Motor/Temperature" : ""
	}
}
