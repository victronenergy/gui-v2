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

	readonly property real power: _phases.totalPower
	readonly property real current: phases.count === 1 ? _phases.firstPhaseCurrent : NaN // multi-phase systems don't have a total current
	readonly property alias currentLimit: _acInputService.currentLimit
	readonly property alias phases: _phases

	// Phase measurements from com.victronenergy.system/Ac/ActiveIn/L<1|2|3>
	readonly property AcInputPhaseModel _phases: AcInputPhaseModel {
		id: _phases
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
