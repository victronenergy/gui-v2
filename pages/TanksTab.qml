/*!
** Copyright (C) 2022 Victron Energy B.V.
**
** The public API for this component is limited to 2 functions, 'addTank(type, name)' and 'removeTank(type, name)'.
** The 'type' is defined in 'enum TankType'.
** Adding or removing tanks updates _tanksModel, which drives changes to _gaugesModel, which handles merging and splitting gauges.
** If there are too many gauges to fit on the screen, gauges of the same type (eg. Fuel) will be merged into a single gauge, containing several tanks.
** The user may click on a merged gauge, which will give an expanded view containing separate gauges, each containing a single tank.
** If tanks are removed, merged tanks will be split back into individual tanks if there is enough space to display them.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

ListView {
	id: root

	property alias _showTankGroupData: tankGroupData.showTankGroupData
	property var _tanksModel: [ // indexed by enum TankType
		fuelTanks,
		freshWaterTanks,
		wasteWaterTanks,
		liveWellTanks,
		oilTanks,
		blackWaterTanks,
		gasolineTanks
	]
	property ListModel _gaugesModel: ListModel{ // contains a single entry for each gauge. Sorted by tank priority. Driven by '_tanksModel'.
		function addTank(newTank, mergingAllowed = true) {
			var index = _gaugesModel.count
			for (var i = _gaugesModel.count - 1; i >= 0; --i) {
				var gauge = _gaugesModel.get(i)
				if (newTank.type < gauge.type) {
					index = i
				}
			}
			var newGauge = {
				type: newTank.type,
				tankTypeName: _tankProperties[newTank.type].groupName,
				gaugeTanks: [newTank] // 'gaugeTanks' is converted to a ListModel when inserted into _gaugesModel
			}
			root._gaugesModel.insert(
						index,
						newGauge
						)
			if (mergingAllowed && _shouldMergeTanks()) {
				// group tanks of the same kind in a single gauge
				var tankTypeToMerge = _getLowestPriorityMergableTankType()
				_mergeTanksOfType(tankTypeToMerge)
			}
		}
		function removeTank(gaugeIndex, tankIndex) {
			var gauge = _gaugesModel.get(gaugeIndex)
			gauge.gaugeTanks.remove(tankIndex)
			if (_shouldSplitTanks()) {
				var gaugeToSplit = _highestPrioritySplittableGauge()
				var finished = false
				while (!finished) {
					finished = splitGauge(gaugeToSplit)
				}
			}
		}
		function splitGauge(gaugeToSplit) {
			var finished = true
			for (var i = 0; i < gaugeToSplit.gaugeTanks.count; ++i ) {
				var tankToSplit = gaugeToSplit.gaugeTanks.get(i)
				addTank(tankToSplit, false)
				gaugeToSplit.gaugeTanks.remove(i)
				finished = false
				break
			}
			return finished
		}
	}

	enum TankType {
		Fuel,
		FreshWater,
		WasteWater,
		LiveWell,
		Oil,
		BlackWater,
		Gasoline
	}
	readonly property var _tankProperties: [ // indexed via enum TankType
		{
			icon: '/images/fuel.svg',
			gaugeType: Gauges.FallingPercentage,
			borderColor: Theme.color.levelsPage.fuel.borderColor,
			//% "Fuel"
			groupName: qsTrId('levels_page_fuel')
		},
		{
			icon: '/images/freshWater20x27.svg',
			gaugeType: Gauges.FallingPercentage,
			borderColor: Theme.color.levelsPage.freshWater.borderColor,
			//% "Fresh water"
			groupName: qsTrId('levels_page_fresh_water')
		},
		{
			icon: '/images/wasteWater.svg',
			gaugeType: Gauges.RisingPercentage,
			borderColor: Theme.color.levelsPage.wasteWater.borderColor,
			//% "Waste water"
			groupName: qsTrId('levels_page_waste_water')
		},
		{
			icon: '/images/liveWell.svg',
			gaugeType: Gauges.FallingPercentage,
			borderColor: Theme.color.levelsPage.liveWell.borderColor,
			//% "Live well"
			groupName: qsTrId('levels_page_live_well')
		},
		{
			icon: '/images/oil.svg',
			gaugeType: Gauges.FallingPercentage,
			borderColor: Theme.color.levelsPage.oil.borderColor,
			//% "Oil"
			groupName: qsTrId('levels_page_oil')
		},
		{
			icon: '/images/blackWater.svg',
			gaugeType: Gauges.RisingPercentage,
			borderColor: Theme.color.levelsPage.blackWater.borderColor,
			//% "Black water"
			groupName: qsTrId('levels_page_black_water')
		},
		{
			icon: '/images/tank.svg', // same as 'Fuel'
			gaugeType: Gauges.FallingPercentage,
			borderColor: Theme.color.levelsPage.gasoline.borderColor,
			//% "Gasoline"
			groupName: qsTrId('levels_page_gasoline')
		}
	]
	readonly property var _spacing: [
		Theme.geometry.levelsPage.gauge.spacing2,
		Theme.geometry.levelsPage.gauge.spacing3,
		Theme.geometry.levelsPage.gauge.spacing4,
		Theme.geometry.levelsPage.gauge.spacing5,
		Theme.geometry.levelsPage.gauge.spacing6,
		Theme.geometry.levelsPage.gauge.spacing7,
	]

	readonly property var _subgaugeWidths: [
		Theme.geometry.levelsPage.subgauge.width1,
		Theme.geometry.levelsPage.subgauge.width2,
		Theme.geometry.levelsPage.subgauge.width3,
		Theme.geometry.levelsPage.subgauge.width4
	]

	property bool anchorCenter: count <= Theme.geometry.levelsPage.tankMergeCount

	function addTank(type, name, percentage = Math.random(), mergingAllowed = true) {
		var newTank = {
			type: type,
			name: name,
			percentage: percentage
		}
		root._tanksModel[type].append(newTank)
		_gaugesModel.addTank(newTank, mergingAllowed)
	}

	function removeTank(type, name) {
		for (var i = 0; i < _gaugesModel.count; ++i) {
			var gaugeTanks = _gaugesModel.get(i).gaugeTanks
			for (var j = 0; j < gaugeTanks.count; ++j) {
				var tank = gaugeTanks.get(j)
				if (tank.name === name) {
					_removeTank(i, j)
					break
				}
			}
		}
	}

	function _removeTank(gaugeIndex, tankIndex) {
		var gauge = _gaugesModel.get(gaugeIndex)
		var tankToRemove = gauge.gaugeTanks.get(tankIndex)
		var tanks = _tanksModel[gauge.type]
		for (var i = 0; i < tanks.count; ++i) {
			var tank = tanks.get(i)
			if (tank.name === tankToRemove.name) {
				tanks.remove(i)
				break
			}
		}
		_gaugesModel.removeTank(gaugeIndex, tankIndex)
		if (gauge.gaugeTanks.count === 0) {
			_gaugesModel.remove(gaugeIndex)
		}
	}

	function _getLowestPriorityMergableTankType() {
		for (var i = _gaugesModel.count -1; i >= 1; --i) {
			var gauge1 = _gaugesModel.get(i)
			var gauge2 = _gaugesModel.get(i - 1)
			if (gauge1.type === gauge2.type) {
				return gauge1.type
			}
		}
		return -1
	}

	function _shouldMergeTanks() {
		return (
		(root._gaugesModel.count >= Theme.geometry.levelsPage.tankMergeCount) &&
		(fuelTanks.count > 1 ||
		freshWaterTanks.count > 1 ||
		wasteWaterTanks.count > 1 ||
		liveWellTanks.count > 1 ||
		oilTanks.count > 1 ||
		blackWaterTanks.count > 1 ||
		gasolineTanks.count > 1)
		)
	}
	function _shouldSplitTanks() {
		var gauge = _highestPrioritySplittableGauge()
		if (gauge && ((_gaugesModel.count + gauge.gaugeTanks.count - 1) <= Theme.geometry.levelsPage.tankMergeCount)) {
			return true
		}
		return false
	}
	function _highestPrioritySplittableGaugeIndex() {
		for (var i = 0; i < _gaugesModel.count; ++i) {
			var gauge = _gaugesModel.get(i)
			if (gauge.gaugeTanks.count > 1) {
				return i
			}
		}
		return -1
	}
	function _highestPrioritySplittableGauge() {
		var index = _highestPrioritySplittableGaugeIndex()
		return  index === -1 ? null : _gaugesModel.get(index)
	}
	function _mergeTanksOfType(type) { // merge all tanks of a type to the leftmost gauge of the matching type
		var destinationGaugeIndex = -1

		function moveGauge(destinationGaugeIndex, type) { // nested function to avoid 'break' breaking out of a 'for' loop nested inside a 'while' loop
			var finished = true

			for (var i = destinationGaugeIndex + 1; i < _gaugesModel.count; ++i) {
				let gauge = _gaugesModel.get(i)
				if (gauge.type === type) {
					// move all tanks in this gauge to the destination gauge
					var tanks = gauge.gaugeTanks
					for (var j = 0; j < tanks.count; ++j) {
						var tankToMove = tanks.get(j)
						_gaugesModel.get(destinationGaugeIndex).gaugeTanks.append(tankToMove)
						tanks.remove(j)
					}
					_gaugesModel.remove(i)
					finished = false
					break
				}
			}
			return finished
		}

		// find the leftmost gauge of the correct type
		for (var i = 0; i < _gaugesModel.count; ++i) {
			let gauge = _gaugesModel.get(i)
			if (gauge.type === type) {
				destinationGaugeIndex = i
				break
			}
		}
		if (destinationGaugeIndex === -1) {
			return -1
		}
		// move tanks of the right type to the destination gauge
		var finished = false
		while (!finished) {
			finished = moveGauge(destinationGaugeIndex, type)
		}
	}

	Component.onCompleted: {
		// Randomly populate the page with dummy gauges
		var numTanks = Math.max(1, Math.floor(Math.random() * 10)) // 1 - 9 tanks
		for (var i = 0; i < numTanks; ++i) {
			var tankType = Math.floor(Math.random() * 7)
			root.addTank(tankType, (("%1 %2").arg(root._tankProperties[tankType].groupName).arg(_tanksModel[tankType].count + 1)))
		}
	}

	function onSplitGauge(index) {
		tankGroupData.model = model.get(index).gaugeTanks
		_showTankGroupData = true
	}

	width: childrenRect.width
	Behavior on width {
		NumberAnimation {
			duration: Theme.animation.levelsPage.animation.duration
			easing.type: Easing.InOutQuad
		}
	}

	model: root._gaugesModel
	orientation: ListView.Horizontal
	spacing: root._gaugesModel.count > 1 ? root._spacing[root._gaugesModel.count - 2] : 0

	Behavior on spacing { NumberAnimation { duration: Theme.animation.levelsPage.animation.duration } }
	Behavior on anchors.leftMargin {
		NumberAnimation { duration: Theme.animation.levelsPage.animation.duration; easing.type: Easing.InOutQuad }
	}

	delegate: LevelsPageGaugeDelegate {
		interactive: PageManager.interactivity !== PageManager.InteractionMode.Idle
		totalCapacity: model.gaugeTanks.count * 1000 // TODO - hook up to real capacity
		percentage: {
			var retval = 0
			for (var i = 0; i < model.gaugeTanks.count; ++i) {
				retval += model.gaugeTanks.get(i).percentage * 1000 // TODO - hook up to real capacity
			}
			retval /= totalCapacity
			return retval
		}
		Component.onCompleted: splitGauge.connect(root.onSplitGauge)
	}

	ListModel {
		id: fuelTanks

		readonly property int type: TanksTab.TankType.Fuel
	}
	ListModel {
		id: freshWaterTanks

		readonly property int type: TanksTab.TankType.FreshWater
	}
	ListModel {
		id: wasteWaterTanks

		readonly property int type: TanksTab.TankType.WasteWater
	}
	ListModel {
		id: liveWellTanks

		readonly property int type: TanksTab.TankType.LiveWell
	}
	ListModel {
		id: oilTanks

		readonly property int type: TanksTab.TankType.Oil
	}
	ListModel {
		id: blackWaterTanks

		readonly property int type: TanksTab.TankType.BlackWater
	}
	ListModel {
		id: gasolineTanks

		readonly property int type: TanksTab.TankType.Gasoline
	}
	ExpandedTanksView {
		// If you have multiple tanks merged into a single gauge, you can click on the gauge.
		// This popup appears, containing an exploded view with each of the tanks in its own gauge.
		id: tankGroupData

		visible: _showTankGroupData
	}
}
