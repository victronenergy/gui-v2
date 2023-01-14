/*
** Copyright (C) 2022 Victron Energy B.V.
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
			systemServiceUid: model.uid

			// this looks like: 'mqtt/vebus/289/'
			serviceUid: serviceType !== '' && deviceInstance !== '' ? 'mqtt/' + serviceType + '/' + deviceInstance : ''
		}
	}
}
