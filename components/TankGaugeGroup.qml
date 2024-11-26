/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

TankItem {
	id: root

	property int groupIndex: -1
	property bool animationEnabled: true
	property int tankType
	property bool expanded

	property BaseDeviceModel gaugeTanks
	property bool mergeTanks

	readonly property var tankProperties: Gauges.tankProperties(tankType)

	header.color: tankProperties.color
	icon: tankProperties.icon

	Behavior on height {
		enabled: root.animationEnabled && !!Global.pageManager && Global.pageManager.animatingIdleResize
		NumberAnimation {
			duration: Theme.animation_page_idleResize_duration
			easing.type: Easing.InOutQuad
		}
	}

	gauge: Row {
		id: subgauges // contains 1 or more gauges of a single type

		height: parent.height
		spacing: root.mergeTanks ? Theme.geometry_levelsPage_subgauges_spacing : 0

		Repeater {
			model: root.gaugeTanks
			delegate: Loader {
				id: tankGaugeLoader
				property int tankIndex: model.index
				property real tankLevel: model.device.level
				// There are two options: either there is a single TankGaugeGroup which is showing
				// all gauges for tanks of this type (and mergeTanks will be true), OR there are
				// multiple TankGaugeGroup instances for tanks of this type, and each TankGaugeGroup
				// should only show the gauge for the specific tank where the tank index matches the group index.
				active: root.mergeTanks || (tankIndex === root.groupIndex)
				width: {
					if (active) {
						const availableSpace = root.width - 2 * Theme.geometry_levelsPage_subgauges_horizontalMargin;
						if (root.mergeTanks) {
							return (availableSpace - (gaugeTanks.count - 1) * subgauges.spacing) / gaugeTanks.count;
						} else {
							return availableSpace;
						}
					} else {
						return 0;
					}
				}
				height: subgauges.height
				sourceComponent: TankGauge {
					expanded: root.expanded
					animationEnabled: root.animationEnabled
					valueType: root.tankProperties.valueType
					value: tankGaugeLoader.tankLevel / 100
					isGrouped: root.mergeTanks
				}
				onStatusChanged: if (status === Loader.Error)
					console.warn("Unable to load tank levels gauge:", errorString())
			}
		}
	}
}
