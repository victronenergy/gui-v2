/*!
** Copyright (C) 2022 Victron Energy B.V.
**
** If there are too many gauges to fit on the screen, gauges of the same type (eg. Fuel) will be merged into a single gauge, containing several tanks.
** The user may click on a merged gauge, which will give an expanded view containing separate gauges, each containing a single tank.
** If tanks are removed, merged tanks will be split back into individual tanks if there is enough space to display them.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils

ListView {
	id: root

	property bool animateModelChanges

	property int _tankItemCount // No. of visible tank items, where merged tanks only count as one item
	property var _mergedTankTypes: []
	property int _lastVisibleTankType

	readonly property var _spacingValues: [
		Theme.geometry.levelsPage.gauge.spacing2,
		Theme.geometry.levelsPage.gauge.spacing3,
		Theme.geometry.levelsPage.gauge.spacing4,
		Theme.geometry.levelsPage.gauge.spacing5,
		Theme.geometry.levelsPage.gauge.spacing6,
		Theme.geometry.levelsPage.gauge.spacing7,
	]

	function _spacing() {
		if (_tankItemCount <= 1) {
			return 0
		}
		return _spacingValues[_tankItemCount - 1] || Theme.geometry.levelsPage.gauge.spacing7
	}

	function _updateLayout(initialLayout) {
		let i = 0
		for (i = tanks.tankTypes.length - 1; i >= 0; --i) {
			if (tanks.tankModel(tanks.tankTypes[i]).count > 0) {
				_lastVisibleTankType = tanks.tankTypes[i]
				break
			}
		}

		if (tanks.totalTankCount < Theme.geometry.levelsPage.tankMergeThreshold) {
			// There is no more than one tank per type, so merging is not required
			_tankItemCount = tanks.totalTankCount
			_mergedTankTypes = []
		} else {
			let tankItemCountIfMerged = tanks.totalTankCount
			let mergedTankTypes = []
			for (i = 0; i < tanks.tankTypes.length; ++i) {
				const tankModel = tanks.tankModel(tanks.tankTypes[i])
				if (tankModel.count > 1) {
					tankItemCountIfMerged = tankItemCountIfMerged - tankModel.count + 1
					mergedTankTypes.push(tanks.tankTypes[i])
					if (tankItemCountIfMerged < Theme.geometry.levelsPage.tankMergeThreshold) {
						break
					}
				}
			}
			_tankItemCount = tankItemCountIfMerged
			_mergedTankTypes = mergedTankTypes
		}

		if (!initialLayout) {
			animateModelChanges = true
		}
	}

	model: tanks.tankTypes
	orientation: ListView.Horizontal
	boundsBehavior: Flickable.StopAtBounds

	delegate: Row {
		id: tankTypeDelegate

		readonly property int tankType: modelData
		readonly property var tankModel: tanks.tankModel(tankType)
		readonly property bool mergeTanks: root._mergedTankTypes.indexOf(tankType) >= 0

		// Add spacing between this set of tank types and the next
		width: implicitWidth + (gaugeRepeater.count === 0 || tankType == root._lastVisibleTankType ? 0 : root._spacing())

		Repeater {
			id: gaugeRepeater

			model: tankTypeDelegate.tankModel.count > 0
				   ? (tankTypeDelegate.mergeTanks ? 1 : tankTypeDelegate.tankModel)
				   : null

			delegate: Item {
				// Add spacing between this tank and the next (if there is more than one of this type)
				width: gaugeDelegate.width + (model.index === gaugeRepeater.count - 1 ? 0 : root._spacing())
				height: 1

				LevelsPageGaugeDelegate {
					id: gaugeDelegate

					tankType: tankTypeDelegate.tankType
					title: mergeTanks
						   ? tankProperties.name
						   : model.tank.name || tankProperties.name
					expanded: PageManager.expandLayout

					level: mergeTanks
							? (gaugeTanks.totalCapacity === 0
							   ? 0
							   : (gaugeTanks.totalRemaining / gaugeTanks.totalCapacity) * 100)
							: model.tank.level
					totalRemaining: mergeTanks ? gaugeTanks.totalRemaining : model.tank.remaining
					totalCapacity: mergeTanks ? gaugeTanks.totalCapacity : model.tank.capacity

					gaugeTanks: tankTypeDelegate.tankModel
					mergeTanks: tankTypeDelegate.mergeTanks

					MouseArea {
						anchors.fill: parent
						enabled: tankTypeDelegate.tankModel.count > 1
						onClicked: {
							expandedTanksLoader.tankModel = tankTypeDelegate.tankModel
							expandedTanksLoader.active = true
							expandedTanksLoader.item.active = true
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		_updateLayout(true)
	}

	Connections {
		target: tanks
		function onTotalTankCountChanged() {
			Qt.callLater(_updateLayout)
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
		}
	}
}
