/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Sets the settings /Settings/Devices paths according to the services on the system.

	TODO: update to add /Settings/Devices/cgwacs_* devices for Carlo Gavazzi meters.
*/
Item {
	id: root

	Instantiator {
		// model: Global.dataServiceModel
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterFlags: VeQItemSortTableModel.FilterOffline
			filterRegExp: "^mock\/com\.victronenergy\.(digitalinput|grid|pvinverter|tank|temperature)"
			model: Global.dataServiceModel
		}
		delegate: Device {
			id: device

			required property string uid
			readonly property string serviceType: BackendConnection.serviceTypeFromUid(uid)

			function addToSettings() {
				MockManager.setValue(settingPath() + "/ClassAndVrmInstance", `${serviceType}:${deviceInstance}`)
				MockManager.setValue(settingPath() + "/CustomName", customName)
			}

			function removeFromSettings() {
				MockManager.removeValue(settingPath())
			}

			function settingPath() {
				// The identifier is the suffix after the service type. E.g. if the uid is
				// mock/com.victronenergy.temperature.adc_builtin0_8, the uid is "adc_builtin0_8".
				const identifier = serviceUid.substring(serviceUid.indexOf(serviceType) + serviceType.length + 1)
				return `${Global.systemSettings.serviceUid}/Settings/Devices/${identifier}`
			}

			serviceUid: uid
		}

		onObjectAdded: (index, device) => {
			device.addToSettings()
		}
		onObjectRemoved: (index, device) => {
			device.removeFromSettings()
		}
	}
}
