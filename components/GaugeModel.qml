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

	function _loadDefaultGauges() {
		let gauges = []
		if (Global.tanks.totalTankCount === 0) {
			// There are no tanks, so there are no gauges to be shown.
			return []
		} else {
			// Show the system battery, followed by gauges with aggregated tank levels for whichever
			// tank types are available on the system.
			gauges.push({ centerGaugeType: VenusOS.BriefView_CentralGauge_SystemBattery, value: "" })
			for (const tankModel of Global.tanks.allTankModels) {
				if (tankModel.count > 0) {
					gauges.push({ centerGaugeType: VenusOS.BriefView_CentralGauge_TankAggregate, value: tankModel.type })
					if (gauges.length >= Theme.geometry_briefPage_centerGauge_maximumGaugeCount) {
						break
					}
				}
			}
		}
		return gauges
	}

	// Rebuild the gauge model, based on the preferred gauges and the tanks available.
	function _reset() {
		let useDefaultGauges = false
		let gauges = Global.systemSettings.briefView.centralGauges
		if (gauges.length === 0) {
			gauges = _loadDefaultGauges()
			useDefaultGauges = true
		} else {
			gauges = gauges.filter((data) => data.centerGaugeType !== VenusOS.BriefView_CentralGauge_None)
		}
		if (gauges !== _gaugeObjects.model) {
			// Clear the model and add default values for each gauge.
			_gaugeObjects.model = []
			let hasBatteryId = false
			for (let i = 0; i < gauges.length; ++i) {
				if (!hasBatteryId && gauges[i].centerGaugeType === VenusOS.BriefView_CentralGauge_BatteryId) {
					hasBatteryId = true
				}
				root.set(i, {
					tankType: -1,
					name: "",
					icon: "",
					valueType: VenusOS.Gauges_ValueType_NeutralPercentage,
					color: Theme.color_ok,
					level: 0,
					value: 0,
				})
			}
			while (count > gauges.length) {
				root.remove(count - 1)
			}

			root._batteriesItem.active = hasBatteryId
			root._gaugeObjects.model = gauges

			// If showing aggregated tank types for the available tanks on the system, then refresh
			// the model whenever the available tanks have changed.
			root._tankCountConn.enabled = useDefaultGauges
		}
	}

	function _updateGauge(gaugeIndex, gauge) {
		if (gaugeIndex >= 0 && gaugeIndex < count) {
			const value = Global.systemSettings.briefView.unit.value === VenusOS.BriefView_Unit_Percentage
						|| gauge.type === VenusOS.Tank_Type_Battery
					? gauge.level
					: gauge.remaining
			set(gaugeIndex, {
				tankType: gauge.type,
				name: gauge.name,
				icon: gauge.icon,
				valueType: gauge.valueType,
				color: gauge.color,
				level: gauge.level,
				value: value
			})
		}
	}

	readonly property VeQuickItem _batteriesItem: VeQuickItem {
		property bool active

		uid: active ? Global.system.serviceUid + "/Batteries" : ""
	}

	component GaugeSource : QtObject {
		required property int type
		property string name
		property string icon
		property real level
		property real remaining
	}

	readonly property Instantiator _gaugeObjects: Instantiator {
		id: _gaugeObjects

		model: null
		delegate: Loader {
			id: gaugeObject

			required property var modelData
			required property int index

			readonly property int type: item?.type ?? -1
			readonly property string name: item?.name || properties.name || ""
			readonly property string icon: item?.icon || properties.icon || ""
			readonly property real level: item?.level ?? NaN
			readonly property real remaining: item?.remaining ?? NaN
			readonly property int valueType: properties.valueType ?? VenusOS.Gauges_ValueType_NeutralPercentage
			readonly property color color: properties.color ?? Theme.color_ok

			readonly property var properties: type >= 0 ? Gauges.tankProperties(type) : ({})

			function _updateGaugeModel() {
				if (root) { // may be null if this object has been destroyed after the Qt.callLater() call
					root._updateGauge(index, gaugeObject)
				}
			}

			sourceComponent: modelData.centerGaugeType === VenusOS.BriefView_CentralGauge_BatteryId ? batteryIdSource
					: modelData.centerGaugeType === VenusOS.BriefView_CentralGauge_SystemBattery ? systemBatterySource
					: modelData.centerGaugeType === VenusOS.BriefView_CentralGauge_TankAggregate ? tankAggregateSource
					: tankIdSource

			// If tank data changes, update the model at the end of the event loop to avoid
			// excess updates if multiple values change simultaneously for the same tank.
			onNameChanged: Qt.callLater(_updateGaugeModel)
			onIconChanged: Qt.callLater(_updateGaugeModel)
			onLevelChanged: Qt.callLater(_updateGaugeModel)

			Connections {
				target: Global.systemSettings.briefView.unit

				function onValueChanged() {
					Qt.callLater(_updateGaugeModel)
				}
			}

			Component {
				id: batteryIdSource

				GaugeSource {
					id: battery

					type: VenusOS.Tank_Type_Battery

					readonly property Connections _batteriesConn: Connections {
						target: _batteriesItem
						function onValueChanged() {
							const batteryId = gaugeObject.modelData.value
							const batteryList = _batteriesItem.value ?? []
							let batteryName = ""
							let batteryIcon = ""
							let batteryLevel = ""
							for (const battery of batteryList) {
								if (battery.id === batteryId) {
									const power = battery.power ?? NaN
									batteryName = battery.name ?? ""
									batteryIcon = VenusOS.battery_iconFromMode(VenusOS.battery_modeFromPower(power))
									batteryLevel = battery.soc ?? NaN
									break
								}
							}
							battery.name = batteryName
							battery.icon = batteryIcon
							battery.level = batteryLevel
						}
					}
				}
			}

			Component {
				id: systemBatterySource

				GaugeSource {
					type: VenusOS.Tank_Type_Battery
					icon: Global.system.battery.icon
					level: Global.system.battery.stateOfCharge
				}
			}

			Component {
				id: tankAggregateSource

				GaugeSource {
					readonly property TankModel _tankModel: Global.tanks.tankModel(type)

					type: parseInt(gaugeObject.modelData.value)
					level: _tankModel.count === 0 ? NaN
							: !isNaN(_tankModel.averageLevel) ? _tankModel.averageLevel
							: (_tankModel.count === 0 || _tankModel.totalCapacity === 0) ? 0
							: ((Math.min(_tankModel.totalRemaining / _tankModel.totalCapacity, 1.0) * 100))
					remaining: Units.convert(_tankModel.totalRemaining, VenusOS.Units_Volume_CubicMeter, Global.systemSettings.volumeUnit)
				}
			}

			Component {
				id: tankIdSource

				GaugeSource {
					readonly property Tank _device: _findTank()

					function _findTank() {
						const tankIdInfo = BackendConnection.portableIdInfo(gaugeObject.modelData.value)
						for (const tankModel of Global.tanks.allTankModels) {
							const tank = tankModel.deviceForDeviceInstance(tankIdInfo.instance)
							if (tank) {
								return tank
							}
						}
						return null
					}

					name: _device?.name || ""
					type: _device?.type ?? -1
					level: _device?.level ?? NaN
					remaining: Units.convert(_device?.remaining ?? NaN, VenusOS.Units_Volume_CubicMeter, Global.systemSettings.volumeUnit)
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
		target: Global.systemSettings.briefView

		function onCentralGaugesChanged() {
			Qt.callLater(root._reset)
		}
	}

	Component.onCompleted: Qt.callLater(root._reset)
}
