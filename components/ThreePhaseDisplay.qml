/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property var physicalQuantity: Enums.Units_PhysicalQuantity_Power // eg. Units.Voltage, Units.Current, Units.Power
	property int precision: 3 // this will display 1.23 kW, given a value of 1234 W
	property alias model: phaseRepeater.model
	property string phaseModelProperty: "power"

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

			ValueQuantityDisplay {
				anchors.right: parent.right
				value: model[root.phaseModelProperty]
				physicalQuantity: root.physicalQuantity
				precision: root.precision
				valueColor: Theme.color.font.secondary
			}
		}
	}
}
