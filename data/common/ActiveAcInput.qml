/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: root

	property AcInputSystemInfo inputInfo

	readonly property bool connected: inputInfo && inputInfo.connected
	readonly property string serviceType: !!inputInfo ? inputInfo.serviceType : ""
	readonly property string serviceName: !!inputInfo ? inputInfo.serviceName : ""

	readonly property int source: !!inputInfo ? inputInfo.source : VenusOS.AcInputs_InputSource_NotAvailable
	readonly property alias gensetStatusCode: _acInputService.gensetStatusCode

	// clamp to zero any values with magnitude < 1 (assume it's noise) to avoid UI flicker.
	readonly property real power: (Math.floor(Math.abs(_phaseMeasurements.power)) < 1.0) ? 0.0 : _phaseMeasurements.power
	readonly property real current: _phaseMeasurements.current
	readonly property alias currentLimit: _acInputService.currentLimit
	readonly property alias phases: _phaseMeasurements.phases

	// Phase measurements from com.victronenergy.system/Ac/ActiveIn/L<1|2|3>
	readonly property ObjectAcConnection _phaseMeasurements: ObjectAcConnection {
		id: _phaseMeasurements
		bindPrefix: Global.system.serviceUid + "/Ac/ActiveIn"
	}

	// Data from the input-specific service, e.g. com.victronenergy.vebus for a VE.Bus input,
	// or com.victronenergy.grid for grid parallel systems.
	readonly property AcInputServiceLoader _acInputService: AcInputServiceLoader {
		id: _acInputService

		active: !!root.inputInfo
		serviceUid: root.serviceUid
		serviceType: root.serviceType
	}
}
