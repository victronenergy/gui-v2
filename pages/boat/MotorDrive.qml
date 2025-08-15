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

	readonly property QtObject dcConsumption: QtObject {
		// we no longer support max current, so any ArcGauges (such as the BoatPage center gauge) always shows power, regardless of Global.systemSettings.electricalQuantity
		readonly property VeQuickItemsQuotient quotient: root.power

		// we can show current in the consumption gauge
		readonly property VeQuickItem scalar: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp ? _scalarCurrent : root.power._numerator
		readonly property int scalarUnit: Global.systemSettings.electricalQuantity

		readonly property VeQuickItem _scalarCurrent: VeQuickItem {
			uid: root.motorDrive ? BackendConnection.serviceUidForType("system") + "/MotorDrive/Current" : ""
		}
	}

	readonly property VeQuickItemsQuotient power: VeQuickItemsQuotient {
		objectName: "motorDrivePower"
		numeratorUid: root.motorDrive ? BackendConnection.serviceUidForType("system") + "/MotorDrive/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Power/Max" : ""
		sourceUnit: VenusOS.Units_Watt
		displayUnit: VenusOS.Units_Watt
	}

	readonly property VeQuickItemsQuotient rpm: VeQuickItemsQuotient {
		objectName: "motorDriveRpm"
		numeratorUid: root.motorDrive ? root.motorDrive.serviceUid + "/Motor/RPM" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/RPM/Max" : ""
		sourceUnit: VenusOS.Units_RevolutionsPerMinute
		displayUnit: VenusOS.Units_RevolutionsPerMinute
	}

	readonly property VeQuickItem temperature: VeQuickItem {
		uid: root.motorDrive ? root.motorDrive.serviceUid + "/Dc/0/Temperature" : ""
	}

	readonly property VeQuickItem motorTemperature: VeQuickItem {
		uid: root.motorDrive ? root.motorDrive.serviceUid + "/Motor/Temperature" : ""
	}
}
