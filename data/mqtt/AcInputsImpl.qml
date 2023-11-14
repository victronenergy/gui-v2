/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	/*
	Each AC input has basic config details at com.victronenergy.system /Ac/In/x. E.g. for Input 0:
		/Ac/In/0/Connected {"value": 0}
		/Ac/In/0/DeviceInstance {"value": 289}
		/Ac/In/0/ServiceName {"value": "com.victronenergy.vebus.ttyUSB1"}
		/Ac/In/0/ServiceType {"value": "vebus"}
		/Ac/In/0/Source {"value": 3}

	The ServiceName points to the service that provides more details for the input, e.g.
	vebus, grid, genset, which provides voltage, current, power etc. for the inputs.
	*/
	property Instantiator inputObjects: Instantiator {

		/* model uids will look like this:
			uid: mqtt/system/0/Ac/In/0					// we want this one
			uid: mqtt/system/0/Ac/In/1					// we want this one
			uid: mqtt/system/0/Ac/In/NumberOfAcInputs	// we don't want this one
		*/
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.IdRole
			filterRegExp: "[0-9]+"

			model: VeQItemTableModel {
				uids: ["mqtt/system/0/Ac/In"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: AcInput {
			systemServicePrefix: model.uid

			// this looks like: 'mqtt/vebus/289/'
			serviceUid: serviceType.length && _deviceInstanceOnSystemService.value !== undefined
					? "mqtt/" + serviceType + "/" + _deviceInstanceOnSystemService.value
					: ""

			// Get the value of mqtt/system/Ac/In/<x>/DeviceInstance, to assemble the serviceUid
			readonly property VeQuickItem _deviceInstanceOnSystemService: VeQuickItem {
				uid: model.uid + "/DeviceInstance"
			}
		}
	}
}
