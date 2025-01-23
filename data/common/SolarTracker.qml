/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property SolarDevice device
	required property int trackerIndex

	readonly property string name: _name.value ?? ""
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property real voltage: _voltage.isValid ? _voltage.value : NaN
	readonly property real current: !power || !voltage ? NaN : power / voltage

	// If there is only 1 tracker (e.g. all common MPPTs), the voltage and power are provided via
	// /Pv/V and /Yield/Power instead of /Pv/0/V and /Pv/0/P.
	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: root.device.trackerCount <= 1 ? `${root.device.serviceUid}/Pv/V` : `${root.device.serviceUid}/Pv/${root.trackerIndex}/V`
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: root.device.trackerCount <= 1 ? `${root.device.serviceUid}/Yield/Power` : `${root.device.serviceUid}/Pv/${root.trackerIndex}/P`
	}

	readonly property VeQuickItem _name: VeQuickItem {
		uid: root.device.trackerCount <= 1 ? "" : `${root.device.serviceUid}/Pv/${root.trackerIndex}/Name`
	}
}
