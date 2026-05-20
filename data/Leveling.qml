/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property bool available: _levelingServiceUid.length > 0
	readonly property string serviceUid: _levelingServiceUid
	readonly property real roll: _roll.valid ? _roll.value : NaN
	readonly property real pitch: _pitch.valid ? _pitch.value : NaN

	property string _levelingServiceUid: ""

	// Probe every temperature service to find the one that exposes Rotation/Roll.
	readonly property Instantiator _serviceMonitor: Instantiator {
		model: FilteredServiceModel { serviceTypes: ["temperature"] }
		delegate: QtObject {
			id: svcDelegate
			required property string uid

			readonly property VeQuickItem _rollProbe: VeQuickItem {
				uid: svcDelegate.uid + "/Orientation/Roll"
				onValidChanged: {
					if (valid && root._levelingServiceUid.length === 0) {
						root._levelingServiceUid = svcDelegate.uid
					} else if (!valid && root._levelingServiceUid === svcDelegate.uid) {
						root._levelingServiceUid = ""
					}
				}
			}
		}
	}

	readonly property VeQuickItem _roll: VeQuickItem {
		uid: root._levelingServiceUid.length > 0 ? root._levelingServiceUid + "/Orientation/Roll" : ""
	}

	readonly property VeQuickItem _pitch: VeQuickItem {
		uid: root._levelingServiceUid.length > 0 ? root._levelingServiceUid + "/Orientation/Pitch" : ""
	}

	Component.onCompleted: Global.leveling = root
}
