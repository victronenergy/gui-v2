/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator generatorObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/generator"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: Generator {
			id: generator

			serviceUid: model.uid
			onValidChanged: {
				if (!!Global.generators) {
					if (valid) {
						Global.generators.addGenerator(generator)
					} else {
						Global.generators.removeGenerator(generator)
					}
				}
			}
		}
	}
}
