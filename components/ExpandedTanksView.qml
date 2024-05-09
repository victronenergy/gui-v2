/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Gauges

Rectangle {
	id: root

	property bool active
	property alias tankModel: groupedSubgaugesRepeater.model
	readonly property var _tankProperties: Gauges.tankProperties(tankModel.type)
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
				width: Gauges.width(groupedSubgaugesRepeater.count, Theme.geometry_levelsPage_max_tank_count, root.width)
				height: Theme.geometry_levelsPage_panel_expanded_height

				header.text: model.device.name || root._tankProperties.name
				header.color: root._tankProperties.color
				level: model.device.level
				icon: root._tankProperties.icon
				totalCapacity: model.device.capacity
				totalRemaining: model.device.remaining

				gauge: TankGauge {
					width: Theme.geometry_levelsPage_groupedSubgauges_delegate_width
					valueType: root._tankProperties.valueType
					animationEnabled: root.animationEnabled
					value: model.device.level / 100
				}
			}
		}
	}
}
