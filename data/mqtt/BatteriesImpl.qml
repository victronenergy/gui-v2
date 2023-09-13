/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil

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
