/*
** Copyright (C) 2021 Victron Energy B.V.
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
	property int pixelsize: Theme.geometry.weatherDetails.pixelSize
	property alias rowSpacing: row.spacing

	width: Theme.geometry.weatherDetails.width

	Label {
		id: day

		color: Theme.color.font.secondary
		height: Theme.geometry.weatherDetails.day.height
		anchors.left: parent.left
		font.pixelSize: column.pixelsize
		verticalAlignment: Text.AlignVCenter
	}
	Row {
		id: row

		topPadding: Theme.geometry.weatherDetails.row.topPadding
		spacing: Theme.geometry.weatherDetails.row.spacing

		Label {
			id: temperature

			font.pixelSize: Theme.font.size.body2
			width: implicitWidth
			color: day.color
		}
		CP.ColorImage {
			id: image

			anchors.verticalCenter: parent.verticalCenter
			width: implicitWidth
			color: day.color
		}
	}
}
