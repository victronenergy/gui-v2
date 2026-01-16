/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property FilteredDeviceModel _motorDrives: FilteredDeviceModel {
		serviceTypes: ["motordrive"]
	}

	readonly property VeQuickItem _firstDeviceInstance: VeQuickItem {
		uid: BackendConnection.serviceUidForType("system") + "/MotorDrive/0/DeviceInstance"
	}
	readonly property VeQuickItem _secondDeviceInstance: VeQuickItem {
		uid: BackendConnection.serviceUidForType("system") + "/MotorDrive/1/DeviceInstance"
	}

	readonly property Device _firstDevice: _motorDrives.count,_firstDeviceInstance.valid
		? _motorDrives.deviceForDeviceInstance(_firstDeviceInstance.value)
		: null

	readonly property Device _secondDevice: _motorDrives.count,_secondDeviceInstance.valid
		? _motorDrives.deviceForDeviceInstance(_secondDeviceInstance.value)
		: null

	readonly property Device single: root._firstDevice && !root._secondDevice ? root._firstDevice : null
	readonly property MotorDrive singleMotorDrive: MotorDrive {
		serviceUid: root.single ? root.single.serviceUid : ""
	}

	readonly property Device left: root._firstDevice && root._secondDevice ? root._firstDevice : null
	readonly property MotorDrive leftMotorDrive: MotorDrive {
		serviceUid: root.left ? root.left.serviceUid : ""
	}

	readonly property Device right: root._firstDevice && root._secondDevice ? root._secondDevice : null
	readonly property MotorDrive rightMotorDrive: MotorDrive {
		serviceUid: root.right ? root.right.serviceUid : ""
	}

	readonly property VeQuickItemsQuotient power: VeQuickItemsQuotient {
		objectName: "overallPower"
		numeratorUid: root._firstDevice ? BackendConnection.serviceUidForType("system") + "/MotorDrive/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Power/Max" : ""
		sourceUnit: VenusOS.Units_Watt
		displayUnit: VenusOS.Units_Watt
	}

	readonly property QtObject dcConsumption: QtObject {
		// we no longer support max current, so any ArcGauges (such as the BoatPage center gauge)
		// always shows power, regardless of Global.systemSettings.electricalPowerDisplay
		readonly property VeQuickItemsQuotient quotient: root.power

		// we can show current in the consumption gauge
		// and also in the central gauge when Amps/Mixed is preferred
		readonly property QtObject scalar: QtObject {
			readonly property real power: root.power._numerator.value ?? NaN
			readonly property real current: _scalarCurrent.value ?? NaN

			readonly property VeQuickItem _scalarCurrent: VeQuickItem {
				uid: root.serviceUid ? BackendConnection.serviceUidForType("system") + "/MotorDrive/Current" : ""
			}
		}
	}
}
