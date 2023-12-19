/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
				color: Theme.color_font_secondary
			}

			ElectricalQuantityLabel {
				anchors.right: parent.right
				dataObject: model
				valueColor: Theme.color_font_secondary
			}
		}
	}
}
