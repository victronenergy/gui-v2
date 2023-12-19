/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Column {
	id: column

	property alias day: day.text
	property alias temperature: temperature.text
	property alias source: image.source

	width: Theme.geometry_weatherDetails_width

	Label {
		id: day

		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_size_body1
	}
	Row {
		id: row

		spacing: Theme.geometry_weatherDetails_row_spacing

		Label {
			id: temperature

			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_secondary
		}

		CP.ColorImage {
			id: image

			anchors.verticalCenter: temperature.verticalCenter
			color: Theme.color_font_secondary
		}
	}
}
