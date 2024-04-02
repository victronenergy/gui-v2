/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	height: label.height
	width: label.width + Theme.geometry_button_spacing

	QuantityLabel {
		id: label

		value: cpuInfo.usage
		unit: VenusOS.Units_Percentage
		anchors.centerIn: parent

		CpuInfo {
			id: cpuInfo
		}
	}
}
