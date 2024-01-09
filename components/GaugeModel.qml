/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Gauges

/*
  A model of gauge data, sorted according to the preferred order from system settings.
*/

ListModel {
	id: root

	property alias sourceModel: _gaugeObjects.model
	property int maximumGaugeCount

	function addGauge(gauge) {
		const sortedGaugeTypes = Global.systemSettings.briefView.centralGauges.value || []

		if (count === maximumGaugeCount) {
			// Try removing a gauge that is not a preferred gauge, to make space for the new one
			let removeIndex = -1
			for (let i = 0; i < count; ++i) {
				if (sortedGaugeTypes.indexOf(get(i).tankType) < 0) {
					removeIndex = i
					break
				}
			}
			if (removeIndex >= 0) {
				remove(removeIndex)
			} else {
				// Have reached limit for number of gauges to display
				return
			}
		}
		insert(_insertionIndex(gauge.tankType, sortedGaugeTypes),
			   Object.assign({}, Gauges.tankProperties(gauge.tankType), { tankType: gauge.tankType, value: gauge.tankLevel }))
	}

	function findGauge(gauge) {
		for (let i = 0; i < count; ++i) {
			if (get(i).tankType === gauge.tankType) {
				return i
			}
		}
		return -1
	}

	function updateGauge(gauge) {
		const gaugeIndex = findGauge(gauge)
		if (gaugeIndex >= 0) {
			set(gaugeIndex, { name: gauge.tankName, icon: gauge.tankIcon, value: gauge.tankLevel })
		}
	}

	function _insertionIndex(tankType, sortedGaugeTypes) {
		const preferredSortIndex = sortedGaugeTypes.indexOf(tankType)
		if (preferredSortIndex < 0) {
			// If no preference, just add gauge to end
			return count
		}
		for (let i = 0; i < count; ++i) {
			const sortIndex = sortedGaugeTypes.indexOf(get(i).tankType)
			if (sortIndex < 0 || preferredSortIndex < sortIndex) {
				return i
			}
		}
		return count
	}

	property Instantiator _gaugeObjects: Instantiator {
		id: _gaugeObjects

		delegate: QtObject {
			id: gaugeObject

			readonly property int tankType: modelData
			readonly property bool isBattery: tankType === VenusOS.Tank_Type_Battery

			readonly property string tankName: _tankProperties.name
			readonly property string tankIcon: isBattery ? Global.batteries.system.icon : _tankProperties.icon
			readonly property var tankModel: isBattery ? null : Global.tanks.tankModel(tankType)
			readonly property real tankLevel: isBattery
					? Math.round(Global.batteries.system.stateOfCharge || 0)
					: (tankModel.count === 0 || tankModel.totalCapacity === 0
					   ? 0
					   : (tankModel.totalRemaining / tankModel.totalCapacity) * 100)

			readonly property var _tankProperties: Gauges.tankProperties(tankType)

			property Connections _tankModelConn: Connections {
				target: gaugeObject.tankModel

				function onCountChanged() {
					gaugeObject.refresh()
				}
			}

			function refresh() {
				const gaugeIndex = root.findGauge(gaugeObject)
				if (isBattery) {
					if (gaugeIndex < 0) {
						root.addGauge(gaugeObject)
					}
				} else if (gaugeIndex >= 0 && tankModel.count === 0) {
					root.remove(gaugeIndex)
				} else if (gaugeIndex < 0 && tankModel.count > 0) {
					root.addGauge(gaugeObject)
				}
			}

			function _updateGaugeModel() {
				root.updateGauge(gaugeObject)
			}

			// If tank data changes, update the model at the end of the event loop to avoid
			// excess updates if multiple values change simultaneously for the same tank.
			onTankNameChanged: Qt.callLater(_updateGaugeModel)
			onTankIconChanged: Qt.callLater(_updateGaugeModel)
			onTankLevelChanged: Qt.callLater(_updateGaugeModel)

			Component.onCompleted: {
				if (isBattery || tankModel.count > 0) {
					root.addGauge(gaugeObject)
				}
			}
		}
	}

	property Connections _centralGaugesConn: Connections {
		target: Global.systemSettings.briefView.centralGauges

		function onValueChanged() {
			root.clear()
			for (let i = 0; i < _gaugeObjects.count; ++i) {
				_gaugeObjects.objectAt(i).refresh()
			}
		}
	}
}
