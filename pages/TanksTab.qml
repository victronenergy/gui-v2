/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

/*
** If there are too many gauges to fit on the screen, gauges of the same type (eg. Fuel) will be merged into a single gauge, containing several tanks.
** The user may click on a merged gauge, which will give an expanded view containing separate gauges, each containing a single tank.
** If tanks are removed, merged tanks will be split back into individual tanks if there is enough space to display them.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

BaseListView {
	id: root

	property bool animationEnabled: true

	model: AggregateTankModel {
		mergeThreshold: Theme.geometry_levelsPage_tankMergeThreshold
		tankModels: Global.tanks.allTankModels
	}
	orientation: ListView.Horizontal
	spacing: Gauges.spacing(count)

	delegate: TankItem {
		id: tankOrGroupDelegate

		required property int index
		required property bool isGroup
		required property Tank tank // null if isGroup=true
		required property TankModel tankModel

		width: Gauges.width(root.count, Theme.geometry_levelsPage_max_tank_count, root.width)
		height: Gauges.height(!!Global.pageManager && Global.pageManager.expandLayout)
		fluidType: tankModel.type
		name: tank?.name ?? ""
		gauge: isGroup ? gaugeGroupComponent : singleGaugeComponent
		level: isGroup ? tankModel.averageLevel : tank?.level ?? NaN
		totalCapacity: isGroup ? tankModel.totalCapacity : tank?.capacity ?? NaN
		totalRemaining: isGroup ? tankModel.totalRemaining : tank?.remaining ?? NaN

		Behavior on height {
			enabled: root.animationEnabled && !!Global.pageManager && Global.pageManager.animatingIdleResize
			NumberAnimation {
				duration: Theme.animation_page_idleResize_duration
				easing.type: Easing.InOutQuad
			}
		}

		PressArea {
			anchors.fill: parent
			enabled: tankOrGroupDelegate.isGroup
			radius: Theme.geometry_levelsPage_panel_radius
			onClicked: {
				expandedTanksLoader.tankModel = tankOrGroupDelegate.tankModel
				expandedTanksLoader.active = true
				expandedTanksLoader.item.active = true
			}
		}

		Component {
			id: singleGaugeComponent

			TankGauge {
				anchors.fill: parent
				expanded: !!Global.pageManager && Global.pageManager.expandLayout
				animationEnabled: root.animationEnabled
				valueType: tankOrGroupDelegate.tankProperties.valueType
				value: tankOrGroupDelegate.tank ? tankOrGroupDelegate.tank.level / 100 : NaN
				isGrouped: false
			}
		}

		Component {
			id: gaugeGroupComponent

			Row {
				id: gaugeRow

				anchors.fill: parent
				spacing: Theme.geometry_levelsPage_subgauges_spacing

				Repeater {
					model: tankOrGroupDelegate.tankModel
					delegate: TankGauge {
						required property BaseTankDevice device

						width: (gaugeRow.width - (gaugeRow.spacing * (tankOrGroupDelegate.tankModel.count - 1))) / tankOrGroupDelegate.tankModel.count
						height: parent.height
						expanded: !!Global.pageManager && Global.pageManager.expandLayout
						animationEnabled: root.animationEnabled
						valueType: tankOrGroupDelegate.tankProperties.valueType
						value: device.level / 100
						isGrouped: true
					}
				}
			}
		}
	}

	// If you have multiple tanks merged into a single gauge, you can click on the gauge.
	// This popup appears, containing an exploded view with each of the tanks in its own gauge.
	Loader {
		id: expandedTanksLoader

		property var tankModel

		active: false
		sourceComponent: ExpandedTanksView {
			tankModel: expandedTanksLoader.tankModel
			animationEnabled: root.animationEnabled
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load expanded tanks view:", errorString())
	}
}
