/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Veutil
import "../common"

QtObject {
	property Instantiator batteryObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/battery"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: Battery {
			serviceUid: model.uid
		}
	}

	property Instantiator multiRsBatteryObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/multi"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: Battery {
			serviceUid: model.uid
		}
	}
}
