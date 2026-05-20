/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("system")
	readonly property int state: _systemState.valid ? _systemState.value : VenusOS.System_State_Off

	readonly property bool hasGridMeter: _gridDeviceType.valid
	readonly property bool hasAcOutSystem: _hasAcOutSystem.valid && _hasAcOutSystem.value === 1
	readonly property bool hasAcLoads: !_hasAcLoads.valid || _hasAcLoads.value === 1 // show AC loads by default if the path isn't valid
	readonly property bool hasVebusEss: _systemType.value === "ESS" || _systemType.value === "Hub-4"
	readonly property bool hasEss: hasVebusEss || _systemType.value === "AC System"
	readonly property bool showInputLoads: load.acIn.hasPower
			&& (hasVebusEss ? (hasGridMeter && _withoutGridMeter.value === 0) : hasGridMeter)
	readonly property bool feedbackEnabled: _feedbackEnabled.value === 1

	readonly property ActiveSystemBattery battery: ActiveSystemBattery {
		systemServiceUid: root.serviceUid
	}

	readonly property QtObject load: SystemLoad {
		systemServiceUid: root.serviceUid
	}

	readonly property QtObject dc: QtObject {
		// Regardless of the actual power value, regard the system as having DC power (and show
		// DC Loads in the UI) if any relevant DC services are present or if /HasDcSystem=1.
		readonly property bool hasPower: serviceModel.count > 0 || _hasDcSystem.value === 1

		readonly property real power: hasPower ? _dcSystemPower.value || 0 : NaN
		readonly property bool currentValid: !isNaN(power) && !isNaN(voltage) && (voltage !== 0)
		readonly property real current: currentValid ? power / voltage : NaN
		readonly property real voltage: _dcBatteryVoltage.valid ? _dcBatteryVoltage.value : NaN
		readonly property real maximumPower: _maximumDcPower.valid ? _maximumDcPower.value : NaN

		readonly property VeQuickItem _dcSystemPower: VeQuickItem {
			uid: root.serviceUid + "/Dc/System/Power"
		}

		readonly property VeQuickItem _dcBatteryVoltage: VeQuickItem {
			uid: root.serviceUid + "/Dc/Battery/Voltage"
		}

		readonly property VeQuickItem _maximumDcPower: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/System/Power/Max"
		}

		readonly property VeQuickItem _hasDcSystem: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
		}

		readonly property FilteredServiceModel serviceModel: FilteredServiceModel {
			serviceTypes: ["dcload", "dcsystem", "dcdc"]
		}
	}

	property QtObject solar: QtObject {
		readonly property real power: Units.sumRealNumbers(acPower, dcPower)
		readonly property real acPower: _pvMonitor.totalPower
		readonly property real dcPower: _dcPvPower.valid ? _dcPvPower.value : NaN
		readonly property real maximumPower: _maximumPower.valid ? _maximumPower.value : NaN

		readonly property VeQuickItem _maximumPower: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Pv/Power/Max"
		}

		readonly property PvMonitor _pvMonitor: PvMonitor {
			systemServiceUid: root.serviceUid
		}

		readonly property VeQuickItem _dcPvPower: VeQuickItem {
			uid: root.serviceUid + "/Dc/Pv/Power"
		}

		readonly property VeQuickItem _dcPvCurrent: VeQuickItem {
			uid: root.serviceUid + "/Dc/Pv/Current"
		}
	}

	readonly property QtObject veBus: QtObject {
		readonly property string serviceUid: BackendConnection.serviceUidFromName(_serviceName.value || "", _deviceInstance.value || 0)

		readonly property VeQuickItem _serviceName: VeQuickItem { uid: root.serviceUid + "/VebusService" }
		readonly property VeQuickItem _deviceInstance: VeQuickItem { uid: root.serviceUid + "/VebusInstance" }
	}

	readonly property VeQuickItem _systemState: VeQuickItem {
		uid: root.serviceUid + "/SystemState/State"
	}

	readonly property VeQuickItem _systemType: VeQuickItem {
		uid: root.serviceUid + "/SystemType"
	}

	readonly property VeQuickItem _gridDeviceType: VeQuickItem {
		uid: root.serviceUid + "/Ac/Grid/DeviceType"
	}

	readonly property VeQuickItem _hasAcLoads: VeQuickItem {
		uid: root.serviceUid + "/Ac/HasAcLoads"
	}

	readonly property VeQuickItem _hasAcOutSystem: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem"
	}

	readonly property VeQuickItem _withoutGridMeter: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter"
	}

	readonly property VeQuickItem _feedbackEnabled: VeQuickItem {
		uid: root.serviceUid + "/Ac/ActiveIn/FeedbackEnabled"
	}

	Component.onCompleted: Global.system = root
}
