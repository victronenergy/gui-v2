/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

BaseListView {
	id: root

	property bool animationEnabled

	orientation: Qt.Horizontal
	spacing: Gauges.spacing(count)
	delegate: TankItem {
		id: tankDelegate

		required property Tank device

		width: Gauges.width(root.model.count, Theme.geometry_levelsPage_max_tank_count, Theme.geometry_screen_width)
		height: Theme.geometry_levelsPage_panel_expanded_height
		status: device.status
		fluidType: device.type
		name: device.name
		level: device.level
		totalCapacity: device.capacity
		totalRemaining: device.remaining

		gauge: TankGauge {
			width: Theme.geometry_levelsPage_groupedSubgauges_delegate_width
			valueType: tankDelegate.tankProperties.valueType
			animationEnabled: root.animationEnabled
			value: tankDelegate.device.level / 100
			surfaceColor: tankDelegate.status === VenusOS.Tank_Status_Ok
				? Theme.color_levelsPage_gauge_separatorBarColor
				: tankDelegate.backgroundColor
		}
	}
}
