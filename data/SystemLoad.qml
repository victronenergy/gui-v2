/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string systemServiceUid

	readonly property real maximumAcCurrent: _maximumAcCurrent.valid ? _maximumAcCurrent.value : NaN

	readonly property ObjectAcConnection ac: ObjectAcConnection {
		l2AndL1OutSummed: _l2L1OutSummed.valid && (_l2L1OutSummed.value !== 0)
		isAcOutput: true
		bindPrefix: root.systemServiceUid + "/Ac/Consumption"
	}
	readonly property ObjectAcConnection acIn: ObjectAcConnection {
		splitPhaseL2PassthruDisabled: _splitPhaseL2Passthru.value === 0
		bindPrefix: root.systemServiceUid + "/Ac/ConsumptionOnInput"
	}
	readonly property ObjectAcConnection acOut: ObjectAcConnection {
		l2AndL1OutSummed: _l2L1OutSummed.valid && (_l2L1OutSummed.value !== 0)
		isAcOutput: true
		bindPrefix: root.systemServiceUid + "/Ac/ConsumptionOnOutput"
	}

	readonly property VeQuickItem _maximumAcCurrent: VeQuickItem {
		uid: Global.acInputs.input1Info.connected ? Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/AcIn1/Consumption/Current/Max"
		   : Global.acInputs.input2Info.connected ? Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/AcIn2/Consumption/Current/Max"
		   : Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/NoAcIn/Consumption/Current/Max"
	}

	/*
	 * Single Multis that can be split-phase reports NrOfPhases of 2
	 * When L2 is disconnected from the input the output L1 and L2
	 * are shorted. This item indicates if L2 is passed through
	 * from AC-in to AC-out.
	 * 1: L2 is being passed through from AC-in to AC-out.
	 * 0: L1 and L2 are shorted together.
	 * invalid: The unit is configured in such way that its L2 output is not used.
	 */
	readonly property VeQuickItem _splitPhaseL2Passthru: VeQuickItem {
		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/SplitPhaseL2Passthru" : ""
	}
	readonly property VeQuickItem _l2L1OutSummed: VeQuickItem {
		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/SplitPhaseL2L1OutSummed" : ""
	}
}
