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
	readonly property real power: _power.valid ? _power.value : NaN
	readonly property real voltage: _voltage.valid ? _voltage.value : NaN
	readonly property real current: !power || !voltage ? NaN : power / voltage

	// Whether the tracker is enabled, i.e. it should appear in the UI.
	// This is true if the /Enabled setting is not present, for compatibility with older systems.
	readonly property bool enabled: !_enabled.valid || _enabled.value === 1

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

	readonly property VeQuickItem _enabled: VeQuickItem {
		uid: root.device.trackerCount <= 1 ? "" : `${root.device.serviceUid}/Pv/${root.trackerIndex}/Enabled`
	}
}
