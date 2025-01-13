/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property string bindPrefix

	function name(index) {
		if (isNaN(+index))
			return index

		index = +index
		return "Phase L" + ((+index % 3) + 1) + ", device " + (Math.floor(index / 3) + 1) + " (" + index + ")"
	}

	VeQItemTableModel {
		id: tableModel

		uids: [root.bindPrefix + "/Devices"]
		flags: VeQItemTableModel.AddChildren |
			   VeQItemTableModel.AddNonLeaves |
			   VeQItemTableModel.DontAddItem
	}

	GradientListView {
		model: VisibleItemModel {

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: tableModel
					delegate: ListText {
						preferredVisible: dataItem.isValid
						text: name(model.id)
						dataItem.uid: model.uid + "/SerialNumber"
					}
				}
			}
		}
	}
}
