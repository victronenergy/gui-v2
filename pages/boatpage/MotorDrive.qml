/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var _motorDrive: Global.allDevicesModel.motorDriveDevices.count > 0
									   ? Global.allDevicesModel.motorDriveDevices.firstObject
									   : null

	readonly property VeQuickItemsQuotient dcConsumption: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp
																	? current
																	: power

	readonly property VeQuickItemsQuotient power: VeQuickItemsQuotient {
		objectName: "motorDrivePower"
		numeratorUid: _motorDrive ? _motorDrive.serviceUid + "/Dc/0/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Power/Max" : ""
		sourceUnit: VenusOS.Units_Watt
		displayUnit: VenusOS.Units_Watt
	}

	readonly property VeQuickItemsQuotient current: VeQuickItemsQuotient {
		objectName: "motorDriveCurrent"
		numeratorUid: _motorDrive ? _motorDrive.serviceUid + "/Dc/0/Current" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Current/Max" : ""
		sourceUnit: VenusOS.Units_Amp
		displayUnit: VenusOS.Units_Amp
	}

	readonly property VeQuickItemsQuotient rpm: VeQuickItemsQuotient {
		objectName: "motorDriveRpm"
		numeratorUid: _motorDrive ? _motorDrive.serviceUid + "/Motor/RPM" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Rpm/Max" : ""
		sourceUnit: VenusOS.Units_RevolutionsPerMinute
		displayUnit: VenusOS.Units_RevolutionsPerMinute
	}

	readonly property VeQuickItem temperature: VeQuickItem {
		uid: _motorDrive ? _motorDrive.serviceUid + "/Dc/0/Temperature" : ""
	}

	readonly property VeQuickItem motorTemperature: VeQuickItem {
		uid: _motorDrive ? _motorDrive.serviceUid + "/Motor/Temperature" : ""
	}
}
