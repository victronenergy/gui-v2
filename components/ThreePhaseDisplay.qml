/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property alias model: phaseRepeater.model

	Repeater {
		id: phaseRepeater

		delegate: Item {
			width: parent.width
			height: phaseLabel.height

			Label {
				id: phaseLabel

				text: model.name
				color: Theme.color.font.secondary
			}

			ElectricalQuantityLabel {
				anchors.right: parent.right
				dataObject: model
				valueColor: Theme.color.font.secondary
			}
		}
	}
}
