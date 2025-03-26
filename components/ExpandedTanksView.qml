/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Rectangle {
	id: root

	property bool active
	property alias tankModel: groupedSubgaugesRepeater.model
	property bool animationEnabled

	parent: Global.dialogLayer
	anchors.fill: parent
	color: Theme.color_levelsPage_tankGroupData_background_color
	opacity: active ? 1 : 0

	Behavior on opacity {
		enabled: root.animationEnabled
		OpacityAnimator {
			duration: Theme.animation_levelsPage_tanks_expandedView_fade_duration
		}
	}

	MouseArea {
		anchors.fill: parent
		enabled: root.active
		onClicked: root.active = false
	}

	Row {
		id: groupedSubgauges

		anchors.centerIn: parent
		spacing: Gauges.spacing(groupedSubgaugesRepeater.count)

		Repeater {
			id: groupedSubgaugesRepeater

			delegate: TankItem {
				id: gaugeDelegate

				width: Gauges.width(groupedSubgaugesRepeater.count, Theme.geometry_levelsPage_max_tank_count, root.width)
				height: Theme.geometry_levelsPage_panel_expanded_height
				fluidType: root.tankModel.type
				name: model.device.name
				level: model.device.level
				totalCapacity: model.device.capacity
				totalRemaining: model.device.remaining

				gauge: TankGauge {
					width: Theme.geometry_levelsPage_groupedSubgauges_delegate_width
					valueType: gaugeDelegate.tankProperties.valueType
					animationEnabled: root.animationEnabled
					value: model.device.level / 100
				}
			}
		}
	}
}
