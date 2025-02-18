/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

/*
  A model of gauge data, sorted according to the preferred order from system settings.
*/

ListModel {
	id: root

	function gaugesToDisplay() {
		let gaugeTypes = []
		const preferredGaugeTypes = Global.systemSettings.briefView.centralGauges.preferredOrder

		for (let i = 0; i < preferredGaugeTypes.length; ++i) {
			if (gaugeTypes.indexOf(preferredGaugeTypes[i]) >= 0) {
				// Do not show more than one gauge for the same tank type.
				continue
			} else if (preferredGaugeTypes[i] === VenusOS.Tank_Type_Battery) {
				// Assume battery is always available.
				gaugeTypes.push(VenusOS.Tank_Type_Battery)
			} else if (preferredGaugeTypes[i] !== VenusOS.Tank_Type_None) {
				// If there is a tank of this type, then add the type to the displayed gauges. If
				// not, add another tank that is available on the system. Otherwise, if the user has
				// not selected any preferred tanks, but does not have any of the tanks from the
				// default preferences, then the center display would not show any tanks at all.
				const preferredTankModel = Global.tanks.tankModel(preferredGaugeTypes[i])
				if (preferredTankModel.count > 0) {
					gaugeTypes.push(preferredGaugeTypes[i])
				} else {
					for (const tankModel of Global.tanks.allTankModels) {
						if (tankModel.count > 0 && gaugeTypes.indexOf(tankModel.type) < 0) {
							gaugeTypes.push(tankModel.type)
							break
						}
					}
				}
			}
		}
		return gaugeTypes
	}

	// Rebuild the gauge model, based on the preferred gauges and the tanks available.
	function _reset() {
		const gaugeTypes = gaugesToDisplay()
		if (gaugeTypes != _gaugeObjects.model) {
			_gaugeObjects.model = []

			// Clear the model and add default values for each gauge.
			clear()
			for (let i = 0; i < gaugeTypes.length; ++i) {
				append(Object.assign({}, Gauges.tankProperties(gaugeTypes[i]), { tankType: gaugeTypes[i], level: 0, value: 0 }))
			}
			_gaugeObjects.model = gaugeTypes
		}
	}

	function _updateGauge(gaugeIndex, gauge) {
		if (gaugeIndex >= 0 && gaugeIndex < count) {
			const value = Global.systemSettings.briefView.unit.value === VenusOS.BriefView_Unit_Percentage || gauge.isBattery ? gauge.tankLevel : gauge.tankRemaining
			set(gaugeIndex, { name: gauge.tankName, icon: gauge.tankIcon, level: gauge.tankLevel, value: value })
		}
	}

	property Instantiator _gaugeObjects: Instantiator {
		id: _gaugeObjects

		model: null
		delegate: QtObject {
			id: gaugeObject

			required property int modelData
			required property int index

			readonly property int tankType: modelData
			readonly property bool isBattery: tankType === VenusOS.Tank_Type_Battery

			readonly property string tankName: _tankProperties.name
			readonly property string tankIcon: isBattery ? Global.system.battery.icon : _tankProperties.icon
			readonly property var tankModel: isBattery ? null : Global.tanks.tankModel(tankType)
			readonly property real tankLevel: isBattery ? Math.round(Global.system.battery.stateOfCharge)
					: !isNaN(tankModel.averageLevel) ? tankModel.averageLevel
					: (tankModel.count === 0 || tankModel.totalCapacity === 0) ? 0
					: ((Math.min(tankModel.totalRemaining / tankModel.totalCapacity, 1.0) * 100))
			readonly property real tankRemaining: isBattery ? null
					: Units.convert(tankModel.totalRemaining, VenusOS.Units_Volume_CubicMeter, Global.systemSettings.volumeUnit)

			readonly property var _tankProperties: Gauges.tankProperties(tankType)

			function _updateGaugeModel() {
				if (root) { // may be null if this object has been destroyed after the Qt.callLater() call
					root._updateGauge(index, gaugeObject)
				}
			}

			// If tank data changes, update the model at the end of the event loop to avoid
			// excess updates if multiple values change simultaneously for the same tank.
			onTankNameChanged: Qt.callLater(_updateGaugeModel)
			onTankIconChanged: Qt.callLater(_updateGaugeModel)
			onTankLevelChanged: Qt.callLater(_updateGaugeModel)

			property Connections _unitConn: Connections {
				target: Global.systemSettings.briefView.unit

				function onValueChanged() {
					Qt.callLater(_updateGaugeModel)
				}
			}
		}
	}

	property Connections _tankCountConn: Connections {
		target: Global.tanks

		function onTotalTankCountChanged() {
			Qt.callLater(root._reset)
		}
	}

	property Connections _centralGaugesConn: Connections {
		target: Global.systemSettings.briefView.centralGauges

		function onPreferredOrderChanged() {
			Qt.callLater(root._reset)
		}
	}

	Component.onCompleted: Qt.callLater(root._reset)
}
