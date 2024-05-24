/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

TankItem {
	id: root

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
				active: model.index === 0 || root.mergeTanks
				width: {
					if (active) {
						const availableSpace = root.width - 2*Theme.geometry_levelsPage_subgauges_horizontalMargin
						if (root.mergeTanks) {
							return (availableSpace - (gaugeTanks.count - 1) * subgauges.spacing)/gaugeTanks.count
						} else {
							return availableSpace
						}
					} else {
						return 0
					}
				}
				height: subgauges.height
				sourceComponent: TankGauge {
					expanded: root.expanded
					animationEnabled: root.animationEnabled
					valueType: root.tankProperties.valueType
					value: (root.mergeTanks ? model.device.level : root.level) / 100
					isGrouped: root.mergeTanks
				}
				onStatusChanged: if (status === Loader.Error) console.warn("Unable to load tank levels gauge:", errorString())
			}
		}
	}
}
