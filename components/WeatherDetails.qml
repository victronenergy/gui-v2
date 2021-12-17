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
	property int pixelsize: 18
	property alias rowSpacing: row.spacing

	spacing: 2
	width: 65

	Label {
		id: day

		color: Theme.color.font.tertiary
		height: 22
		anchors.left: parent.left
		font.pixelSize: column.pixelsize
	}
	Row {
		id: row

		height: 22
		spacing: 3

		Label {
			id: temperature

			font.pixelSize: column.pixelsize
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
