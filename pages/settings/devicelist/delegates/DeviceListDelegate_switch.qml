/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: {
		if (device.customName) {
			return device.customName
		} else if (device.deviceInstance >= 0 && device.productName) {
			return `${device.productName} (${device.deviceInstance})`
		} else {
			return ""
		}
	}

	secondaryText: VenusOS.switch_deviceStateToText(state.value)

	onClicked: {
		outputModelLoader.active = true
		Global.pageManager.pushPage("/pages/settings/devicelist/PageSwitchableOutputList.qml", {
			serviceUid: root.device.serviceUid,
			switchableOutputModel: outputModelLoader.item,
			title: Qt.binding(function() { return root.text })
		})
	}

	VeQuickItem {
		id: state
		uid: root.device.serviceUid + "/State"
	}

	Loader {
		id: outputModelLoader

		active: false
		sourceComponent: SwitchableOutputModel {
			sourceModel: VeQItemTableModel {
				uids: [ root.device.serviceUid + "/SwitchableOutput" ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
	}
}
