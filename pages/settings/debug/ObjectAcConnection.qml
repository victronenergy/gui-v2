/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	property string bindPrefix
	property string powerKey: "Power"

	property DataPoint powerL1: DataPoint { source: bindPrefix + "/L1/" + powerKey }
	property DataPoint powerL2: DataPoint { source: bindPrefix + "/L2/" + powerKey }
	property DataPoint powerL3: DataPoint { source: bindPrefix + "/L3/" + powerKey }
	property DataPoint phaseCount: DataPoint { source: bindPrefix + "/NumberOfPhases" }
	property bool splitPhaseL2PassthruDisabled: false
	property bool isAcOutput: false
	property bool l1AndL2OutShorted: splitPhaseL2PassthruDisabled && isAcOutput

	property var power
	// As systemcalc doesn't provide the totals anymore we calculate it here.
	// Timer is needed because the values are not received in once and then the total
	// changes too often on system with more than one phase
	property Timer timer: Timer {
		interval: 1000
		running: BackendConnection.applicationVisible
		repeat: true
		onTriggered: {
			power = powerL1.valid || powerL2.valid || powerL3.valid
					? (powerL1.value || 0) + (powerL2.value || 0) + (powerL3.value || 0)
					: undefined
		}
	}
}
