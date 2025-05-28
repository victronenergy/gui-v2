/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string bindPrefix
	property string powerKey: "Power"
	property string currentKey: "Current"
	readonly property alias phaseCount: _phases.phaseCount

	readonly property VeQuickItem powerL1: VeQuickItem {
		uid: bindPrefix ? bindPrefix + "/L1/" + root.powerKey : ""
		onValueChanged: root.phases.setValue(0, PhaseModel.PowerRole, value)
		onValidChanged: if (valid) root._expandPhaseCount(1)
	}
	readonly property VeQuickItem powerL2: VeQuickItem {
		uid: bindPrefix ? bindPrefix + "/L2/" + root.powerKey : ""
		onValidChanged: if (valid) root._expandPhaseCount(2)
		onValueChanged: root.phases.setValue(1, PhaseModel.PowerRole, value)
	}
	readonly property VeQuickItem powerL3: VeQuickItem {
		uid: bindPrefix ? bindPrefix + "/L3/" + root.powerKey : ""
		onValidChanged: if (valid) root._expandPhaseCount(3)
		onValueChanged: root.phases.setValue(2, PhaseModel.PowerRole, value)
	}
	readonly property VeQuickItem _currentL1: VeQuickItem {
		uid: bindPrefix ? bindPrefix + "/L1/" + root.currentKey : ""
		onValueChanged: root.phases.setValue(0, PhaseModel.CurrentRole, value)
	}
	readonly property VeQuickItem _currentL2: VeQuickItem {
		uid: bindPrefix ? bindPrefix + "/L2/" + root.currentKey : ""
		onValueChanged: root.phases.setValue(1, PhaseModel.CurrentRole, value)
	}
	readonly property VeQuickItem _currentL3: VeQuickItem {
		uid: bindPrefix ? bindPrefix + "/L3/" + root.currentKey : ""
		onValueChanged: root.phases.setValue(2, PhaseModel.CurrentRole, value)
	}
	readonly property VeQuickItem _phaseCount: VeQuickItem { uid: bindPrefix ? bindPrefix + "/NumberOfPhases" : "" }
	property bool splitPhaseL2PassthruDisabled: false
	property bool isAcOutput: false
	property bool l2AndL1OutSummed: false

	readonly property real power: hasPower ? _power : NaN
	readonly property bool hasPower: powerL1.valid || powerL2.valid || powerL3.valid
	property real _power: NaN

	// multi-phase systems don't have a total current
	readonly property real current: _phaseCount.value === 1 && _currentL1.valid ? _currentL1.value : NaN

	readonly property real preferredQuantity: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp ? current : power

	readonly property PhaseModel phases: PhaseModel {
		id: _phases
		l2AndL1OutSummed: root.l2AndL1OutSummed
		phaseCount: _phaseCount.value || 0
	}

	// As systemcalc doesn't provide the totals anymore we calculate it here.
	// Timer is needed because the values are not received in once and then the total
	// changes too often on system with more than one phase
	readonly property Timer _totalPowerTimer: Timer {
		interval: 1000
		running: BackendConnection.applicationVisible && root.hasPower
		repeat: true
		onTriggered: {
			_power = (powerL1.value || 0) + (powerL2.value || 0) + (powerL3.value || 0)
		}
	}

	function _expandPhaseCount(minimumCount) {
		if (!_phaseCount.valid) {
			phases.phaseCount = Math.max(phases.count, minimumCount)
		}
	}
}
