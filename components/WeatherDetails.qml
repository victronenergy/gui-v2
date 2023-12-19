/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Column {
	id: column

	property alias day: day.text
	property alias temperature: temperature.text
	property alias source: image.source

	width: Theme.geometry.weatherDetails.width

	Label {
		id: day

		color: Theme.color.font.secondary
		font.pixelSize: Theme.font.size.body1
	}
	Row {
		id: row

		spacing: Theme.geometry.weatherDetails.row.spacing

		Label {
			id: temperature

			font.pixelSize: Theme.font.size.body2
			color: Theme.color.font.secondary
		}

		CP.ColorImage {
			id: image

			anchors.verticalCenter: temperature.verticalCenter
			color: Theme.color.font.secondary
		}
	}
}
