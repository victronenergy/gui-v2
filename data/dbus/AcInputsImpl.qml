/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	/*
	Each AC input has basic config details at com.victronenergy.system /Ac/In/x. E.g. for Input 0:
		/Ac/In/0/Connected: 			1
		/Ac/In/0/ServiceName: 		'com.victronenergy.grid.smappee_5400001427'
		/Ac/In/0/ServiceType: 		'grid'

	The ServiceName points to the service that provides more details for the input, e.g.
	com.victronenergy.vebus, com.victronenergy.grid, com.victronenergy.genset, which provides
	voltage, current, power etc. for the inputs.
	*/
	property Instantiator inputObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.IdRole
			filterRegExp: "[0-9]+"

			model: VeQItemTableModel {
				uids: ["dbus/com.victronenergy.system/Ac/In"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: AcInput {
			serviceUid: model.uid

			// this looks like: "dbus/com.victronenergy.vebus.ttyO1"
			inputServiceUid: _serviceName.value ? 'dbus/' + _serviceName.value : ''

			readonly property VeQuickItem _serviceName: VeQuickItem {
				uid: model.uid + "/ServiceName"
			}
		}
	}
}
