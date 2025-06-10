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

	// AC power is the total power from Ac/PvOnGrid/L*/Power, Ac/PvOnGenset/L*/Power
	// and Ac/PvOnOutput/L*/Power.
	function _updateAcTotals() {
		let _totalPower = NaN

		for (let i = 0; i < count; ++i) {
			const acPv = objectAt(i)
			if (!!acPv) {
				_totalPower = Units.sumRealNumbers(_totalPower, acPv.power)
			}
		}
		root.totalPower = _totalPower
	}

	model: [
		`${root.systemServiceUid}/Ac/PvOnGrid`,
		`${root.systemServiceUid}/Ac/PvOnGenset`,
		`${root.systemServiceUid}/Ac/PvOnOutput`
	]

	delegate: ObjectAcConnection {
		required property string modelData

		bindPrefix: modelData
		onPowerChanged: Qt.callLater(root._updateAcTotals)
	}
}
