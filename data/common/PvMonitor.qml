/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	required property string systemServiceUid

	property real totalPower: NaN
	property real totalCurrent: NaN
	property int maxPhaseCount: 0

	// AC power is the total power from Ac/PvOnGrid/L*/Power, Ac/PvOnGenset/L*/Power
	// and Ac/PvOnOutput/L*/Power.
	function _updateAcTotals() {
		let _totalPower = NaN
		let _totalCurrent = NaN

		for (let i = 0; i < count; ++i) {
			const acPv = objectAt(i)
			if (!!acPv) {
				_totalPower = Units.sumRealNumbers(_totalPower, acPv.power)
				_totalCurrent = Units.sumRealNumbers(_totalCurrent, acPv.current)
			}
		}
		root.totalPower = _totalPower
		root.totalCurrent = _totalCurrent
	}

	function _updateMaximumPhaseCount() {
		let _maxPhaseCount = 0
		for (let i = 0; i < count; ++i) {
			const acPvDelegate = root.objectAt(i)
			if (!!acPvDelegate) {
				_maxPhaseCount = Math.max(_maxPhaseCount, acPvDelegate.phaseCount)
			}
		}
		root.maxPhaseCount = _maxPhaseCount
	}

	model: [
		`${root.systemServiceUid}/Ac/PvOnGrid`,
		`${root.systemServiceUid}/Ac/PvOnGenset`,
		`${root.systemServiceUid}/Ac/PvOnOutput`
	]

	delegate: ObjectAcConnection {
		required property string modelData

		bindPrefix: modelData

		onPhaseCountChanged: Qt.callLater(root._updateMaximumPhaseCount)
		onPowerChanged: Qt.callLater(root._updateAcTotals)
		onCurrentChanged: Qt.callLater(root._updateAcTotals)
	}
}
