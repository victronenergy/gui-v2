/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	property string bindPrefix
	property string powerKey: "Power"

	property VeQuickItem powerL1: VeQuickItem { uid: bindPrefix + "/L1/" + powerKey }
	property VeQuickItem powerL2: VeQuickItem { uid: bindPrefix + "/L2/" + powerKey }
	property VeQuickItem powerL3: VeQuickItem { uid: bindPrefix + "/L3/" + powerKey }
	property VeQuickItem phaseCount: VeQuickItem { uid: bindPrefix + "/NumberOfPhases" }
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
			power = powerL1.isValid || powerL2.isValid || powerL3.isValid
					? (powerL1.value || 0) + (powerL2.value || 0) + (powerL3.value || 0)
					: undefined
		}
	}
}
