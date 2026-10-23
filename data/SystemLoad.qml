/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string systemServiceUid
	required property string veBusServiceUid

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
		uid: root.veBusServiceUid ? root.veBusServiceUid + "/Ac/State/SplitPhaseL2Passthru" : ""
	}
	readonly property VeQuickItem _l2L1OutSummed: VeQuickItem {
		uid: root.veBusServiceUid ? root.veBusServiceUid + "/Ac/State/SplitPhaseL2L1OutSummed" : ""
	}
}
