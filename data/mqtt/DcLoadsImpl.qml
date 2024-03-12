/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	readonly property Instantiator dcloadObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/dcload"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: DcLoad {
			serviceUid: model.uid
		}
	}

	readonly property Instantiator dcsystemObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/dcsystem"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: DcLoad {
			serviceUid: model.uid
		}
	}

	readonly property Instantiator dcdcObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/dcdc"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: DcLoad {
			serviceUid: model.uid
		}
	}
}
