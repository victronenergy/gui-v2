/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string deviceClass
	property int vrmInstance: -1
	property alias uid: dataItem.uid
	property string customNameUid

	property BaseDevice device
	readonly property string name: _customName.value || device?.name || ""

	function setVrmInstance(newInstance) {
		dataItem.setValue(deviceClass + ":" + newInstance)
	}

	readonly property VeQuickItem dataItem: VeQuickItem {
		id: dataItem

		onValueChanged: {
			if (value) {
				const values = value.split(":")
				const _deviceClass = values[0] || ""
				const _vrmInstance = parseInt(values[1] || "")
				if (isNaN(_vrmInstance)) {
					console.warn("Cannot parse VRM instance from", value)
					root.deviceClass = ""
					root.vrmInstance = -1
				} else {
					root.deviceClass = _deviceClass
					root.vrmInstance = _vrmInstance
				}
			}
		}
	}

	readonly property VeQuickItem _customName: VeQuickItem {
		uid: root.customNameUid
	}
}
